# report-hub

> versatile-ai 各仓库的自包含 HTML 报告聚合站点。
>
> 🌐 在线访问:<https://versatile-ai.github.io/report-hub/>

## 概述

report-hub 把 versatile-ai 下各仓库的实验/阶段报告聚合为一个纯静态站点:每份报告是单个 HTML 文件,内联全部 CSS/JS,无构建、无外部依赖、无后端。URL 即路径,可直链分享,托管于 GitHub Pages 或任意静态服务器。

站点采用两级导航:顶层 `index.html` 聚合所有仓库(`REPOS` 数组),`<repo>/index.html` 自报本仓库的实验与报告(`EXPERIMENTS` 数组)。聚合统计只由各仓库子目录自维护,顶层不复制,避免双源漂移。

## 特性

- **自包含** — 单文件、零外链,离线可读,分享即所见。
- **统一视觉** — 浅色入口/导航页 + 深色报告页,以 `docs/design-guide.md` 为单一事实源。
- **两级导航** — 顶层聚合仓库,仓库页自报实验,统计不双源。
- **自动化发布** — 附带 `report-hub-build-publish` skill,供 Claude Code / Codex / OpenCode 自动生成报告、登记导航、提交发布。

## 快速开始

### 预览

```bash
git clone https://github.com/versatile-ai/report-hub.git
cd report-hub
python3 -m http.server 8000
# 浏览器打开 http://localhost:8000
```

### 安装 build-publish skill

```bash
bash scripts/install-skill.sh
```

交互模式:自动检测本机已装的 agent(claude code / codex / opencode)并选择安装目标。已运行的 agent 会话需重启以加载新 skill。

### 用法示例

在 agent 会话里执行 `/report-hub-build-publish`,告诉它仓库、实验、报告类型和素材即可,它会生成报告页、登记导航、本地提交,推送前等你确认:

```
/report-hub-build-publish

给 automodelwire / deepseek-v4-npu-dspark 发一份 stage 报告,
标题「Phase Report — Draft Graph 落盘」,素材见下……
```

## 目录结构

```
report-hub/
├── index.html                       # 顶层聚合入口(versatile-ai 全局导航)
├── docs/
│   └── design-guide.md              # 设计规范(单一事实源)
├── automodelwire/                   # AutoModelWire 仓库报告
│   ├── index.html                   # 仓库级导航(EXPERIMENTS 自报)
│   └── ...
├── skills/
│   └── report-hub-build-publish/    # 跨 agent 报告生成 skill
└── scripts/
    └── install-skill.sh             # 一键安装脚本
```
