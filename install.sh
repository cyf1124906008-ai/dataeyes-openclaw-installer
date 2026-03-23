#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${DATAEYES_REPO_URL:-https://github.com/dataeyesai/dataeyes-mac-deploy.git}"
BRANCH="${DATAEYES_BRANCH:-main}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}i ${NC}$*"; }
success() { echo -e "${GREEN}OK ${NC}$*"; }
warn()    { echo -e "${YELLOW}! ${NC}$*"; }
error()   { echo -e "${RED}X ${NC}$*"; }

SCRIPT_PATH="${BASH_SOURCE[0]:-}"
SCRIPT_DIR=""
INSTALLER_PATH=""
if [[ -n "$SCRIPT_PATH" && "$SCRIPT_PATH" != "bash" && "$SCRIPT_PATH" != "-bash" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
  INSTALLER_PATH="$SCRIPT_DIR/内部文件/安装主程序.sh"
fi

ensure_git() {
  if command -v git >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

build_github_archive_url() {
  local repo_url="$1"
  local branch="$2"
  local repo_path

  if [[ "$repo_url" =~ ^https://github\.com/([^/]+/[^/]+)(\.git)?$ ]]; then
    repo_path="${BASH_REMATCH[1]%.git}"
    echo "https://codeload.github.com/$repo_path/tar.gz/refs/heads/$branch"
    return 0
  fi

  return 1
}

download_repo_archive() {
  local tmp_dir="$1"
  local archive_url archive_file root_dir

  archive_url="$(build_github_archive_url "$REPO_URL" "$BRANCH")" || return 1
  archive_file="$tmp_dir/repo.tar.gz"

  info "正在下载 GitHub 安装包..." >&2
  curl -fsSL --connect-timeout 30 --retry 3 --retry-delay 2 --max-time 300 \
    "$archive_url" -o "$archive_file" || return 1

  root_dir="$(tar -tzf "$archive_file" | head -n 1 | cut -d/ -f1)"
  [[ -n "$root_dir" ]] || return 1

  tar -xzf "$archive_file" -C "$tmp_dir"
  echo "$tmp_dir/$root_dir"
}

clone_repo_if_needed() {
  local tmp_dir="$1"
  ensure_git || return 1
  info "正在通过 git 下载仓库..." >&2
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$tmp_dir/repo" >/dev/null 2>&1 || return 1
  echo "$tmp_dir/repo"
}

run_local_installer() {
  if [[ ! -f "$INSTALLER_PATH" ]]; then
    error "没有找到安装脚本: $INSTALLER_PATH"
    exit 1
  fi
  bash "$INSTALLER_PATH"
}

run_remote_installer() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  local repo_dir
  if ! repo_dir="$(download_repo_archive "$tmp_dir")"; then
    warn "GitHub 安装包下载失败，尝试回退到 git clone"
    if ! repo_dir="$(clone_repo_if_needed "$tmp_dir")"; then
      error "无法下载仓库: $REPO_URL"
      echo "可尝试以下任一方式后重试："
      echo "1. 检查当前网络是否可访问 GitHub / codeload.github.com"
      echo "2. 安装 git 后再次执行安装命令"
      echo "3. 手动下载仓库后本地执行 bash install.sh"
      [[ "$(uname -s)" == "Darwin" ]] && echo "macOS 安装 git 可先执行: xcode-select --install"
      exit 1
    fi
  fi

  if [[ ! -f "$repo_dir/内部文件/安装主程序.sh" ]]; then
    error "仓库中没有找到 /内部文件/安装主程序.sh"
    exit 1
  fi

  success "下载完成，开始安装"
  bash "$repo_dir/内部文件/安装主程序.sh"
}

main() {
  echo "DataEyes GitHub Installer"
  echo "Repo: $REPO_URL"
  echo ""

  if [[ -n "$INSTALLER_PATH" && -f "$INSTALLER_PATH" ]]; then
    run_local_installer
  else
    run_remote_installer
  fi
}

main "$@"
