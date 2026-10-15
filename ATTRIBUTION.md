# Attribution

This repository is a derivative distribution of **Adventure for Omarchy** by
`kszx11`.

- Original repository: <https://github.com/kszx11/omarchy-plugin-adv>
- Original author/maintainer: `kszx11`
- Original license: MIT
- Original plugin ID: `io.github.kszx11.adventure` (this derivative uses `io.github.john-wardle.adventure-ollama`)

The original Adventure source, design, manifest identity, and copyright remain
attributed to the original author. This repository does not claim authorship
of that work.

## Changes in this distribution

This distribution adds packaging and local-runtime support around the original
plugin:

- A self-contained `install.sh` installer.
- Ollama installation and service startup checks.
- Automatic installation of the `qwen2.5:3b` model when it is missing.
- Documentation for installing this repository as a complete local package.

The Adventure runtime is configured to send gameplay requests only to the
local Ollama endpoint at `127.0.0.1:11434`. The original `LICENSE` file is
retained and applies to the original work.
