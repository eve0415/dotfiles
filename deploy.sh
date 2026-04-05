#!/usr/bin/env bash
set -euo pipefail

# =========================
# Dotfiles deployer
# =========================
# 設定ファイルをホームディレクトリにコピーまたはシンボリックリンクで配置します。
# コピー方式: デプロイ後にマシン固有のカスタマイズが可能。
# シンボリックリンク方式: リポジトリとの同期を維持。
# インタラクティブな選択式UIで、デプロイする設定と方式を選べます。
#
# Usage:
#   ./deploy.sh                   # インタラクティブモード（選択式）
#   ./deploy.sh --all             # すべてをコピーで一括デプロイ
#   ./deploy.sh --all --copy      # すべてをコピーで一括デプロイ
#   ./deploy.sh --all --link      # すべてをシンボリックリンクで一括デプロイ
#   ./deploy.sh --check           # 現在の状態を確認（変更なし）

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

# ---- Mode & Method ----
MODE="interactive"
METHOD=""  # copy or link（空の場合はインタラクティブで選択）
for arg in "$@"; do
  case "$arg" in
    --all)   MODE="all" ;;
    --check) MODE="check" ;;
    --copy)  METHOD="copy" ;;
    --link)  METHOD="link" ;;
  esac
done

# --all の場合、方式未指定ならコピーをデフォルトにする
if [[ "$MODE" == "all" && -z "$METHOD" ]]; then
  METHOD="copy"
fi

# =========================
# 設定モジュール定義
# =========================
# 各モジュール: "名前|説明|ソース(user/からの相対パス)|コピー先(~/からの相対パス)|タイプ(file|dir|files)"
# files タイプ: セミコロン区切りで複数ファイルを指定 (src>tgt;src>tgt)
MODULES=(
  "neovim|Neovim エディタ設定|.config/nvim|.config/nvim|dir"
  "tmux|tmux ターミナルマルチプレクサ設定|.tmux.conf|.tmux.conf|file"
  "zsh|Zsh シェル設定|.zshrc|.zshrc|file"
  "wezterm|WezTerm ターミナル設定|.wezterm.lua|.wezterm.lua|file"
  "git|Git 設定 (config + ignore)|.gitconfig>.gitconfig;.config/git/ignore>.config/git/ignore||files"
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

  if [[ "$type" == "files" ]]; then
    # files タイプ: source フィールドにセミコロン区切りのペアが入っている
    check_status_files "$source"
    return
  fi

  if [[ ! -e "$target" ]]; then
    echo "missing"       # 未配置
    return
  fi

  # シンボリックリンクの場合、リンク先を確認
  if [[ -L "$target" ]]; then
    local link_target
    link_target="$(readlink -f "$target")"
    local real_source
    real_source="$(readlink -f "$source")"
    if [[ "$link_target" == "$real_source" ]]; then
      echo "synced"
    else
      echo "modified"
    fi
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

# files タイプのステータスを確認
check_status_files() {
  local pairs="$1"
  local any_missing=false any_modified=false

  IFS=';' read -ra PAIRS <<< "$pairs"
  for pair in "${PAIRS[@]}"; do
    local src_rel="${pair%%>*}"
    local tgt_rel="${pair#*>}"
    local src="${USER_DIR}/${src_rel}"
    local tgt="${HOME_DIR}/${tgt_rel}"

    if [[ ! -e "$tgt" ]]; then
      any_missing=true
      continue
    fi

    if [[ -L "$tgt" ]]; then
      local link_target real_source
      link_target="$(readlink -f "$tgt")"
      real_source="$(readlink -f "$src")"
      if [[ "$link_target" != "$real_source" ]]; then
        any_modified=true
      fi
    elif ! diff -q "$src" "$tgt" &>/dev/null; then
      any_modified=true
    fi
  done

  if $any_missing; then
    echo "missing"
  elif $any_modified; then
    echo "modified"
  else
    echo "synced"
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

    local status
    if [[ "$type" == "files" ]]; then
      status="$(check_status "" "$src_rel" "$type")"
    else
      local source="${USER_DIR}/${src_rel}"
      local target="${HOME_DIR}/${tgt_rel}"
      status="$(check_status "$target" "$source" "$type")"
    fi

    printf "  %s  ${BOLD}%-10s${RESET} %s\n" "$(status_label "$status")" "$name" "${DIM}${desc}${RESET}"
  done

  echo ""
}

# =========================
# デプロイ処理
# =========================

# 単一ファイルをデプロイ（コピーまたはシンボリックリンク）
deploy_single_file() {
  local name="$1" source="$2" target="$3"

  mkdir -p "$(dirname "$target")"

  # 既存ファイルのバックアップ（シンボリックリンクでない場合）
  if [[ -e "$target" && ! -L "$target" ]] && ! diff -q "$source" "$target" &>/dev/null; then
    local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
    warn "${name}: 既存ファイルをバックアップします → ${backup}"
    cp "$target" "$backup"
  fi

  # 既存のシンボリックリンクを削除
  if [[ -L "$target" ]]; then
    rm "$target"
  fi

  if [[ "$METHOD" == "link" ]]; then
    ln -sf "$source" "$target"
  else
    cp "$source" "$target"
  fi
}

deploy_module() {
  local mod="$1"
  local name src_rel tgt_rel type
  name="$(get_field "$mod" 1)"
  src_rel="$(get_field "$mod" 3)"
  tgt_rel="$(get_field "$mod" 4)"
  type="$(get_field "$mod" 5)"

  local method_label
  if [[ "$METHOD" == "link" ]]; then
    method_label="リンク"
  else
    method_label="コピー"
  fi

  # files タイプ: 複数ファイルペアを処理
  if [[ "$type" == "files" ]]; then
    deploy_files_module "$name" "$src_rel" "$method_label"
    return
  fi

  local source="${USER_DIR}/${src_rel}"
  local target="${HOME_DIR}/${tgt_rel}"

  # ソースの存在確認
  if [[ ! -e "$source" ]]; then
    err "${name}: ソースが見つかりません (${source})"
    return 1
  fi

  local status
  status="$(check_status "$target" "$source" "$type")"

  if [[ "$status" == "synced" ]]; then
    success "${name}: すでに最新です"
    return 0
  fi

  if [[ "$type" == "dir" ]]; then
    if [[ "$METHOD" == "link" ]]; then
      # ディレクトリのシンボリックリンク: 既存ディレクトリをバックアップして置換
      if [[ -e "$target" && ! -L "$target" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        warn "${name}: 既存ディレクトリをバックアップします → ${backup}"
        mv "$target" "$backup"
      elif [[ -L "$target" ]]; then
        rm "$target"
      fi
      mkdir -p "$(dirname "$target")"
      ln -sf "$source" "$target"
      success "${name}: ${method_label}しました (${target})"
    else
      # ディレクトリのコピー: 中のファイルだけを個別にコピー（既存の他ファイルは残す）
      local copied=0
      while IFS= read -r -d '' src_file; do
        local rel="${src_file#"${source}"/}"
        local tgt_file="${target}/${rel}"

        deploy_single_file "$name" "$src_file" "$tgt_file"
        copied=$((copied + 1))
      done < <(find "$source" -type f ! -name '.DS_Store' -print0)

      success "${name}: ${copied} 個のファイルを${method_label}しました"
    fi
  else
    deploy_single_file "$name" "$source" "$target"
    success "${name}: ${method_label}しました (${target})"
  fi
}

# files タイプのデプロイ処理
deploy_files_module() {
  local name="$1" pairs="$2" method_label="$3"

  IFS=';' read -ra PAIRS <<< "$pairs"
  local deployed=0

  for pair in "${PAIRS[@]}"; do
    local src_rel="${pair%%>*}"
    local tgt_rel="${pair#*>}"
    local source="${USER_DIR}/${src_rel}"
    local target="${HOME_DIR}/${tgt_rel}"

    if [[ ! -e "$source" ]]; then
      err "${name}: ソースが見つかりません (${source})"
      continue
    fi

    # 個別ファイルの同期チェック
    local file_status
    file_status="$(check_status "$target" "$source" "file")"
    if [[ "$file_status" == "synced" ]]; then
      deployed=$((deployed + 1))
      continue
    fi

    deploy_single_file "$name" "$source" "$target"
    deployed=$((deployed + 1))
  done

  success "${name}: ${deployed} 個のファイルを${method_label}しました"
}

# =========================
# デプロイ方式選択UI
# =========================
select_method() {
  local method_idx=0  # 0: copy, 1: link

  while true; do
    printf "\033[2J\033[H"

    echo ""
    printf "${BOLD}${CYAN}  ╔══════════════════════════════════════╗${RESET}\n"
    printf "${BOLD}${CYAN}  ║     デプロイ方式を選択してください   ║${RESET}\n"
    printf "${BOLD}${CYAN}  ╚══════════════════════════════════════╝${RESET}\n"
    echo ""
    printf "  ${DIM}番号で選択 │ Enter: 決定 │ q: キャンセル${RESET}\n"
    echo ""

    local copy_mark link_mark
    if [[ $method_idx -eq 0 ]]; then
      copy_mark="${GREEN}●${RESET}"
      link_mark="${DIM}○${RESET}"
    else
      copy_mark="${DIM}○${RESET}"
      link_mark="${GREEN}●${RESET}"
    fi

    printf "  ${BOLD}1${RESET}  %s  ${BOLD}コピー${RESET}              ${DIM}ファイルをコピーして配置（マシン固有のカスタマイズ可）${RESET}\n" "$copy_mark"
    printf "  ${BOLD}2${RESET}  %s  ${BOLD}シンボリックリンク${RESET}  ${DIM}リポジトリへのリンクを作成（常に同期）${RESET}\n" "$link_mark"
    echo ""

    printf "  ${BOLD}> ${RESET}"
    local key
    read -rsn1 key

    case "$key" in
      1) method_idx=0 ;;
      2) method_idx=1 ;;
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

  if [[ $method_idx -eq 0 ]]; then
    METHOD="copy"
  else
    METHOD="link"
  fi
}

# =========================
# インタラクティブ選択UI
# =========================
interactive_select() {
  # まずデプロイ方式を選択
  if [[ -z "$METHOD" ]]; then
    select_method
  fi

  local method_display
  if [[ "$METHOD" == "link" ]]; then
    method_display="シンボリックリンク"
  else
    method_display="コピー"
  fi

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
    printf "  方式: ${BOLD}${GREEN}%s${RESET}\n" "$method_display"
    echo ""
    printf "  ${DIM}番号で選択切替 │ a: 全選択 │ n: 全解除${RESET}\n"
    printf "  ${DIM}Enter: デプロイ開始     │ q: キャンセル${RESET}\n"
    echo ""

    for i in "${!MODULES[@]}"; do
      local mod="${MODULES[$i]}"
      local name desc src_rel tgt_rel type
      name="$(get_field "$mod" 1)"
      desc="$(get_field "$mod" 2)"
      src_rel="$(get_field "$mod" 3)"
      tgt_rel="$(get_field "$mod" 4)"
      type="$(get_field "$mod" 5)"

      local status
      if [[ "$type" == "files" ]]; then
        status="$(check_status "" "$src_rel" "$type")"
      else
        local source="${USER_DIR}/${src_rel}"
        local target="${HOME_DIR}/${tgt_rel}"
        status="$(check_status "$target" "$source" "$type")"
      fi

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
  printf "${BOLD}  デプロイを開始します... (${method_display})${RESET}\n"
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
