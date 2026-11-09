# Changelog

## [1.0.3](https://github.com/cycneuramus/swaywall/compare/v1.0.2...v1.0.3) (2026-11-09)


### Bug Fixes

* Don't break paths with spaces on swaymsg ([861c5be](https://github.com/cycneuramus/swaywall/commit/861c5be4e5c947643ce1f48657118521050c5bf5))

## [1.0.2](https://github.com/cycneuramus/swaywall/compare/v1.0.1...v1.0.2) (2026-11-07)


### Performance Improvements

* Run backend without a shell ([2830fa2](https://github.com/cycneuramus/swaywall/commit/2830fa2ad8925c247a5b14fa2f399cbdf22879b3))
* Use hashsets to increase lookup performance dramatically ([a65b1e8](https://github.com/cycneuramus/swaywall/commit/a65b1e8837040d42b5b1c40af388c8e839c80ecf))

## [1.0.1](https://github.com/cycneuramus/swaywall/compare/v1.0.0...v1.0.1) (2026-11-06)


### Bug Fixes

* Follow symlinked directories ([dcc7912](https://github.com/cycneuramus/swaywall/commit/dcc7912d0fc837fee8126b8894fda0b97a358899))
* Handle error in --restore as in the normal path ([528141b](https://github.com/cycneuramus/swaywall/commit/528141b7745d6e667041923cb9cccfb712917858))
* More robust extension parsing ([e9a8a33](https://github.com/cycneuramus/swaywall/commit/e9a8a33c8bb49256f4a63fba9182463a3ac327c6))
* Normalize wall dir path ([c282084](https://github.com/cycneuramus/swaywall/commit/c28208441967d361da32708c68ce0d09da333831))

## [1.0.0](https://github.com/cycneuramus/swaywall/compare/v0.3.1...v1.0.0) (2026-11-04)


### ⚠ BREAKING CHANGES

* Complete rewrite in Nim

### Features

* Complete rewrite in Nim ([87009d7](https://github.com/cycneuramus/swaywall/commit/87009d7528c58ae2b634a269285ee40d6312f0ca))
* Start new history on completed wall cycle to avoid predictable ordering ([87009d7](https://github.com/cycneuramus/swaywall/commit/87009d7528c58ae2b634a269285ee40d6312f0ca))


### Bug Fixes

* Normalize file extension case ([87009d7](https://github.com/cycneuramus/swaywall/commit/87009d7528c58ae2b634a269285ee40d6312f0ca))
* Use absolute path for wallpaper directory ([87009d7](https://github.com/cycneuramus/swaywall/commit/87009d7528c58ae2b634a269285ee40d6312f0ca))

## [0.3.1](https://github.com/cycneuramus/swaywall/compare/v0.3.0...v0.3.1) (2026-03-27)


### Bug Fixes

* Accommodate swww –&gt; awww project rename ([6340f2a](https://github.com/cycneuramus/swaywall/commit/6340f2a8732e149cbfa3f776b49fa022212efb66))


### Documentation

* Update README ([02ca6fc](https://github.com/cycneuramus/swaywall/commit/02ca6fc77550d765c98c5c01254d8e44668e65d4))

## [0.3.0](https://github.com/cycneuramus/swaywall/compare/v0.2.1...v0.3.0) (2025-06-17)


### Features

* Support swww as wallpaper method ([9a04a26](https://github.com/cycneuramus/swaywall/commit/9a04a26d167d0ea9eee1333161919125ad206b49))

## [0.2.1](https://github.com/cycneuramus/swaywall/compare/v0.2.0...v0.2.1) (2025-04-07)


### Bug Fixes

* Type related improvements ([ebdfc2c](https://github.com/cycneuramus/swaywall/commit/ebdfc2c19e68a02f6b6daa587f39cf79bec21036))

## [0.2.0](https://github.com/cycneuramus/swaywall/compare/v0.1.1...v0.2.0) (2025-02-26)


### Features

* Add CLI flag for image extensions ([5849e6d](https://github.com/cycneuramus/swaywall/commit/5849e6d9481912745c612bf7793707f09592a1e0))
* Automatically prune non-existing files from history ([7b25e02](https://github.com/cycneuramus/swaywall/commit/7b25e0269808a90aeacbde9c144398d5116eac18))
* Support wallpapers organized in subdirectories ([8d5cc26](https://github.com/cycneuramus/swaywall/commit/8d5cc2605c53ded2e08b4641b851e1b17c1d6eb6))


### Bug Fixes

* Prevent trying to restore non-existing wallpaper ([bb924d3](https://github.com/cycneuramus/swaywall/commit/bb924d32190c07dff34fa045e987231d5365a719))


### Documentation

* Mention default image file extensions ([f998621](https://github.com/cycneuramus/swaywall/commit/f9986218e68ef599d38a552f2307f2e113f1ca01))
* Update README ([9860b47](https://github.com/cycneuramus/swaywall/commit/9860b472c46d5e047a97c4af1a4ceeb5614bc56c))

## [0.1.1](https://github.com/cycneuramus/swaywall/compare/v0.1.0...v0.1.1) (2025-02-26)


### Bug Fixes

* Add script installation ([9dc4373](https://github.com/cycneuramus/swaywall/commit/9dc4373daad477ac67307c727b9c83c835fb7aaa))
* more reliable random pick ([217d4e5](https://github.com/cycneuramus/swaywall/commit/217d4e5a5be896f8bfe1d15f1cdcec87b66e211c))

## 0.1.0 (2025-02-26)

Initial release
