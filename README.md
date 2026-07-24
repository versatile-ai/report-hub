# report-hub

> versatile-ai 各仓库的自包含 HTML 报告聚合站点。
>
> 🌐 在线访问:<https://versatile-ai.github.io/report-hub/>

[在线访问](https://versatile-ai.github.io/report-hub/) · [设计规范](docs/design-guide.md) · [模块说明](CLAUDE.md)

## 概述

report-hub 把 versatile-ai 下各仓库的实验/阶段报告聚合为一个**纯静态站点**:每份报告是单个 HTML 文件,内联全部 CSS/JS,无构建步骤、无外部依赖、无后端。URL 即路径,可直链分享,可直接托管于 GitHub Pages 或任意静态服务器。

站点采用两级导航:

- **顶层 `index.html`** — 仓库级聚合入口,通过 `REPOS` 数组列出所有仓库。
- **`<repo>/index.html`** — 仓库级导航,自报本仓库的实验与报告(`EXPERIMENTS` 数组)。

聚合统计(实验数、报告数等)只由各仓库子目录自维护,顶层不复制,避免双源漂移。

## 特性

- **自包含** — 每份报告单文件、零外链,离线可读,分享即所见。
- **统一视觉** — 浅色入口/导航页 + 深色报告页,共享强调紫与三字体角色,以 [`docs/design-guide.md`](docs/design-guide.md) 为单一事实源。
- **两级导航** — 顶层聚合仓库,仓库页自报实验,统计不双源。
- **自动化发布** — 附带 `report-hub-build-publish` skill,供 Claude Code / Codex / OpenCode 自动按规范生成报告、登记导航、提交发布。

## 快速开始

### 预览

```bash
git clone https://github.com/versatile-ai/report-hub.git
cd report-hub
python3 -m http.server 8000
# 浏览器打开 http://localhost:8000
```

### 安装 build-publish skill

安装后,在 agent 会话中执行 `/report-hub-build-publish`,即可按设计规范自动生成报告、登记导航、提交,并在推送前征求确认。

```bash
# 交互模式:自动检测本机已装的 agent 并选择安装目标
bash scripts/install-skill.sh

# 非交互:指定路径与目标 agent(逗号分隔)
bash scripts/install-skill.sh --path . --agent claude,codex

# 装到所有检测到的 agent
bash scripts/install-skill.sh --all
```

脚本会确定 report-hub 本地路径(须含 `index.html` 与 `docs/design-guide.md`)、检测已装的 agent(claude code / codex / opencode)、把 skill 拷到对应 `skills/` 目录并在 `config.json` 写入 `repo_path`。已运行的 agent 会话需重启以加载新 skill。

## 目录结构

```
report-hub/
├── index.html                       # 顶层聚合入口(versatile-ai 全局导航)
├── docs/
│   └── design-guide.md              # 设计规范(单一事实源)
├── automodelwire/                   # AutoModelWire 仓库报告
│   ├── index.html                   # 仓库级导航(EXPERIMENTS 自报)
│   ├── deepseek-v4-npu-dspark/
│   ├── deepseek-v4-npu-operator-deps/
│   ├── cann-ops-version-diff/
│   └── verl-train-perfix-cache-perf/
├── skills/
│   └── report-hub-build-publish/    # 跨 agent 报告生成 skill
└── scripts/
    └── install-skill.sh             # 一键安装脚本
```

## 维护工作流

### 新增报告

**通过 skill(推荐)** — 在 agent 会话执行 `/report-hub-build-publish`,提供目标仓库、实验、报告类型等参数。skill 将:

1. 按 `docs/design-guide.md` 生成自包含报告页 `<repo>/<experiment>/YYYY-MM-DD-<type>.html`;
2. 登记到 `<repo>/index.html` 的 `EXPERIMENTS` 数组,并同步 `lastUpdate`;
3. 本地 `git commit`(约定式提交),**推送前询问确认**。

**手动** — 照 [`docs/design-guide.md`](docs/design-guide.md) 的骨架与 token 拼装报告页:

1. 文件名 `YYYY-MM-DD-<type>.html`,全小写连字符;类型取值见下表。
2. 编辑 `<repo>/index.html` 的 `EXPERIMENTS`:新实验追加整项,已有实验在其 `reports` 末尾追加条目并更新 `lastUpdate`。
3. 产物须自包含(无外链 CSS/JS、无运行时 fetch),`section ≥ 4` 时必备 TOC,顶部必备 breadcrumb。

| 类型 | 含义 |
|------|------|
| `stage` | 阶段报告 |
| `final` | 结题报告 |
| `weekly` | 周报 |
| `diagnosis` | 诊断报告 |
| `design` | 设计文档 |
| `retrospective` | 复盘 |

### 新增仓库

1. 在仓库根建子目录,目录名 = GitHub 仓库名(全小写、连字符分隔)。
2. 子目录内建 `index.html` 作为仓库级导航,自报本仓库的 `EXPERIMENTS`(实验/报告即事实源)。
3. 在顶层 `index.html` 的 `REPOS` 数组追加一项,字段**仅限** `id` / `name` / `path` / `gh` / `desc` / `lastUpdate` / `tags`。
4. 顶层 `REPOS` **不**持有 `reports` / `active` / `stats` 等聚合字段——实验数、报告数由各仓库子目录自行维护。详见 [`CLAUDE.md`](CLAUDE.md)。

## 设计规范

全站视觉系统以 [`docs/design-guide.md`](docs/design-guide.md) 为单一事实源:主题基调(浅色入口 + 深色报告)、design tokens(浅/深两态颜色、字体三角色、间距、圆角)、组件规格、报告页骨架、可访问性要求。新增或修改任何页面前先读该文档,产物须自包含内联 CSS(GitHub Pages 约束)。
