# ffexport

A zsh plugin that wraps ffmpeg for consistent video exports across platforms. I got tired of manually tweaking ffmpeg flags every time I needed to export something for Instagram or YouTube, so I built this.

## What it does

You define your export presets once in `profiles.toml`, then run:

```bash
ffexport -p Instagram.Reel -i video.mov
```

That's it. The output lands next to your source file with all the right settings baked in.

## Why I made this

Instagram kept destroying my video quality after upload—first few seconds looked fine, then everything went to hell. Turns out you need specific bitrate constraints and tone-mapping for HDR footage. This tool handles that automatically with profiles like `Instagram.ReelPro`.

Also, I was copy-pasting the same ffmpeg commands constantly. Now I just tab-complete profile names.

## Installation

**Using znap** (easiest):

```zsh
# Add to ~/.zshrc
znap source Pakrohk/ffexport.plugin.zsh
```

**Manual**:

```bash
git clone https://github.com/Pakrohk/ffexport.plugin.zsh ~/.local/share/ffexport

# Add to ~/.zshrc:
export PATH="$HOME/.local/share/ffexport/bin:$PATH"
fpath=("$HOME/.local/share/ffexport/completion" $fpath)
autoload -Uz compinit && compinit
```

## Quick examples

```bash
# List what's available
ffexport --list-profiles

# Export a reel
ffexport -p Instagram.Reel -i clip.mov

# Custom quality
ffexport -p YouTube.Post -i video.mov -q high

# Custom output location
ffexport -p Instagram.Post -i clip.mov -n "final_v2" -d ~/exports

# Pass raw ffmpeg flags
ffexport -p Instagram.Reel -i clip.mov -x "-tune film"
```

## Built-in profiles

Ships with sensible defaults for:
- Instagram (Post, Reel, ReelPro with HDR tone-mapping)
- YouTube (H.264 and VP9 variants)

You can tweak them or add your own in `profiles.toml`.

## How profiles work

Each profile is just a collection of ffmpeg settings. Example:

```toml
[platforms.Instagram.Reel]
name = "Insta_Reel"
container = "mp4"
video_codec = "libx264"
video_bitrate = "12000k"
resolution = "1080:1920"
extra_args = "-movflags +faststart -maxrate 6000k -bufsize 12000k"
```

The `extra_args` is where the Instagram quality magic happens—it constrains bitrate spikes so the platform doesn't aggressively re-encode your video.

## Sharing profiles

Export a profile to share with others:

```bash
ffexport --export-profile Instagram.Reel --out reel-settings.toml
```

Import someone else's profiles:

```bash
ffexport --import-profile downloaded-profiles.toml
```

It backs up your existing profiles before merging and can auto-commit if you're in a git repo.

## Requirements

- `ffmpeg` (any recent version)
- `python3` (3.11+ preferred, but works with 3.9+ if you install `tomli`)
- `zsh`

Optional: `notify-send` for desktop notifications, `gh` if you want to publish your own fork.

## Common issues

**Completion not working?**
Clear your zsh cache: `rm ~/.zcompdump && compinit`

**Python complains about tomllib?**
You're on Python < 3.11. Either upgrade or `pip install tomli tomli_w`.

**Instagram still looks bad?**
Try the `ReelPro` profile—it includes HDR-to-SDR tone-mapping. If your source is iPhone footage with Dolby Vision, this usually fixes washed-out colors.

## Contributing

PRs welcome. I'm particularly interested in:
- Auto-detecting HDR and applying tone-mapping automatically
- Better error messages when ffmpeg fails
- A simple TUI for picking profiles

Use conventional commits (fix/feat/docs) and keep changes focused.

## License

MIT. Do whatever you want with it.

---

Made this because I export a lot of vertical video and got sick of Instagram ruining it. Hope it helps you too.
