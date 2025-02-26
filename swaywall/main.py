#!/usr/bin/env python3

import argparse
import os
import random
import subprocess
from pathlib import Path


def dedupe(lst: list) -> list:
    return list(set(lst))


def ensure_exists(file: Path) -> None:
    file.parent.mkdir(parents=True, exist_ok=True)
    file.touch(exist_ok=True)


def find(path: Path, exts: list[str]) -> list:
    res = []
    for e in exts:
        for i in path.glob(f"**/*.{e}"):
            res.append(i)
    return res


def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser(
        prog="swaywall", description="Intelligent wallpaper switcher for swaywm"
    )
    ap.add_argument("dir", help="path to wallpaper directory", type=str)
    ap.add_argument(
        "-r", "--restore", help="restore latest wallpaper", action="store_true"
    )
    return ap.parse_args()


def get_history(hst_file: Path) -> list:
    res = []
    ensure_exists(hst_file)
    for line in hst_file.read_text().splitlines():
        i = line.rstrip()
        res.append(i)
    return res


def get_new(walls: list, hst: list) -> Path:
    new_walls = []
    for w in walls:
        if str(w) not in hst:
            new_walls.append(w)
    return random.choice(new_walls)


def remember(new: Path, walls: list, hst: list, hst_file: Path) -> None:
    hst = dedupe(hst)
    random.shuffle(hst)  # avoid cycling through walls in the same order

    hst.insert(0, str(new))
    del hst[len(walls) - 1 :]
    with hst_file.open("w") as f:
        for i in hst:
            f.write(f"{i}\n")


def set_wall(img: Path) -> None:
    subprocess.run(["swaymsg", "output", "*", "bg", str(img), "fill"], check=True)


def main() -> None:
    args = parse_args()
    walls_dir = Path(args.dir)
    if not walls_dir.is_dir():
        raise FileNotFoundError(f"directory not found: {walls_dir}")

    state = os.getenv("XDG_STATE_HOME") or Path.home() / ".local" / "state"
    hst_file = Path(state) / "wallpaperhst"
    img_exts = ["png", "jpg", "jpeg"]

    hst = get_history(hst_file)
    if args.restore and hst:
        set_wall(hst[0])
        exit()

    walls = find(walls_dir, img_exts)
    if not walls:
        raise FileNotFoundError(f"no wallpapers found in {walls_dir}")

    new = get_new(walls, hst)
    if new:
        remember(new, walls, hst, hst_file)
        set_wall(new)


if __name__ == "__main__":
    main()
