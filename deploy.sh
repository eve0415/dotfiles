#!/usr/bin/env bash
set -euo pipefail

# =========================
# Dotfiles deployer
# =========================
# 設定ファイルをホームディレクトリにコピーで配置します。
# コピー方式なので、デプロイ後にマシン固有のカスタマイズが可能です。
# インタラクティブな選択式UIで、デプロイする設定を選べます。
#
# Usage:
#   ./deploy.sh            # インタラクティブモード（選択式）
#   ./deploy.sh --all      # すべての設定を一括デプロイ
#   ./deploy.sh --check    # 現在の状態を確認（変更なし）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_DIR="${SCRIPT_DIR}/user"
HOME_DIR="${HOME}"

# ---- Colors ----
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
RESET=$'\033[0m'

info()    { printf "${BLUE}[info]${RESET}  %s\n" "$*"; }
success() { printf "${GREEN}[ok]${RESET}    %s\n" "$*"; }
warn()    { printf "${YELLOW}[skip]${RESET}  %s\n" "$*"; }
err()     { printf "${RED}[err]${RESET}   %s\n" "$*"; }

# ---- Mode ----
MODE="interactive"
case "${1:-}" in
  --all)   MODE="all" ;;
  --check) MODE="check" ;;
esac

# =========================
# 設定モジュール定義
# =========================
# 各モジュール: "名前|説明|ソース(user/からの相対パス)|コピー先(~/からの相対パス)|タイプ(file|dir)"
MODULES=(
  "neovim|Neovim エディタ設定|.config/nvim|.config/nvim|dir"
  "tmux|tmux ターミナルマルチプレクサ設定|.tmux.conf|.tmux.conf|file"
  "zsh|Zsh シェル設定|.zshrc|.zshrc|file"
  "wezterm|WezTerm ターミナル設定|.wezterm.lua|.wezterm.lua|file"
  "git|Git グローバル設定|.gitconfig|.gitconfig|file"
  "gitignore|Git グローバル ignore|.config/git/ignore|.config/git/ignore|file"
  "claude|Claude Code 設定|.claude|.claude|dir"
  "codex|Codex 設定|.codex|.codex|dir"
)

# =========================
# ユーティリティ関数
# =========================

# モジュールのフィールドを取得
get_field() {
  local module="$1" field="$2"
  echo "$module" | cut -d'|' -f"$field"
}

# ファイルの状態を確認
check_status() {
  local target="$1" source="$2" type="$3"

  if [[ ! -e "$target" ]]; then
    echo "missing"       # 未配置
    return
  fi

  # 内容を比較
  if [[ "$type" == "dir" ]]; then
    if diff -rq "$source" "$target" &>/dev/null; then
      echo "synced"      # リポジトリと同一
    else
      echo "modified"    # ローカルで変更あり
    fi
  else
    if diff -q "$source" "$target" &>/dev/null; then
      echo "synced"      # リポジトリと同一
    else
      echo "modified"    # ローカルで変更あり
    fi
  fi
}

# ステータス表示用のラベル
status_label() {
  case "$1" in
    synced)   printf "${GREEN}● 同期済み${RESET}" ;;
    modified) printf "${YELLOW}▲ 変更あり${RESET}" ;;
    missing)  printf "${DIM}○ 未配置${RESET}" ;;
  esac
}

# =========================
# ステータス一覧表示
# =========================
show_status() {
  echo ""
  printf "${BOLD}  設定ファイルの状態${RESET}\n"
  printf "  %s\n" "─────────────────────────────────────"

  for i in "${!MODULES[@]}"; do
    local mod="${MODULES[$i]}"
    local name desc src_rel tgt_rel type
    name="$(get_field "$mod" 1)"
    desc="$(get_field "$mod" 2)"
    src_rel="$(get_field "$mod" 3)"
    tgt_rel="$(get_field "$mod" 4)"
    type="$(get_field "$mod" 5)"

    local source="${USER_DIR}/${src_rel}"
    local target="${HOME_DIR}/${tgt_rel}"
    local status
    status="$(check_status "$target" "$source" "$type")"

    printf "  %s  ${BOLD}%-10s${RESET} %s\n" "$(status_label "$status")" "$name" "${DIM}${desc}${RESET}"
  done

  echo ""
}

# =========================
# デプロイ処理
# =========================
deploy_module() {
  local mod="$1"
  local name src_rel tgt_rel type
  name="$(get_field "$mod" 1)"
  src_rel="$(get_field "$mod" 3)"
  tgt_rel="$(get_field "$mod" 4)"
  type="$(get_field "$mod" 5)"

  local source="${USER_DIR}/${src_rel}"
  local target="${HOME_DIR}/${tgt_rel}"

  # ソースの存在確認
  if [[ ! -e "$source" ]]; then
    err "${name}: ソースが見つかりません (${source})"
    return 1
  fi

  local status
  status="$(check_status "$target" "$source" "$type")"

  case "$status" in
    synced)
      success "${name}: すでに最新です"
      return 0
      ;;
    modified)
      # 単一ファイルの場合のみここでバックアップ（dirはファイル単位で個別処理）
      if [[ "$type" == "file" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        warn "${name}: 既存ファイルをバックアップします → ${backup}"
        cp "$target" "$backup"
      fi
      ;;
    missing)
      ;;
  esac

  # 親ディレクトリを作成
  mkdir -p "$(dirname "$target")"

  # コピー
  if [[ "$type" == "dir" ]]; then
    # ディレクトリの場合: 中のファイルだけを個別にコピー（既存の他ファイルは残す）
    local copied=0
    while IFS= read -r -d '' src_file; do
      local rel="${src_file#"${source}"/}"
      local tgt_file="${target}/${rel}"

      mkdir -p "$(dirname "$tgt_file")"

      if [[ -f "$tgt_file" ]] && ! diff -q "$src_file" "$tgt_file" &>/dev/null; then
        local file_backup="${tgt_file}.backup.$(date +%Y%m%d_%H%M%S)"
        warn "${name}: ${rel} をバックアップ → ${file_backup}"
        cp "$tgt_file" "$file_backup"
      fi

      cp "$src_file" "$tgt_file"
      copied=$((copied + 1))
    done < <(find "$source" -type f ! -name '.DS_Store' -print0)

    success "${name}: ${copied} 個のファイルをコピーしました"
  else
    cp "$source" "$target"
    success "${name}: コピーしました (${target})"
  fi
}

# =========================
# インタラクティブ選択UI
# =========================
interactive_select() {
  # 選択状態の配列（0: 未選択, 1: 選択済み）
  local -a selected
  for i in "${!MODULES[@]}"; do
    selected[$i]=1  # デフォルトで全選択
  done

  while true; do
    # 画面クリア
    printf "\033[2J\033[H"

    echo ""
    printf "${BOLD}${CYAN}  ╔══════════════════════════════════════╗${RESET}\n"
    printf "${BOLD}${CYAN}  ║     Dotfiles デプロイ設定 選択       ║${RESET}\n"
    printf "${BOLD}${CYAN}  ╚══════════════════════════════════════╝${RESET}\n"
    echo ""
    printf "  ${DIM}番号で選択切替 │ a: 全選択 │ n: 全解除${RESET}\n"
    printf "  ${DIM}Enter: デプロイ開始     │ q: キャンセル${RESET}\n"
    echo ""

    for i in "${!MODULES[@]}"; do
      local mod="${MODULES[$i]}"
      local name desc src_rel tgt_rel type
      name="$(get_field "$mod" 1)"
      desc="$(get_field "$mod" 2)"
      tgt_rel="$(get_field "$mod" 4)"
      type="$(get_field "$mod" 5)"

      local source="${USER_DIR}/$(get_field "$mod" 3)"
      local target="${HOME_DIR}/${tgt_rel}"
      local status
      status="$(check_status "$target" "$source" "$type")"

      local checkbox
      if [[ "${selected[$i]}" -eq 1 ]]; then
        checkbox="${GREEN}[✔]${RESET}"
      else
        checkbox="${DIM}[ ]${RESET}"
      fi

      local num=$((i + 1))
      printf "  ${BOLD}%d${RESET}  %s  ${BOLD}%-10s${RESET} %s  %s\n" \
        "$num" "$checkbox" "$name" "${DIM}${desc}${RESET}" "$(status_label "$status")"
    done

    echo ""

    # キー入力を読み取り
    printf "  ${BOLD}> ${RESET}"
    local key
    read -rsn1 key

    case "$key" in
      [1-9])
        local idx=$((key - 1))
        if [[ $idx -lt ${#MODULES[@]} ]]; then
          selected[$idx]=$(( 1 - selected[$idx] ))
        fi
        ;;
      a|A)
        for i in "${!MODULES[@]}"; do selected[$i]=1; done
        ;;
      n|N)
        for i in "${!MODULES[@]}"; do selected[$i]=0; done
        ;;
      q|Q)
        echo ""
        info "キャンセルしました"
        exit 0
        ;;
      "")  # Enter
        break
        ;;
    esac
  done

  # 選択されたモジュールをデプロイ
  echo ""
  printf "${BOLD}  デプロイを開始します...${RESET}\n"
  echo ""

  local deployed=0
  for i in "${!MODULES[@]}"; do
    if [[ "${selected[$i]}" -eq 1 ]]; then
      deploy_module "${MODULES[$i]}"
      deployed=$((deployed + 1))
    fi
  done

  if [[ $deployed -eq 0 ]]; then
    warn "何も選択されていません"
  fi
}

# =========================
# メイン処理
# =========================
main() {
  echo ""
  printf "${BOLD}${BLUE}Dotfiles Deployer${RESET}\n"
  printf "${DIM}${SCRIPT_DIR}${RESET}\n"

  case "$MODE" in
    check)
      show_status
      ;;
    all)
      echo ""
      for mod in "${MODULES[@]}"; do
        deploy_module "$mod"
      done
      ;;
    interactive)
      interactive_select
      ;;
  esac

  # 完了サマリー
  if [[ "$MODE" != "check" ]]; then
    echo ""
    printf "${BLUE}════════════════════════════════════════${RESET}\n"
    printf "${GREEN}${BOLD}  デプロイ完了！${RESET}\n"
    printf "${BLUE}════════════════════════════════════════${RESET}\n"
    echo ""
    info "変更を反映するにはシェルを再起動してください:"
    printf "  ${BOLD}exec \$SHELL${RESET}\n"
    echo ""
  fi
}

main
