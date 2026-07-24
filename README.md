# report-hub

> 🌐 **在线访问:<https://versatile-ai.github.io/report-hub/>**

> versatile-ai 各仓库的**自包含 HTML 报告聚合站点**。
> 顶层 `index.html` 做多仓库导航,每个仓库在子目录下维护自己的实验与报告页面。

产物为纯静态 HTML(内联 CSS/JS、无构建步骤、无外部依赖、无后端),URL 即路径,可直链分享,可直接托管于 GitHub Pages 或任意静态服务器。

## 特性

- **自包含**:每份报告单文件、零外链,离线可读,分享即所见。
- **双主题统一视觉**:浅壳入口/导航页 + 深文报告页,共享强调紫与三字体角色,以 [`docs/design-guide.md`](docs/design-guide.md) 为单一事实源。
- **两级导航**:顶层 `REPOS` 聚合仓库,各仓库子目录 `index.html` 自报实验与报告,避免双源统计漂移。
- **一键安装 skill**:附带 `report-hub-build-publish` skill,供 Claude Code / Codex / OpenCode 自动按规范生成报告、登记导航、提交发布。

## 目录结构

```
report-hub/
├── index.html                # 顶层聚合入口(versatile-ai 全局导航)
├── docs/
│   └── design-guide.md       # 设计规范(单一事实源)
├── automodelwire/            # AutoModelWire 仓库报告
│   ├── index.html            # 仓库级导航(EXPERIMENTS 自报)
│   ├── deepseek-v4-npu-dspark/
│   │   ├── 2026-07-19-stage-report.html
│   │   └── 2026-07-22-phase-report.html
│   ├── deepseek-v4-npu-operator-deps/
│   ├── cann-ops-version-diff/
│   └── verl-train-perfix-cache-perf/
├── skills/
│   └── report-hub-build-publish/   # 跨 agent 报告生成 skill
└── scripts/
    └── install-skill.sh      # 一键安装脚本
```

## 快速开始

### 1. 本地预览

```bash
cd report-hub
python3 -m http.server 8000
# 浏览器打开 http://localhost:8000
```

### 2. 安装 build-publish skill(推荐)

安装后,在 agent 会话中执行 `/report-hub-build-publish`,即可按设计规范自动生成报告、登记导航、提交,并在推送前征求确认。

```bash
# 交互模式:自动检测本机已装的 agent 并选择安装目标
bash scripts/install-skill.sh

# 非交互:指定路径与目标 agent(逗号分隔)
bash scripts/install-skill.sh --path . --agent claude,codex

# 装到所有检测到的 agent
bash scripts/install-skill.sh --all
```

脚本会:
1. 确定 report-hub 本地路径(须含 `index.html` 与 `docs/design-guide.md`);
2. 检测已装的 agent(claude code / codex / opencode),交互选择目标;
3. 把 `skills/report-hub-build-publish/` 拷到目标 agent 的 `skills/` 目录,并在 `config.json` 写入 `repo_path`。

> 未克隆本仓库时,先 `git clone https://github.com/versatile-ai/report-hub.git && cd report-hub && bash scripts/install-skill.sh`。
> 安装后若 agent 会话已在运行,需重启以加载新 skill。

## 新增报告

### 通过 skill(推荐)

在对应 agent 会话执行 `/report-hub-build-publish`,提供目标仓库、实验、报告类型等参数。skill 将:

1. 按 `docs/design-guide.md` 生成自包含报告页 `<repo>/<experiment>/YYYY-MM-DD-<type>.html`;
2. 登记到仓库级导航 `<repo>/index.html` 的 `EXPERIMENTS` 数组,并同步 `lastUpdate`;
3. 本地 `git commit`(约定式提交),**推送前询问确认**。

报告类型: `stage` / `final` / `weekly` / `diagnosis` / `design` / `retrospective`。

### 手动

1. 照 [`docs/design-guide.md`](docs/design-guide.md) 的骨架与 token 拼装报告页,文件名 `YYYY-MM-DD-<type>.html`,全小写连字符。
2. 编辑 `<repo>/index.html` 的 `EXPERIMENTS` 数组:新实验追加整项,已有实验在其 `reports` 末尾追加条目并更新 `lastUpdate`。
3. 产物须自包含(无外链 CSS/JS、无运行时 fetch),`section ≥ 4` 时必备 TOC,顶部必备 breadcrumb。

## 新增仓库

1. 在仓库根建子目录,目录名 = GitHub 仓库名(全小写、连字符分隔)。
2. 子目录内建 `index.html` 作为仓库级导航,自报本仓库的 `EXPERIMENTS`(实验/报告即事实源)。
3. 在顶层 `index.html` 的 `REPOS` 数组追加一项,字段**仅限**:
   `id` / `name` / `path` / `gh` / `desc` / `lastUpdate` / `tags`
4. **聚合统计不复制**:顶层 `REPOS` **不**持有 `reports` / `active` / `stats` 等字段——实验数、报告数由各仓库子目录 `index.html` 自行维护,避免顶层与仓库页双源漂移。详见 [`CLAUDE.md`](CLAUDE.md)。

## 设计规范

全站视觉系统以 [`docs/design-guide.md`](docs/design-guide.md) 为单一事实源:主题基调(浅壳入口页 + 深文报告页)、design tokens(浅/深两态颜色、字体三角色、间距、圆角)、组件规格、报告页骨架、可访问性要求。新增或修改任何页面前先读该文档,产物须自包含内联 CSS(GitHub Pages 约束)。

## 迁移来源

- AutoModelWire `gh-pages` 分支(`ef62f75`):`index.html` 与 `deepseek-v4-npu-dspark/2026-07-19-stage-report.html`(原 `stage-report.html`),原样迁入 `automodelwire/` 子目录,报告内部相对链接保持不变。
