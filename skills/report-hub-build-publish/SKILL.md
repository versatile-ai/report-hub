---
name: report-hub-build-publish
description: 生成并发布自包含 HTML 报告到 report-hub。按 docs/design-guide.md 规范制作深态报告页,登记到仓库级 EXPERIMENTS 导航与顶层 REPOS,本地 git commit,推送前等用户确认。须先经 scripts/install-skill.sh 安装并写入 repo_path。
---

# report-hub-build-publish — 报告创作与发布

你是 report-hub 的**报告作者**——把实验/性能/诊断内容做成自包含 HTML 报告,登记进站点导航,
并提交到 git 远程(推送前等用户确认)。

> 一切产物严格遵循 report-hub 仓库规则。本 skill 只引导流程,具体 token/组件规格以
> `docs/design-guide.md` 为单一事实源,目录/命名/登记约定以仓库 `CLAUDE.md` 为准。

## 0. 启动:先读配置与规范,不要凭记忆

1. 读本 skill 目录下 `config.json`,取 `repo_path`(本仓库在用户机器上的绝对路径)。
   - 若 `repo_path` 缺失或为 `{{REPO_PATH}}` 占位 → 停下,告诉用户运行 `bash scripts/install-skill.sh` 安装本 skill。
2. `Read repo_path/docs/design-guide.md`(视觉系统唯一事实源:浅/深两态 token、字体三角色、
   组件规格、报告页骨架、可访问性硬要求、自包含约束、文件命名约定)。
3. `Read repo_path/CLAUDE.md`(接口边界、新增仓库约定,尤其"聚合统计不复制"红线)。
4. 浏览 `repo_path/index.html` 顶层 `REPOS` 数组与目标仓库 `<repo>/index.html` 的 `EXPERIMENTS` 数组,
   了解现有结构与字段命名,新增时保持一致。

读了就遵循,不在 skill 中复述 token 值——每个报告的 `:root` token 块从 `templates/report-page.html`
原样复制,不改值。

## 1. 收集发布参数(先自动识别,有歧义才问用户)

**不要逐项追问能自己确定的事。** 按下面顺序推断,推断失败或歧义时才问用户。

### 自动识别(优先)

1. **目标仓库** — 依次尝试:
   - 当前工作目录(`pwd`)落在 `repo_path/<repo>/` 下 → 取该 `<repo>`;
   - 否则在对话上下文里找与顶层 `REPOS` 中某 `id`/`name` 匹配的仓库名 → 取之;
   - 命中唯一 → 直接用;命中多个或无命中 → 问用户。
2. **实验 id** — 依次尝试:
   - cwd 落在 `repo_path/<repo>/<experiment>/` 下 → 取该 `<experiment>`;
   - 否则看对话上下文与最近 git 改动文件路径(`git -C repo_path status --short`),匹配目标仓库 `<repo>/index.html` 中 `EXPERIMENTS` 已有 `id` → 取之;
   - 命中唯一 → 直接用;多个或无命中 → 问用户(并说明:是选已有实验,还是给个新 id)。
3. **报告日期** — 默认今天(`date +%F`),除非用户指定。
4. **报告 type** — 用户语句里出现"阶段/周报/结题/诊断/设计/复盘"等词则映射对应 type;否则默认 `stage`,并告知用户可改。

### 必须问用户的(无法推断)

| 参数 | 说明 |
|------|------|
| 报告 `type` | 仅当无法从用户语句推断时问;否则按推断值,在最终确认环节让用户复核 |
| 报告标题 | 一句话标题 |
| 一句话摘要 | 用于 `<meta name="description">` 与导航 `subtitle` |
| 报告内容素材 | 章节、数据、指标、表格、代码改动位置、教训等;素材不足时主动追问 |

### 新仓库 / 新实验的判定

- 目标仓库子目录不存在 → **新仓库**(走第 5 步分支)。
- 仓库存在但识别到的实验 `id` 不在其 `EXPERIMENTS` 中,或用户明确说要新建 → **新实验**。
- 其余为已有实验追加报告。

### 识别后统一确认

把推断结果(仓库 / 实验 / 是否新 / type / 日期)一次性列给用户确认,再开始写。不要逐项打断;只在某项无法推断时单独问那一项。

## 2. 命名与落位(design-guide §7)

- 文件路径:`repo_path/<repo>/<experiment>/YYYY-MM-DD-<type>.html`
- 目录名、文件名全小写、连字符分隔;时间戳在前,描述在后。
- 例:`automodelwire/deepseek-v4-npu-dspark/2026-07-22-phase-report.html`

## 3. 生成报告页(深态)

1. 把 `templates/report-page.html` 复制到目标路径(本 skill 目录下的 `templates/`)。
2. 填内容,但**深态 `:root` token 块原样保留,不改任何值**(design-guide §2 深态列)。
3. 必备结构(design-guide §3/§4):
   - **Breadcrumb**(每份报告顶部必有):`versatile-ai / <仓库> / <实验> / <报告类型>`
     - `../../index.html` → 顶层;`../index.html` → 仓库级;`../index.html#<experiment-id>` → 实验锚;末段纯文本。
   - **Header**:H1(Display 等宽字体) + 一行 meta(Body,muted):报告类型 · 周期 · 集群 · 分支 · 报告日期。
   - **TOC**:section ≥ 4 个时必备,每个 `<section>` 须有 `id`,`<h2>` 文案与 TOC 条目一致。
   - 组件按 §3 规格:Metric/Stat 卡、Table(表头 `--surface-2`+accent 文字+uppercase 11px、数值列 `tabular-nums` 右对齐、`.ok/.warn/.bad` 语义类)、Timeline、Badge/Tag、Note(`.note.ok/.warn/.bad`)、Code block。
4. 可访问性硬要求(§5):`lang="zh-CN"`、`<meta name="description">`、所有交互元素 `:focus-visible`(2px solid accent)、`@media (prefers-reduced-motion: reduce)`、`@media print`。
5. **自包含红线**(§6):CSS/JS 全内联,无 `<link>`/`<script src>` 外链、无运行时 fetch、无构建步骤、无外部图片/字体。

## 4. 登记到仓库级导航

编辑 `repo_path/<repo>/index.html` 的 `EXPERIMENTS` 数组(用 Edit 精确修改,不动其他实验):

- **已有实验**:在其 `reports` 数组末尾追加一条:
  ```js
  {title:"<报告标题>",subtitle:"<一句话摘要>",file:"<experiment>/YYYY-MM-DD-<type>.html",date:"YYYY-MM-DD",type:"<type>"}
  ```
  并把该实验的 `lastUpdate` 更新为报告日期(若新于现有值)。
- **新实验**:追加整项,字段对齐现有结构:
  ```js
  {id:"<experiment>",name:"<显示名>",subtitle:"<副标题>",status:"active",
   startDate:"YYYY-MM-DD",lastUpdate:"YYYY-MM-DD",
   tags:[...],metrics:[{label,value,tone}],reports:[ {上述一条} ]}
  ```
  `tone` 取 `good/warn/info`。

## 5. 新仓库分支(目标子目录不存在时)

1. 建 `repo_path/<repo>/index.html`:复制 `templates/repo-nav.html`(浅态仓库级导航骨架),
   填本仓库 `EXPERIMENTS`(至少含本次实验一项)与 header 文案。保持自包含。
2. 在顶层 `repo_path/index.html` 的 `REPOS` 数组追加一项,字段**仅限**:
   ```js
   {id:"<repo>",name:"<显示名>",path:"<repo>/",gh:"<仓库 GitHub URL>",
    desc:"<一句话描述>",lastUpdate:"YYYY-MM-DD",tags:[...]}
   ```
   **禁止**写入 `reports`/`active`/`stats` 等聚合字段——那些由各仓库子目录 `index.html` 自报,
   顶层不复制,避免双源漂移(CLAUDE.md 约定 5)。

## 6. 校验(每一步验证,不空喊"完成")

1. 在 `repo_path` 启动本地预览:`python3 -m http.server 8000`(后台运行)。
2. 抽查:
   - 新报告页 HTTP 200、`lang="zh-CN"`、`<meta name="description">` 存在;
   - 仓库级 `index.html` 导航出现新报告条目,链接指向正确相对路径,点击可达;
   - 顶层 `index.html`(若改了)`REPOS` 出现新仓库,卡片链接指向 `<repo>/`;
   - grep 新报告页:无 `https?://` 外链资源引用、无 `<link rel="stylesheet">`、无 `<script src=`。
3. 校验通过后停掉 http.server。

## 7. 提交(自动执行)

在 `repo_path` 下:

```bash
git add <新增报告文件> <repo>/index.html [顶层 index.html]
git commit -m "feat(report-hub): <type>(<repo>/<experiment>): <一句话摘要>"
```

约定式提交,中文描述。只 `git add` 本次改动的文件,不用 `git add -A`。

## 8. 推送(必须等用户确认)

向用户报告:本次 commit 的 hash、改动文件清单、待推送分支(`git branch --show-current`)、
远程 `origin`。明确询问:**"是否 push 到 origin/<branch>?"**

- 用户同意 → `git push origin <branch>`,报告推送结果。
- 用户拒绝 → 停在本地提交,告知手动推送命令 `git push origin <branch>`,不追问、不自行推送。
- **绝不在未经确认时 `git push`。绝不 `--force` 推送。**

## 9. 红线(违反即事故)

| # | 红线 |
|---|------|
| R1 | 不改 `docs/design-guide.md` 的 token 取值;每个报告 `:root` 块从模板原样复制 |
| R2 | 不把实验数/报告数等聚合统计写进顶层 `REPOS`(顶层只持仓库级元数据) |
| R3 | 产物自包含:无外链 CSS/JS/字体/图片、无运行时 fetch、无构建步骤 |
| R4 | 只动本次报告相关文件,不碰其他仓库子目录、其他实验条目 |
| R5 | 推送前必须用户确认;不 force push |
| R6 | 文件名严格 `YYYY-MM-DD-<type>.html`,目录/实验 id 全小写连字符 |
