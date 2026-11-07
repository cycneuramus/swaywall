## Swaywall

An intelligent wallpaper switcher for Wayland compositors.

- Sets a random wallpaper from a given directory
- Remembers previous selections:
  - Never repeats a wallpaper until the entire catalogue has been cycled through
  - Can restore the latest selection (useful on e.g. window manager startup)

*Looking for the old Python version? See the [`python-legacy`](https://github.com/cycneuramus/swaywall/blob/python-legacy) branch.*

## Installation

### Compiling from source

`nim c -d:release -o:swaywall swaywall.nim`

### Downloading binary

Pre-built binaries for Linux (AMD64) are available on the [release page](https://github.com/cycneuramus/swaywall/releases).

## Usage

```
Intelligent wallpaper switcher for Wayland compositors.

Usage:
  swaywall [options] dir

Arguments:
  dir              Path to wallpaper directory.

Options:
  -h, --help
  -r, --restore              Restore latest wallpaper.
  -b, --backend=BACKEND      Wallpaper setting backend. Possible values: [swaymsg, awww] (default: swaymsg)
  -e, --extensions=EXTENSIONS
                             Comma-separated image file extensions to look for. (default: png,jpg,jpeg)
```
