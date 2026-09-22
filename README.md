# The `my-package` Package
<div align="center">Version 0.1.0</div>

A short description about the project and/or client.

## Template adaptation checklist

- [ ] Fill out `README.md`
  - Change the `my-package` package name, including code snippets
  - Check section contents and/or delete sections that don't apply
- [ ] Check and/or replace `LICENSE` by something that suits your needs
- [ ] Fill out `typst.toml`
  - See also the [typst/packages README](https://github.com/typst/packages/?tab=readme-ov-file#package-format)
- [ ] Adapt Repository URLs in `CHANGELOG.md`
  - Consider only committing that file with your first release, or removing the "Initial Release" part in the beginning
- [ ] Adapt or deactivate the release workflow in `.github/workflows/release.yml`
  - to deactivate it, delete that file or remove/comment out lines 2-4 (`on:` and following)
  - to use the workflow
    - [ ] check the values under `env:`, particularly `REGISTRY_FORK`
    - [ ] if you don't have one, [create a fine-grained personal access token](https://github.com/settings/tokens?type=beta) with [only Contents permission](https://stackoverflow.com/a/75116350/371191) for the `REGISTRY_FORK`
    - [ ] on this repo, create a secret `REGISTRY_TOKEN` (at `https://github.com/[user]/[repo]/settings/secrets/actions`) that contains the so created token

    if configured correctly, whenever you create a tag `v...`, your package will be pushed onto a branch on the `REGISTRY_FORK`, from which you can then create a pull request against [typst/packages](https://github.com/typst/packages/)
- [ ] remove/replace the example test case
- [ ] (add your actual code, docs and tests)
- [ ] remove this section from the README

## Getting Started

These instructions will get you a copy of the project up and running on the typst web app. Perhaps a short code example on importing the package and a very simple teaser usage.

```typ
#import "@preview/my-package:0.1.0": *

#show: my-show-rule.with()
#my-func()
```

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./thumbnail-dark.svg">
  <img src="./thumbnail-light.svg">
</picture>

### Installation

A step by step guide that will tell you how to get the development environment up and running. This should explain how to clone the repo and where to (maybe a link to the typst documentation on it), along with any pre-requisite software and installation steps.

```
$ First step
$ Another step
$ Final step
```

## Usage

A more in-depth description of usage. Any template arguments? A complicated example that showcases most if not all of the functions the package provides? This is also an excellent place to signpost the manual.

```typ
#import "@preview/my-package:0.1.0": *

#let my-complicated-example = ...
```

## Additional Documentation and Acknowledgments

* Project folder on server:
* Confluence link:
* Asana board:
* etc...

###

- refactor so it include tugas biasa, skripsi, kp, and other ta fpik
- adapt subfigure

### Local packages

Want to install a package locally on your system without publishing it or
experiment with it before publishing? You can store packages in
`{data-dir}/typst/packages/{namespace}/{name}/{version}` to make them available
locally on your system. Here, `{data-dir}` is

- `$XDG_DATA_HOME` or `~/.local/share` on Linux
- `~/Library/Application Support` on macOS
- `%APPDATA%` on Windows

You may also run `typst info` and check _Package path_ for the actual path. This
would be helpful if you have installed the Typst compiler from Snap or are using
special environment variables.

You can create an arbitrary `{namespace}`. A good namespace for system-local
packages is `local`. Using this namespace:

- Store a package in `{data-dir}/typst/packages/local/mypkg/1.0.0`
- Import from it with `#import "@local/mypkg:1.0.0": *`.

Packages in the data directory have precedence over ones in the cache directory.

Note that future iterations of Typst's package management may change/break this
local setup.