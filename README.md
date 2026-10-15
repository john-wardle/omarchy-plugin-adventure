# Adventure for Omarchy

A keyboard-first, AI-powered text adventure for Omarchy. Begin in any place and time, explore a living world, talk with memorable characters, uncover clues, and shape the story through your choices.

Adventure runs fully locally through Ollama. No OpenAI account, API key, internet connection, or cloud billing is required while playing.

![Adventure gameplay preview](preview.png)

## Exploration

Every new adventure opens in a broad named region with at least three meaningful routes. As you travel, the game reveals connected settlements, wilderness, landmarks, and other named locations; the map records routes you have discovered. Ordinary scenes keep at least two ways forward, while true endings and temporary defeats are the only intentional exceptions.

## What you need

- Omarchy 4.0 (Quattro) with Quickshell plugin support.
- Ollama running locally with the `qwen2.5:3b` model available.

For example, install and prepare the model with:

```bash
ollama pull qwen2.5:3b
```

## Install

Install from the Adventure repository:

```bash
omarchy plugin add https://github.com/kszx11/omarchy-plugin-adv.git --enable
```

Omarchy will warn that plugins run unsandboxed; install only repositories you trust. When prompted, choose where Adventure should appear in the bar. Click its icon to open the game.

You can also open Adventure from a terminal:

```bash
omarchy-shell shell summon io.github.kszx11.adventure '{}'
```

## Start playing

1. Open Adventure from its bar icon.
2. Make sure Ollama is running locally and the `qwen2.5:3b` model is available.
3. Describe the place and time for your adventure, then select **New game**.
4. Use the numbered choices or type commands such as `look`, `go to <place>`, `talk to <person>`, or `examine <thing>`.

Adventure sends requests only to Ollama at `127.0.0.1:11434`; no credentials or gameplay data leave your computer.

## Updating

```bash
omarchy plugin update io.github.kszx11.adventure
```

## Remove

```bash
omarchy plugin remove io.github.kszx11.adventure
```

Removing the plugin keeps your saved adventures. If you also want to erase them, delete the `~/.local/state/omarchy-adventure/` directory.
