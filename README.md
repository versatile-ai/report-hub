# report-hub

versatile-ai 各仓库的自包含 HTML 报告聚合站点。仓库级 `index.html` 做多仓库导航,每个仓库在子目录下维护自己的实验/报告页面。

## 目录结构

```
report-hub/
├── index.html              # 仓库级聚合入口(versatile-ai 全局导航)
├── automodelwire/            # AutoModelWire 仓库的静态报告
│   ├── index.html          # AutoModelWire 仓库级导航(从 gh-pages 迁移)
│   └── deepseek-v4-npu-dspark/
│       ├── 2026-07-19-stage-report.html
│       └── 2026-07-22-phase-report.html
└── <其他仓库>/             # 未来新增仓库按同样规则建子目录
    └── index.html
```

## 新增仓库报告

1. 在仓库根建子目录(目录名建议与 GitHub 仓库名一致,全小写)。
2. 把该仓库的静态 HTML 报告放进子目录,保留仓库内相对路径,确保 `子目录/index.html` 可作为仓库级导航。
3. 在顶层 `index.html` 的 `REPOS` 数组追加一项:`{id,name,path:"<子目录>/",gh,desc,tags,lastUpdate}`。顶层只登记仓库级元数据,**不复制**实验数/报告数等聚合统计——那些由各仓库子目录 `index.html` 自报,避免双源漂移。

## 本地预览

```bash
cd report-hub
python3 -m http.server 8000
# 浏览器打开 http://localhost:8000
```

## 迁移来源

- AutoModelWire `gh-pages` 分支(`ef62f75`):`index.html` 与 `deepseek-v4-npu-dspark/2026-07-19-stage-report.html`(原 `stage-report.html`),原样迁入 `automodelwire/` 子目录,报告内部相对链接保持不变。
