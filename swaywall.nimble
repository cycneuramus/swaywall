# Package

version = "2.0.0" # x-release-please-version
author = "cycneuramus"
description = "An intelligent wallpaper switcher for Wayland compositors"
license = "GPL-3.0-only"
srcDir = "src"
bin = @["swaywall"]

# Dependencies

requires "nim >= 2.2.2"

requires "argparse >= 4.0.2"
