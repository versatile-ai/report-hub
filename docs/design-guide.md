# report-hub 风格指导文档

本文件是 report-hub 站点视觉系统的**单一事实源**。所有新页面、新报告在生成 HTML 时
必须遵循此处的 token、字体角色、组件规格与骨架模板。已存在页面若与此冲突,以此为准。

> 目的:消除"每份报告一套主题"的割裂。无论谁生成报告、用什么工具,产物都读起来是
> 同一个系统的不同页面。

---

## 1. 主题基调:浅壳 + 深文

站点由两类页面构成,共享同一套 token,呈现为同一系统的明/暗两态:

| 页面类型 | 基调 | 文件 |
|----------|------|------|
| 入口/索引页(顶层、仓库级) | **浅色**(轻盈,适合导航浏览) | `index.html`、`<repo>/index.html` |
| 报告页(实验内容) | **深色**(沉稳,适合长文+数据+代码) | `<repo>/<experiment>/*.html` |

从浅色入口点进深色报告是**有意的明暗切换**,不是割裂——前提是两者共享 accent、字体角色、
间距栅格。读者应能感到"同一个品牌,换了阅读环境",而非"换了一个网站"。

**禁止**:在同一类页面内出现多套主题(如两份深色报告用不同深底/不同 accent)。
报告页必须全部使用本文档第 2 节的深色态 token。

---

## 2. Design Tokens

颜色给出浅态(入口页)与深态(报告页)两列。同一语义名,两态取值。accent 在两态用同色相
的不同明度:浅态 `#6D28D9`(紫 700),深态 `#A78BFA`(紫 400)——品牌紫贯穿全站。

### 颜色

| Token | 浅态(入口页) | 深态(报告页) | 用途 |
|-------|--------------|--------------|------|
| `--bg` | `#F9F9F6` | `#0D1117` | 页面背景 |
| `--surface` | `#FFFFFF` | `#161B22` | 卡片/表格头/代码块底 |
| `--surface-2` | `#F3F3F0` | `#1C2230` | 次级表面(表格头、悬停) |
| `--border` | `#E6E6E2` | `#30363D` | 分隔线、卡片边框 |
| `--text` | `#18181B` | `#E6EDF3` | 正文 |
| `--text-secondary` | `#71717A` | `#8B949E` | 次要正文、说明 |
| `--text-tertiary` | `#6B7280` | `#6B7385` | 标签、meta(须过 WCAG AA 4.5:1) |
| `--accent` | `#6D28D9` | `#A78BFA` | 品牌紫:链接、强调、进度 |
| `--accent-hover` | `#5B21B6` | `#C4B5FD` | 链接悬停 |
| `--success` | `#059669` | `#3FB950` | 达成/改善/正向指标 |
| `--warning` | `#D97706` | `#D29922` | 进行中/警告 |
| `--danger` | `#DC2626` | `#F85149` | 阻塞/失败/负向指标 |
| `--info` | `#2563EB` | `#79C0FF` | 中性信息 |

语义态背景(半透明叠色,深态示例,浅态用对应浅底):

```
--success-bg: rgba(63,185,80,0.12)   --warning-bg: rgba(210,153,34,0.12)
--danger-bg:  rgba(248,81,73,0.12)   --info-bg:    rgba(121,192,255,0.12)
```

### 字体角色(三角色,全站统一)

| 角色 | 字族 | 用于 |
|------|------|------|
| **Display**(标识性) | `'SF Mono','Fira Code',Consolas,monospace` | 报告 H1/H2、入口页大数字(stat/metric value)、日期、tag |
| **Body**(正文) | `-apple-system,'SF Pro Text','Segoe UI',Roboto,'PingFang SC','Microsoft YaHei',sans-serif` | 段落、列表、表格单元、说明文字 |
| **Code**(代码) | `'SF Mono','Fira Code',Consolas,monospace` | `<code>`、`<pre>` |

> 取舍:报告是 NPU 性能工程内容,标题与数据用等宽字体给出"工程控制台"质感,这是全站
> 签名;正文用 sans 保长文可读性。**不要**让正文也变 mono(phase-report 旧版的问题),
> 也不要让标题用 sans(失去辨识度)。

### 间距栅格

基础单位 `4px`。常用:`4 / 8 / 12 / 16 / 20 / 24 / 32 / 48`。
内容最大宽度 `1100px`(报告页)/ `1060px`(入口页),左右 padding `48px`(移动端 `24px`)。

### 圆角

- 卡片、代码块、表格容器:`6px`
- badge/tag/小药丸:`3px`(克制,不胶囊化)
- 入口页卡片:微圆角 `2px` 或直角

---

## 3. 组件规格(报告页,深态)

### Breadcrumb(每份报告顶部必须有)

固定在正文最顶,显示站点归属与返回路径。消除"打开报告即导航死胡同"。

```
versatile-ai / AutoModelWire / DSpark on Ascend NPU / <报告类型>
└─ 链 ../../  └─ 链 ../  └─ 链 ../(锚到实验) └─ 纯文本
```

### TOC(长文必备,section ≥ 4 个时)

顶部目录,每个 `<section>` 须有 `id`,`<h2>` 文案与 TOC 条目一致。sticky 可选。

### Metric / Stat 卡片

大数字(Display,语义色)+ 小标签(uppercase, tertiary)。用于关键指标速查。
网格 `repeat(auto-fit, minmax(180px, 1fr))`。

### Table

`border-collapse: collapse`。表头 `--surface-2` + accent 色文字 + uppercase 11px。
单元 `--border` 下边线。数值列 `tabular-nums` + 右对齐。语义色用 `.ok/.warn/.bad` 类。

### Timeline

左侧 2px 竖线(`--border`),每项 10px 圆点(语义色),日期用 Display + muted。

### Badge / Tag

- Badge(状态药丸):`padding 2px 8px`,语义底(`rgba(*,0.15)`)+ 语义字。
- Tag(技术标签):mono、`--text-tertiary`、`--surface-2` 底。

### Note(强调块)

左侧 3px 语义色竖条 + 半透明语义底。`.note.ok/.warn/.bad` 三态。

### Code block

`--bg` 深一档底(`#010409` 深态)、`--border`、`6px` 圆角、横滚。inline `<code>` 用 `--surface` 底。

### 面包屑下的 Header

H1(Display) + 一行 meta(Body,muted):周期、集群、分支、报告日期。

---

## 4. 报告页骨架模板

生成新报告时照此结构,把 `<style>` 中的 token 块原样复制,只改内容:

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="description" content="<一句话摘要,用于分享预览>">
<title><实验名> — <报告类型> (<日期>)</title>
<style>
  :root {
    /* 深态 token —— 原样复制,勿改值 */
    --bg:#0D1117; --surface:#161B22; --surface-2:#1C2230; --border:#30363D;
    --text:#E6EDF3; --muted:#8B949E; --tertiary:#6B7385;
    --accent:#A78BFA; --accent-hover:#C4B5FD;
    --green:#3FB950; --yellow:#D29922; --red:#F85149; --info:#79C0FF;
    --code-bg:#010409;
  }
  *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
  body{background:var(--bg);color:var(--text);
    font-family:-apple-system,'SF Pro Text','Segoe UI',Roboto,'PingFang SC','Microsoft YaHei',sans-serif;
    font-size:14px;line-height:1.65}
  h1,h2,.stat .v,.metric .v,.tl-date,.tag,.mono{ /* Display 角色 */
    font-family:'SF Mono','Fira Code',Consolas,monospace}
  a{color:var(--accent);text-decoration:none}
  a:hover{text-decoration:underline}
  a:focus-visible{outline:2px solid var(--accent);outline-offset:2px}
  /* …组件样式见第 3 节… */
  @media (prefers-reduced-motion:reduce){*{transition:none!important;animation:none!important}}
  @media print{body{background:#fff;color:#111}}
</style>
</head>
<body>

<!-- Breadcrumb(必须) -->
<nav class="breadcrumb">
  <a href="../../index.html">versatile-ai</a> /
  <a href="../index.html">AutoModelWire</a> /
  <a href="../index.html#<experiment-id>">DSpark on Ascend NPU</a> /
  <span>Phase Report</span>
</nav>

<header>
  <h1><实验标题></h1>
  <div class="meta">Phase Report · 2026-07-14 → 2026-07-22 · Ascend 910B3 4-Node · branch</div>
</header>

<!-- TOC(section ≥ 4 时必须) -->
<nav class="toc"><ol>
  <li><a href="#metrics">关键指标</a></li>
  <!-- …每个 section 一条… -->
</ol></nav>

<main class="container">
  <section id="metrics"><h2>关键指标</h2> … </section>
  <!-- … -->
</main>

<footer>
  Generated 2026-07-22 · <a href="<repo url>">GitHub</a>
</footer>
</body>
</html>
```

---

## 5. 可访问性(硬要求)

- `--text-tertiary` 用于正文级文字时,对背景对比度须 ≥ **4.5:1**(WCAG AA)。本文档取值已校验。
- 所有交互元素(`<a>`、可点卡片)须有 `:focus-visible` 轮廓(`2px solid var(--accent)`)。
- `lang="zh-CN"` 全站统一。
- 报告页加 `<meta name="description">`,直链分享时有预览。
- 动效服从 `prefers-reduced-motion`。

---

## 6. gh-pages 与自包含约束

- 报告产物必须**自包含**:CSS/JS 全内联,无外部依赖、无运行时 fetch、无构建步骤。
  本文档的 token 块应被**复制**进每个报告的 `<style>`,而非 `<link>` 引用。
- 入口/索引页同样自包含(可被 file:// 双击打开)。
- 设计文档(本文件)仅为开发参考,不部署、不影响产物自包含性。

---

## 7. 文件命名约定(统一)

报告文件名统一用 `phase-report-YYYY-MM-DD.html` / `stage-report.html` / `final-report.html`
等**语义名 + 可选日期**。同一实验目录内不要混用两套命名约定。
