import std/[algorithm, os, random, sequtils, strutils, tempfiles, unittest]
import pkg/argparse
import ../src/swaywall {.all.} # {.all.} = non-exported procs reachable

proc touch*(path: string) =
  createDir(path.parentDir)
  writeFile(path, "")

randomize(1234) # fixed seed keeps runs reproducible

suite "parseExtensions":
  test "splits on commas and prefixes a dot":
    check parseExtensions("png,jpg,jpeg") == @[".png", ".jpg", ".jpeg"]

  test "handles a single extension":
    check parseExtensions("webp") == @[".webp"]

  test "trims whitespace around each entry":
    check parseExtensions(" png , jpg ,jpeg ") == @[".png", ".jpg", ".jpeg"]

  test "lowercases entries":
    check parseExtensions("PNG,JpG") == @[".png", ".jpg"]

  test "leading dot is optional":
    check parseExtensions(".png,jpg,..webp") == @[".png", ".jpg", ".webp"]

  test "dots and whitespace are trimmed together":
    check parseExtensions(" .PNG ,\t.Jpg ") == @[".png", ".jpg"]

  test "trailing dot is dropped":
    check parseExtensions("png.") == @[".png"]

  test "empty entries are skipped":
    check parseExtensions("png,,jpg,") == @[".png", ".jpg"]
    check parseExtensions("").len == 0

suite "findWalls":
  setup:
    let tmp = createTempDir("swaywall_unit_", "")

  teardown:
    removeDir(tmp)

  test "finds files with a listed extension":
    touch(tmp / "a.png")
    touch(tmp / "b.jpg")
    check findWalls(tmp, @[".png", ".jpg"]).sorted == @[tmp / "a.png", tmp / "b.jpg"]

  test "only returns the extensions asked for":
    touch(tmp / "a.png")
    touch(tmp / "b.jpg")
    check findWalls(tmp, @[".jpg"]) == @[tmp / "b.jpg"]

  test "ignores irrelevant extensions and files without one":
    touch(tmp / "notes.txt")
    touch(tmp / "png")
    touch(tmp / "archive.png.bak")
    check findWalls(tmp, @[".png"]).len == 0

  test "recurses into nested directories":
    touch(tmp / "top.png")
    touch(tmp / "a" / "mid.png")
    touch(tmp / "a" / "b" / "c" / "deep.png")
    check findWalls(tmp, @[".png"]).sorted ==
      @[tmp / "a" / "b" / "c" / "deep.png", tmp / "a" / "mid.png", tmp / "top.png"]

  test "handles names containing several dots":
    touch(tmp / "my.wall.final.PNG")
    check findWalls(tmp, @[".png"]) == @[tmp / "my.wall.final.PNG"]

  test "does not yield directories":
    touch(tmp / "directory.png" / "file.txt")
    check findWalls(tmp, @[".png"]).len == 0

  test "returns nothing for empty or missing directory":
    check findWalls(tmp, @[".png"]).len == 0
    check findWalls(tmp / "does-not-exist", @[".png"]).len == 0

  test "includes symlinks that point at image files":
    touch(tmp / "real" / "a.png")
    createSymlink(tmp / "real" / "a.png", tmp / "link.png")
    check findWalls(tmp, @[".png"]).sorted == @[
      tmp / "link.png", tmp / "real" / "a.png"
    ]

  test "does not follow symlinked directories":
    touch(tmp / "real" / "a.png")
    createSymlink(tmp / "real", tmp / "dirlink")
    check findWalls(tmp, @[".png"]) == @[tmp / "real" / "a.png"]

suite "getHistory":
  setup:
    let
      tmp = createTempDir("swaywall_unit_", "")
      histFile = tmp / "hist"

  teardown:
    removeDir(tmp)

  test "returns nothing when the history file does not exist":
    check getHistory(histFile).len == 0

  test "returns nothing for an empty history file":
    writeFile(histFile, "")
    check getHistory(histFile).len == 0

  test "returns existing wallpapers in file order":
    touch(tmp / "a.png")
    touch(tmp / "b.png")
    touch(tmp / "c.png")
    writeFile(histFile, [tmp / "c.png", tmp / "a.png", tmp / "b.png"].join("\n"))
    check getHistory(histFile) == @[tmp / "c.png", tmp / "a.png", tmp / "b.png"]

  test "drops entries whose file no longer exists":
    touch(tmp / "keep.png")
    writeFile(histFile, [tmp / "gone.png", tmp / "keep.png"].join("\n"))
    check getHistory(histFile) == @[tmp / "keep.png"]

  test "trims whitespace, tolerates CRLF and skips blank lines":
    touch(tmp / "a.png")
    touch(tmp / "b.png")
    writeFile(histFile, "  " & tmp / "a.png" & "  \r\n\r\n\n" & tmp / "b.png" & "\r\n")
    check getHistory(histFile) == @[tmp / "a.png", tmp / "b.png"]

  test "supports paths containing spaces":
    touch(tmp / "my walls" / "sunset view.png")
    writeFile(histFile, tmp / "my walls" / "sunset view.png")
    check getHistory(histFile) == @[tmp / "my walls" / "sunset view.png"]

suite "updateHistory":
  let walls = @["/w/a.png", "/w/b.png", "/w/c.png", "/w/d.png"]

  test "first run picks one wallpaper from the directory":
    for _ in 1 .. 50:
      let h = updateHistory(walls, @[])
      check h.len == 1
      check h[0] in walls

  test "fresh pick goes first, followed by the earlier history in order":
    let history = @["/w/c.png", "/w/a.png"]
    for _ in 1 .. 50:
      let h = updateHistory(walls, history)
      check h.len == 3
      check h[0] in ["/w/b.png", "/w/d.png"] # never a wallpaper already shown
      check h[1 ..^ 1] == history

  test "only the unseen wallpaper can be picked when one remains":
    let history = @["/w/d.png", "/w/c.png", "/w/b.png"]
    check updateHistory(walls, history) ==
      @["/w/a.png", "/w/d.png", "/w/c.png", "/w/b.png"]

  test "history entries no longer in the directory are ignored":
    let h = updateHistory(@["/w/a.png", "/w/b.png"], @["/w/gone.png", "/w/a.png"])
    check h == @["/w/b.png", "/w/a.png"]

  test "a completed cycle starts over with a single, different wallpaper":
    let history = @["/w/c.png", "/w/d.png", "/w/a.png", "/w/b.png"] # c is current
    for _ in 1 .. 100:
      let h = updateHistory(walls, history)
      check h.len == 1
      check h[0] != "/w/c.png"
      check h[0] in walls

  test "the 'current' wallpaper is the newest entry still in the directory":
    # /w/x.png was just deleted, so /w/c.png is the one to avoid repeating
    let history = @["/w/x.png", "/w/c.png", "/w/d.png", "/w/a.png", "/w/b.png"]
    for _ in 1 .. 100:
      check updateHistory(walls, history)[0] != "/w/c.png"

  test "two wallpapers strictly alternate":
    let two = @["/w/a.png", "/w/b.png"]
    check updateHistory(two, @["/w/b.png", "/w/a.png"]) == @["/w/a.png"]
    check updateHistory(two, @["/w/a.png", "/w/b.png"]) == @["/w/b.png"]

  test "a single wallpaper is reused (there is nothing else to pick)":
    let one = @["/w/a.png"]
    check updateHistory(one, @[]) == @["/w/a.png"]
    check updateHistory(one, @["/w/a.png"]) == @["/w/a.png"]

  test "simulated runs show every wallpaper once per cycle, never twice in a row":
    let pool = @["a", "b", "c", "d", "e"]
    const cycles = 5
    var
      history: seq[string]
      picks: seq[string]
    for _ in 1 .. pool.len * cycles:
      history = updateHistory(pool, history)
      picks.add(history[0])

    for c in 0 ..< cycles:
      let chunk = picks[c * pool.len ..< (c + 1) * pool.len]
      check chunk.sorted == pool.sorted
    for i in 1 ..< picks.len:
      check picks[i] != picks[i - 1]

  test "every wallpaper is reachable as the first pick":
    var seenFirst: seq[string]
    for _ in 1 .. 100:
      let pick = updateHistory(walls, @[])[0]
      if pick notin seenFirst:
        seenFirst.add(pick)
    check seenFirst.sorted == walls.sorted

suite "argument parsing":
  test "defaults":
    var parser = buildParser()
    let opts = parser.parse(@["/some/dir"])
    check opts.dir == "/some/dir"
    check opts.backend == "swaymsg"
    check opts.extensions == "png,jpg,jpeg"
    check not opts.restore

  test "all options, short form":
    var parser = buildParser()
    let opts = parser.parse(@["-r", "-b", "awww", "-e", "gif,webp", "/walls"])
    check opts.restore
    check opts.backend == "awww"
    check opts.extensions == "gif,webp"
    check opts.dir == "/walls"

  test "all options, long form":
    var parser = buildParser()
    let opts =
      parser.parse(@["--restore", "--backend", "awww", "--extensions", "gif", "/walls"])
    check opts.restore
    check opts.backend == "awww"
    check opts.extensions == "gif"

  test "options may follow the directory":
    var parser = buildParser()
    let opts = parser.parse(@["/walls", "-b", "awww"])
    check opts.dir == "/walls"
    check opts.backend == "awww"

  test "the directory is required":
    var parser = buildParser()
    expect UsageError:
      discard parser.parse(@[])

  test "unknown backends are rejected":
    var parser = buildParser()
    expect UsageError:
      discard parser.parse(@["-b", "feh", "/walls"])

  test "unknown flags are rejected":
    var parser = buildParser()
    expect UsageError:
      discard parser.parse(@["--bogus", "/walls"])

  test "an option without a value is rejected":
    var parser = buildParser()
    expect UsageError:
      discard parser.parse(@["/walls", "-b"])
