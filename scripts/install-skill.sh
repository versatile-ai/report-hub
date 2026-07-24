#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────
# report-hub-build-publish skill 一键安装
#
# 功能:
#   1. 确定 report-hub 本地路径(参数 / 自检 cwd / 交互询问)
#   2. 检测本机已安装的 agent:claude code / codex / opencode
#   3. 交互选择装到哪个(或 --agent / --all 非交互)
#   4. 在目标 agent 的 skills 目录创建软链接指向本仓库的 skill,
#      并写一份本机专属 config.json(填入 report-hub 绝对路径)。
#      软链接方式:仓库 git pull 后 SKILL.md / templates 自动更新,无需重装;
#      仅 repo_path 这一本机路径写在真实 config.json 里。
#
# 用法:
#   bash scripts/install-skill.sh                       # 全交互
#   bash scripts/install-skill.sh --path /path/to/repo  # 指定仓库路径
#   bash scripts/install-skill.sh --agent claude,codex  # 指定 agent(逗号分隔)
#   bash scripts/install-skill.sh --all                 # 装到所有检测到的 agent
#   bash scripts/install-skill.sh -h                    # 帮助
# ──────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="report-hub-build-publish"
SKILL_SRC="$SCRIPT_DIR/../skills/$SKILL_NAME"

REPORT_HUB_PATH=""
AGENTS_ARG=""
INSTALL_ALL=false

usage() {
  sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

# ── 参数解析 ──
while [[ $# -gt 0 ]]; do
  case "$1" in
    --path)   REPORT_HUB_PATH="$2"; shift 2;;
    --agent)  AGENTS_ARG="$2"; shift 2;;
    --all)    INSTALL_ALL=true; shift;;
    -h|--help) usage;;
    *) echo "未知参数: $1" >&2; exit 1;;
  esac
done

# ── 1. 确定 report-hub 路径 ──
is_report_hub() { [[ -f "$1/index.html" && -f "$1/docs/design-guide.md" ]]; }

if [[ -z "$REPORT_HUB_PATH" ]]; then
  if is_report_hub "$SCRIPT_DIR/.."; then
    REPORT_HUB_PATH="$SCRIPT_DIR/.."
  elif is_report_hub "$(pwd)"; then
    REPORT_HUB_PATH="$(pwd)"
  fi
fi

if [[ -z "$REPORT_HUB_PATH" ]]; then
  [[ -t 0 ]] || { echo "错误:非交互环境且未通过 --path 指定 report-hub 路径。" >&2; exit 1; }
  echo "请输入 report-hub 在本机的路径(含 index.html 与 docs/design-guide.md):"
  read -r -p "> " REPORT_HUB_PATH
fi

# 转绝对路径并校验
RAW_PATH="$REPORT_HUB_PATH"
REPORT_HUB_PATH="$(cd "$REPORT_HUB_PATH" 2>/dev/null && pwd)" || {
  echo "错误:路径不存在或无法进入: $RAW_PATH" >&2; exit 1;
}
if ! is_report_hub "$REPORT_HUB_PATH"; then
  echo "错误:$REPORT_HUB_PATH 不是 report-hub 仓库(缺 index.html 或 docs/design-guide.md)。" >&2
  exit 1
fi
echo "✔ report-hub 路径: $REPORT_HUB_PATH"

if [[ ! -d "$SKILL_SRC" ]]; then
  echo "错误:找不到 skill 源目录: $SKILL_SRC" >&2
  exit 1
fi

# ── 2. 检测 agent ──
# 每个 agent:名称 + skills 目录(目录存在 或 CLI 在 PATH 即视为已安装)
detect_agents() {
  local found=()
  # claude code
  if [[ -d "$HOME/.claude/skills" ]] || command -v claude >/dev/null 2>&1; then
    found+=("claude|$HOME/.claude/skills")
  fi
  # codex
  if [[ -d "$HOME/.codex/skills" ]] || command -v codex >/dev/null 2>&1; then
    found+=("codex|$HOME/.codex/skills")
  fi
  # opencode
  if [[ -d "$HOME/.config/opencode/skills" ]] || command -v opencode >/dev/null 2>&1; then
    found+=("opencode|$HOME/.config/opencode/skills")
  fi
  printf '%s\n' "${found[@]}"
}

DETECTED=()
while IFS= read -r line; do
  [[ -n "$line" ]] && DETECTED+=("$line")
done < <(detect_agents)

if [[ ${#DETECTED[@]} -eq 0 ]]; then
  echo "错误:未检测到任何已安装的 agent(claude code / codex / opencode)。" >&2
  echo "  请先安装其一,或手动把 $SKILL_SRC 拷到对应 skills 目录并改 config.json 的 repo_path。" >&2
  exit 1
fi

echo "检测到以下 agent:"
for i in "${!DETECTED[@]}"; do
  IFS='|' read -r name dir <<<"${DETECTED[$i]}"
  printf '  [%d] %s  →  %s\n' "$((i+1))" "$name" "$dir"
done

# ── 3. 选择 agent ──
select_indices=()
if $INSTALL_ALL; then
  for i in "${!DETECTED[@]}"; do select_indices+=("$i"); done
elif [[ -n "$AGENTS_ARG" ]]; then
  # 按名称匹配
  IFS=',' read -ra REQ_NAMES <<<"$AGENTS_ARG"
  for i in "${!DETECTED[@]}"; do
    IFS='|' read -r name dir <<<"${DETECTED[$i]}"
    for req in "${REQ_NAMES[@]}"; do
      if [[ "$name" == "$req" ]]; then select_indices+=("$i"); fi
    done
  done
  if [[ ${#select_indices[@]} -eq 0 ]]; then
    echo "错误:--agent 指定的 agent($AGENTS_ARG)未在检测列表中。" >&2; exit 1
  fi
else
  # 交互多选
  [[ -t 0 ]] || { echo "错误:非交互环境请用 --agent 或 --all 指定目标。" >&2; exit 1; }
  echo "输入要安装到的 agent 编号(逗号分隔,回车=全部):"
  read -r -p "> " selection
  selection="${selection// /}"
  if [[ -z "$selection" ]]; then
    for i in "${!DETECTED[@]}"; do select_indices+=("$i"); done
  else
    IFS=',' read -ra picks <<<"$selection"
    for p in "${picks[@]}"; do
      if [[ "$p" =~ ^[0-9]+$ ]] && [[ "$p" -ge 1 && "$p" -le ${#DETECTED[@]} ]]; then
        select_indices+=("$((p-1))")
      else
        echo "错误:无效编号 '$p'。" >&2; exit 1
      fi
    done
  fi
fi

# ── 4. 软链接 + 本机 config.json ──
install_one() {
  local target_dir="$1"  # skills 目录
  local dest="$target_dir/$SKILL_NAME"
  mkdir -p "$target_dir"
  rm -rf "$dest"
  mkdir -p "$dest"
  # SKILL.md / templates 软链接到仓库源:随仓库更新自动生效
  ln -s "$SKILL_SRC/SKILL.md" "$dest/SKILL.md"
  ln -s "$SKILL_SRC/templates" "$dest/templates"
  # config.json 为本机真实文件,写入 repo_path(不软链,因含本机绝对路径)
  local cfg="$dest/config.json"
  sed "s|{{REPO_PATH}}|$REPORT_HUB_PATH|g" "$SKILL_SRC/config.json" >"$cfg"
  echo "✔ 已安装 → $dest"
  echo "    软链 SKILL.md / templates → $SKILL_SRC(随仓库更新)"
  echo "    config.json: repo_path = $REPORT_HUB_PATH"
}

echo
echo "开始安装 $SKILL_NAME ..."
installed=()
for idx in "${select_indices[@]}"; do
  IFS='|' read -r name dir <<<"${DETECTED[$idx]}"
  # skills 目录可能尚不存在(opencode/codex 依 CLI 探测时)——创建之
  install_one "$dir"
  installed+=("$name ($dir)")
done

# ── 5. 摘要 ──
echo
echo "════════════════════════════════════════"
echo "安装完成"
echo "  skill:        $SKILL_NAME"
echo "  repo_path:    $REPORT_HUB_PATH"
echo "  已装到:"
for line in "${installed[@]}"; do echo "    - $line"; done
echo
echo "调用方式:在对应 agent 会话中执行  /$SKILL_NAME"
echo "提示:若 agent 会话已在运行,需重启以加载新 skill。"
echo "════════════════════════════════════════"
