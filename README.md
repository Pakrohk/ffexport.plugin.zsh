# ffexport: Your Smart FFmpeg Wrapper

**ffexport** is a powerful Zsh plugin that simplifies your video exporting workflow. It wraps the complexity of `ffmpeg` in a user-friendly command-line tool, allowing you to use predefined, high-quality export profiles for platforms like Instagram and YouTube.

Stop memorizing `ffmpeg` flags and start exporting videos consistently and efficiently.

---

## Key Features

| Feature                 | Description                                                                                                                                                             | Logic Behind It                                                                                                                                                               |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Profile-Based Exporting** | Use simple names like `Instagram.Reel` to apply a complex set of `ffmpeg` settings.                                                                                       | Ensures **consistency** and **quality** across all your exports. The profiles are fine-tuned to meet the specific requirements of each platform, preventing quality degradation. |
| **Create Profile from URL** | Automatically generate a new export profile from a video URL (e.g., YouTube, Instagram, TikTok).                                                                         | Uses `yt-dlp` to extract the source video's metadata (resolution, bitrate, codec), allowing you to **perfectly match** the properties of any online video.                    |
| **Easy Profile Management** | Import and export profiles in the simple `.toml` format. Share your settings with others or back up your favorite configurations.                                            | Profiles are stored in a human-readable `profiles.toml` file, making them easy to edit, share, and version-control with Git.                                               |
| **Smart & Fast**            | Optimized for performance and designed to integrate seamlessly with modern Zsh setups, especially with **Znap**.                                                        | By leveraging a fast plugin manager and a combination of efficient shell scripting and Python, the tool remains lightweight and responsive.                                     |

---

## Why Use Znap?

While `ffexport` can be installed manually, we strongly recommend using [Znap](https://github.com/marlonrichert/zsh-snap) for the best experience.

- **Speed:** `znap` is incredibly fast. It loads plugins asynchronously and caches compiled scripts, which significantly reduces your shell's startup time.
- **Simplicity:** No need to manually manage your `$PATH` or `$fpath`. `znap` handles everything automatically.
- **Easy Updates:** Update all your plugins with a single command: `znap pull`.

---

## Prerequisites

Before you begin, ensure you have the following dependencies installed.

| Dependency | Purpose                                          |
| ---------- | ------------------------------------------------ |
| `git`      | For cloning the plugin repository.               |
| `python3`  | For parsing `profiles.toml` and creating profiles. |
| `ffmpeg`   | The core engine for video encoding.              |
| `yt-dlp`   | For the "Create Profile from URL" feature.       |
| `jq`       | For robustly handling JSON from `yt-dlp`.          |

You will also need `pip` (Python's package installer) to install some Python libraries.

---

## Installation

### 1. Install System Dependencies

First, install the required packages for your Linux distribution.

<details>
<summary><strong> Arch Linux </strong></summary>

```bash
sudo pacman -Syu git python ffmpeg yt-dlp jq
```
</details>

<details>
<summary><strong> Fedora </strong></summary>

First, enable the RPM Fusion repository, which provides `ffmpeg`:
```bash
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```
Then, install the packages:
```bash
sudo dnf install git python3 ffmpeg yt-dlp jq
```
</details>

<details>
<summary><strong> openSUSE </strong></summary>

First, enable the Packman repository, which provides `ffmpeg`:
```bash
sudo zypper ar -cfp 90 'https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/' packman
sudo zypper dup --from packman --allow-vendor-change
```
Then, install the packages:
```bash
sudo zypper install git-core python3 ffmpeg yt-dlp jq
```
</details>

<details>
<summary><strong> Alpine Linux </strong></summary>

```bash
sudo apk add git python3 ffmpeg yt-dlp jq
```
</details>

### 2. Install Python Dependencies

Next, install the required Python libraries using `pip`.

```bash
pip install tomli-w
```
*Note: `tomli-w` is used for writing profile data back to your `profiles.toml` file.*

### 3. Install the Plugin

**Recommended Method: Using Znap**

Add the following line to your `~/.zshrc` file:

```zsh
znap source Pakrohk/ffexport
```
Then, restart your shell. That's it! `znap` will handle the rest.

**Manual Method**

If you prefer not to use a plugin manager, you can install it manually.

1.  Clone the repository:
    ```bash
    git clone https://github.com/Pakrohk/ffexport.plugin.zsh ~/.local/share/zsh/ffexport
    ```

2.  Add the following lines to your `~/.zshrc` file:
    ```zsh
    fpath+=~/.local/share/zsh/ffexport/completion
    path=(~/.local/share/zsh/ffexport/bin $path)
    ```

3.  Restart your shell or run `source ~/.zshrc`.

---

## How to Use

### Basic Export

The core feature is simple. Provide a profile (`-p`) and an input file (`-i`).

```bash
# Export a video for an Instagram Reel
ffexport -p Instagram.Reel -i my_video.mov
```

### Creating a Profile from a URL

Generate a new profile by pointing to an online video. You must give the new profile a name (`--name`).

```bash
# Create a profile named 'MyProject.Reference' from a YouTube video
ffexport --create-profile-from-url "https://youtu.be/some_video" --name MyProject.Reference
```
This will add a new `[platforms.MyProject.Reference]` section to your `profiles.toml` file.

### Other Examples

```bash
# List all available profiles
ffexport --list-profiles

# Export with a custom quality setting
ffexport -p YouTube.Post -i video.mov -q high

# Specify a different output directory and filename
ffexport -p Instagram.Post -i clip.mov -n "final_v2" -d ~/exports

# Pass raw, additional flags directly to ffmpeg
ffexport -p Instagram.Reel -i clip.mov -x "-tune film"
```

---

## License

This project is licensed under the **MIT License**. See the `LICENSE` file for details.
