#!/usr/bin/env zsh
# Copyright (c) 2025 Pakrohk
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# ffexport.plugin.zsh - Main plugin file
# Compatible with zsh-snap and other plugin managers.

# zsh-snap automatically adds `bin` to $PATH and `completion` to $fpath.
# It also handles compinit, so we don't need to do it here.

# Detect the plugin's installation directory.
# shellcheck disable=SC2296,SC2298
__ffexport_pkg_dir="${${(%):-%x}:A:h}"

# Set the default profiles file location. Can be overridden by the user.
export FFEXPORT_PROFILES="${__ffexport_pkg_dir}/profiles.toml"

# Convenience wrappers for profile management.
ffexport-export-profile() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: ffexport-export-profile <Profile> <out.toml>" >&2
    return 1
  fi
  command ffexport --export-profile "$1" --out "$2"
}

ffexport-import-profile() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: ffexport-import-profile <file.toml>" >&2
    return 1
  fi
  command ffexport --import-profile "$1"
}
