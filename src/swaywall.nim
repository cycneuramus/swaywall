import std/[options, os, osproc, random, sequtils, strformat, strutils]
import pkg/argparse

type Backend = enum
  swaymsg
  awww

func parseExtensions(exts: string): seq[string] =
  for ext in exts.split(","):
    let name = ext.strip(chars = Whitespace + {'.'}).toLowerAscii
    if name.len > 0:
      result.add(fmt".{name}")

proc findWalls(dir: string, exts: seq[string]): seq[string] =
  for file in walkDirRec(dir, yieldFilter = {pcFile, pcLinkToFile}):
    if file.splitFile.ext.toLowerAscii in exts:
      result.add(file)

proc getHistory(historyFile: string): seq[string] =
  if historyFile.fileExists:
    for line in historyFile.lines:
      let wall = line.strip()
      if wall.fileExists:
        result.add(wall)

proc updateHistory(walls, history: seq[string]): seq[string] =
  let
    seen = history.filterIt(it in walls) # ignore walls no longer in dir
    fresh = walls.filterIt(it notin seen)
  if fresh.len > 0:
    return fresh.sample() & seen # new pick is first entry in updated history

  # Wall cycle complete: start a new one, but don't repeat the current wall
  let
    others = walls.filterIt(it != seen[0])
    pool = if others.len > 0: others else: walls
  @[pool.sample()]

proc setWall(wall: string, backend: Backend) =
  let args =
    case backend
    of swaymsg:
      @["output", "*", "bg", wall, "fill"]
    of awww:
      @["img", wall]

  if execCmd(quoteShellCommand(@[$backend] & args)) != 0:
    raise newException(OSError, fmt"Failed to set wallpaper using {$backend}")

template buildParser(): untyped =
  newParser("swaywall"):
    help("Intelligent wallpaper switcher for swaywm.")
    flag("-r", "--restore", help = "Restore latest wallpaper.")
    option(
      "-b",
      "--backend",
      help = "Wallpaper setting backend.",
      default = some($swaymsg),
      choices = Backend.toSeq.mapIt($it),
    )
    option(
      "-e",
      "--extensions",
      help = "Comma-separated image file extensions to look for.",
      default = some("png,jpg,jpeg"),
    )
    arg("dir", help = "Path to wallpaper directory.")

proc main() =
  var parser = buildParser()
  let args =
    try:
      parser.parse()
    except ShortCircuit as e:
      if e.flag != "argparse_help":
        raise
      echo e.help
      quit(QuitSuccess)
    except UsageError as e:
      quit(fmt"Error parsing arguments: {e.msg}")

  let dir = args.dir.absolutePath
  if not dir.dirExists:
    quit(fmt"Directory not found: {dir}")

  let backend = parseEnum[Backend](args.backend)
  if findExe($backend).isEmptyOrWhitespace:
    quit(fmt"Executable not found: '{$backend}'")

  let
    historyFile =
      getEnv("XDG_STATE_HOME", getHomeDir() / ".local" / "state") / "wallpaperhst"
    history = getHistory(historyFile)

  if args.restore and history.len > 0:
    try:
      setWall(history[0], backend)
    except CatchableError as e:
      quit(e.msg)
    return

  let walls = findWalls(dir, parseExtensions(args.extensions))
  if walls.len == 0:
    quit(fmt"No wallpapers found in {dir}")

  randomize() # seed the random number generator for new wall pick
  let newHistory = updateHistory(walls, history)
  try:
    setWall(newHistory[0], backend)
  except CatchableError as e:
    quit(e.msg)

  if not historyFile.parentDir.dirExists:
    historyFile.parentDir.createDir()
  historyFile.writeFile(newHistory.join("\n"))

when isMainModule:
  main()
