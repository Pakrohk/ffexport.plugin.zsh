# ffexport — zsh plugin & CLI for repeatable FFmpeg exports

> Lightweight, zsh-native video export manager — profile-driven FFmpeg exports, persistent zsh completion, profile import/export, and safe defaults for Instagram & YouTube workflows.

---

## Table of contents
1. [What is ffexport?](#what-is-ffexport)
2. [Key features](#key-features)
3. [Requirements](#requirements)
4. [Install (quick)](#install-quick)
5. [Usage examples](#usage-examples)
6. [profiles.toml — schema & examples](#profilestoml---schema--examples)
7. [Import / Export profiles](#import--export-profiles)
8. [How it handles Instagram quality issues (practical tips)](#how-it-handles-instagram-quality-issues-practical-tips)
9. [Troubleshooting](#troubleshooting)
10. [Development & contributing](#development--contributing)
11. [Automated tests & manual test plan](#automated-tests--manual-test-plan)
12. [License](#license)

---

## What is ffexport?

`ffexport` is a small CLI tool packaged as a zsh plugin (znap-friendly) that wraps `ffmpeg` to create repeatable, production-ready exports for multiple platforms.
Define your export targets in a human-editable `profiles.toml` (defaults + per-platform overrides), and run:

    ffexport -p Instagram.Reel -i /path/to/clip.MOV

Outputs are produced next to the source file by default (or in a custom output directory). The project includes:

- A zsh plugin bootstrap so `ffexport` is available in your `PATH` when loaded by `znap`.
- Persistent tab-completion for `-p` (profile names) and common flags.
- Import/export of profiles (merge with backup and optional git commit when the plugin is in a git repo).
- HDR→SDR tone-mapping profiles and `-maxrate`/`-bufsize` presets to avoid Instagram-induced quality collapse.

---

## Key features

- Profile-driven exports using a single `profiles.toml`.
- zsh plugin that places `ffexport` in `PATH` and registers `_ffexport` completion under `fpath`.
- Built-in professional presets for Instagram (Post / Reel / ReelPro) and YouTube (H.264 and VP9) — editable.
- Stable VBR options (`-maxrate`/`-bufsize`) to reduce destructive platform re-encodes.
- Profile `--export` and `--import` (merge) with automatic backups and optional git commit.
- Minimal runtime dependencies: `ffmpeg` and `python3` (uses `tomllib` on Python 3.11+; fallback support possible).
- Simple CLI flags for quality, extra ffmpeg args, custom output names/dirs.

---

## Requirements

- `ffmpeg` (latest stable recommended).
- `python3` (3.11+ recommended so `tomllib` is available). If you run an older Python, you can install `tomli`/`tomli_w` and use the fallback patch.
- (optional) `notify-send` for desktop notifications.
- `zsh` with `znap` (recommended) or manual shell activation.
- `git` (optional; used by import to commit merged profiles when plugin lives inside a repo).
- `gh` (optional; for automated repo creation if you want to publish the plugin).

---

## Install (quick)

### Install via `znap` (recommended)

Add this to your `~/.zshrc`:

    znap source YOUR_GITHUB_USER/ffexport-zsh-plugin

Then reload your shell:

    source ~/.zshrc

`znap` will clone the repo, source `ffexport.plugin.zsh`, add `bin/` to your `PATH`, and register the completion.

### Manual install

    git clone https://github.com/YOUR_GITHUB_USER/ffexport-zsh-plugin.git ~/.local/share/ffexport
    # Add to PATH and fpath in your ~/.zshrc:
    export PATH="$HOME/.local/share/ffexport/bin:$PATH"
    fpath=("$HOME/.local/share/ffexport/completion" $fpath)
    autoload -Uz compinit && compinit

Make sure `~/.local/share/ffexport/bin/ffexport` is executable:

    chmod +x ~/.local/share/ffexport/bin/ffexport

---

## Usage examples

List available profiles (reads from `profiles.toml`):

    ffexport --list-profiles
    # e.g.
    # Instagram.Post
    # Instagram.Reel
    # Instagram.ReelPro
    # YouTube.Post
    # YouTube.Post_VP9
    # YouTube.Short
    # Custom

Export a Reel (default: output next to input):

    ffexport -p Instagram.Reel -i ~/Videos/clip.MOV

Export with a quality hint (low|medium|high):

    ffexport -p YouTube.Post -i movie.mov -q medium

Export to a custom output directory and name:

    ffexport -p Instagram.Post -i clip.mov -n "teaser_v1" -d ~/exports

Append extra ffmpeg args (raw string):

    ffexport -p Instagram.Reel -i clip.MOV -x "-tune film -threads 8"

Export a single profile to a standalone TOML (shareable):

    ffexport --export-profile Instagram.Reel --out /tmp/reel_profile.toml

Merge/import a TOML of profiles into your plugin's `profiles.toml` (backup + optional git commit):

    ffexport --import-profile /path/to/other_profiles.toml

---

## profiles.toml — schema & examples

`profiles.toml` lives next to the plugin by default, or set `FFEXPORT_PROFILES=/path/to/your.toml` to override.

High-level structure:

    [defaults]
    container = "mp4"
    video_codec = "libx264"
    audio_codec = "aac"
    pixel_format = "yuv420p"
    audio_bitrate = "128k"
    audio_sample_rate = 44100
    audio_channels = 2
    preset = "medium"
    crf = 18
    video_bitrate = ""   # empty = use CRF (quality-based)
    fps = 30
    extra_args = "-movflags +faststart"

    [platforms.Instagram.Reel]
    name = "Insta_Reel"
    container = "mp4"
    video_codec = "libx264"
    audio_codec = "aac"
    video_bitrate = "12000k"
    preset = "slow"
    fps = 30
    resolution = "1080:1920"
    pixel_format = "yuv420p"
    audio_bitrate = "128k"
    filters = "eq=gamma=1.08:saturation=1.10"
    extra_args = "-movflags +faststart -maxrate 6000k -bufsize 12000k -profile:v high -level 4.1"

### Important keys

- `container` — mp4, webm, mov, etc.
- `video_codec` — libx264, libx265, libvpx-vp9, etc.
- `audio_codec` — aac, libopus, etc.
- `video_bitrate` — use `12000k` or leave empty to use `crf`.
- `crf` — constant rate factor for x264/x265 (lower = better quality).
- `resolution` — `width:height` (e.g. `1080:1920`). Use `"keep"` to skip scaling.
- `filters` — ffmpeg filter chain (string). Example: `zscale=t=linear,tonemap=hable,eq=gamma=1.06:saturation=1.1`
- `extra_args` — raw ffmpeg args appended to the command (careful with quoting).
- `fps` — output framerate.
- `max_duration`, `max_file_size` — informational checks (not enforced automatically by default).

---

## Import / Export profiles

### Export a profile

Creates a small TOML containing the selected profile and defaults. Useful for sharing:

    ffexport --export-profile Instagram.Reel --out ~/reel-profile.toml

### Import / Merge a TOML file

Merges `defaults` and `platforms` from the imported TOML into the plugin `profiles.toml`. A backup of the original `profiles.toml` is created before the merge. If the repository containing `profiles.toml` is a git repo, `ffexport` will attempt to `git add` and `git commit` the new file.

    ffexport --import-profile /path/to/incoming_profiles.toml

If you do not want profiles in the plugin altered, copy the shipped `profiles.toml` to a writable location and set:

    export FFEXPORT_PROFILES=~/myprofiles.toml

then run `ffexport --import-profile ...` against your writable copy.

---

## How it handles Instagram quality issues (practical tips)

You reported — correctly — that IG sometimes shows high quality for the first few seconds then the rest looks bad. This often happens when an extreme VBR spike early in the file causes the platform encoder to aggressively downscale later fames.

Mitigation strategies used in the profiles:

- **Constrain VBR spikes**: add `-maxrate` and `-bufsize` values derived from `video_bitrate` (e.g. `-maxrate 6000k -bufsize 12000k`). This produces a steadier stream and reduces the chance of destructive re-encode.
- **Use `-profile:v high -level 4.1/4.2`**: increases decoder-compatibility and avoids progressive quality penalties.
- **Tone-mapping for HDR sources**: for iPhone Dolby Vision/HDR sources, use a `ReelPro` profile that does `zscale` → `tonemap=hable` → color tweaks, preventing blown highlights and “washed-out” skin tones after SDR conversion.
- **Avoid excessive CRF for uploads**: for platform uploads where bitrate control matters, prefer a constrained bitrate mode rather than unconstrained CRF.

If you want an automated HDR detector that toggles tone-mapping, say so — I can add a small autotune step that checks the input for HDR metadata and picks the `*-Pro` profile or injects a tonemap filter.

---

## Troubleshooting

### Common issues

- **`python3` complains about `tomllib` missing`**
  - You are likely on Python <3.11. Options:
    - Install Python 3.11 or later.
    - Install `tomli` and `tomli_w` and ask for the fallback patch (I can provide it quickly).

- **No completion after installing plugin**
  - Ensure `compinit` has run and the znap-sourced plugin has been loaded.
  - Clear zsh compcache:

      rm -f "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompcache" 2>/dev/null || true
      autoload -Uz compinit && compinit

  - If `ffexport` is not in `PATH`, either symlink `bin/ffexport` into `~/bin` or set `FFEXPORT_PROFILES` to point to your profiles file and ensure `ffexport` is callable.

- **Import fails due to permissions**
  - Make sure `profiles.toml` is writable; otherwise set `FFEXPORT_PROFILES` to a writable path and import there.

- **ffmpeg errors on filter chains (e.g. zscale not found)**
  - Ensure your ffmpeg build includes the needed libs (libzimg, libplacebo, etc.). On Arch you usually have full-featured ffmpeg; otherwise install a build that includes zscale or remove HDR tone-mapping filters for fallback.

---

## Development & contributing

Contributions are welcome. Suggested workflow:

1. Fork repo, create a feature branch (`feat/your-feature`).
2. Add tests / examples and make sure `bin/ffexport` remains POSIX-friendly and well-documented.
3. Open a pull request describing the problem and the change. Include sample video test cases for encoding-related changes if possible.

Suggested issues to help with:

- Add a Python fallback for tomllib (`tomli`) for older Python versions.
- Add an automated HDR detection step that injects tone-mapping filters.
- Add a GUI helper (TUI) to pick profiles & preview filters before export.
- Improve unit-testing of command construction (mock ffmpeg).

### Suggested branch policy & commit style

- Use conventional commits (feat/fix/docs/chore).
- Keep changes small and include a README update for new profile keys.
- When importing profiles, include an automated test case demonstrating the merge behavior.

---

## Automated tests & manual test plan

_No CI included by default_ — recommended test steps for changes to encoding logic:

- **Functional tests (manual)**:
  - Run `ffexport --list-profiles` — it should print one profile per line.
  - Export a 10s clip with `Instagram.Reel` and verify no crash.
  - Export an HDR clip with `Instagram.ReelPro` and check highlights & skin tones in SDR playback.
  - Export `YouTube.Post_VP9` and confirm `webm` output and that `ffmpeg` runs without errors.

- **Regression check**:
  - Compare durations and basic format fields for input vs output using `ffprobe`.
  - Verify file sizes are within expected ranges given bitrate/CRF.

If you want, I can provide a small test harness script that runs a baked-in short sample clip through every profile (requires you to place a small test input file in the repo). Would you like that?

---

## License

MIT License — short & permissive. Put a `LICENSE` file in the repository:

    MIT License

    Copyright (c) 2025 YOUR_NAME

    Permission is hereby granted...

(Replace `YOUR_NAME` with your GitHub username or organization.)

---

## Final notes & recommended next steps

1. Replace `YOUR_GITHUB_USER` with your GitHub handle and publish the repo.
2. Consider adding CI that verifies `python3` command builds a valid ffmpeg command string (unit test construction).
3. If you want HDR auto-detect + auto tone-map, I can add it quickly: it will inspect `ffprobe` metadata and choose a `*-Pro` profile or inject `zscale`+`tonemap` filters.

---

If you want, I’ll now:
- produce the `LICENSE` file (MIT) ready to paste, and
- generate the one-shot `create_repo.sh` script that creates local files, initializes git, and pushes to `gh` for you (requires `gh` CLI).

Which one should I generate first?
