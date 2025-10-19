# ffexport.plugin.zsh - plugin bootstrap for znap / manual install
# Determines package dir and adds bin -> PATH and completion dir -> fpath then compinit.

# detect this script location robustly in zsh
__ffexport_pkg_dir="$(builtin dirname -- "${(%):-%x}")"

# add bin to PATH (so 'ffexport' available)
if [[ -d "$__ffexport_pkg_dir/bin" ]]; then
  path=("$__ffexport_pkg_dir/bin" $path)
fi

# add completion directory to fpath so compinit can find _ffexport
if [[ -d "$__ffexport_pkg_dir/completion" ]]; then
  fpath=("$__ffexport_pkg_dir/completion" $fpath)
fi

# ensure compinit loaded (user likely has it in dotfile, but safe to call)
autoload -Uz compinit
# avoid running compinit twice in case of multiple plugin loads
if ! zstyle -t :compinstall:verbose >/dev/null 2>&1; then
  compinit -u >/dev/null 2>&1 || true
else
  compinit >/dev/null 2>&1 || true
fi

# register completion explicitly (so it's available immediately)
if (( $+commands[ffexport] )); then
  # compdef will attach _ffexport from fpath
  compdef _ffexport ffexport ffexport.sh >/dev/null 2>&1 || true
fi

# optional: export location of profiles file to override
export FFEXPORT_PROFILES="${__ffexport_pkg_dir}/profiles.toml"

# convenience wrappers
ffexport-export-profile() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: ffexport-export-profile <Profile> <out.toml>"
    return 2
  fi
  ffexport --export-profile "$1" --out "$2"
}

ffexport-import-profile() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: ffexport-import-profile <file.toml>"
    return 2
  fi
  ffexport --import-profile "$1"
}
