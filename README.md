# Product Pyramid

**产品决策金字塔** — 一套从底层信念到顶层落地的完整产品决策框架，以编程 Agent Skill 形式开源。

> 不把理想信念虚化，而是把它做成高度逻辑化，可以付诸实践的原则。

## 一行安装

```bash
curl -sSL https://raw.githubusercontent.com/Zheng-314/product-pyramid/main/install.sh | bash
```

支持 Claude Code / Codex / Cursor，自动检测已安装的 Agent 并安装到对应目录。

## 它能做什么

输入 `/product-pyramid`，AI Agent 会：

1. **逐层引导分析**：信念→市场→用户→设计→商业化→执行，六层逐一讨论
2. **自动竞品调研**：通过 agent-reach 搜索 ProductHunt、36Kr、GitHub 等平台的真实数据
3. **计算市场规模**：TAM/SAM/SOM 自动计算，带格式化输出
4. **质量检查**：报告生成前自动检查完整性，评分 ≥85% 才允许输出
5. **生成结构化报告**：JSON schema 驱动，输出标准化的产品决策报告

## 支持的 Agent

| Agent | 安装路径 | 状态 |
|-------|---------|------|
| Claude Code | `~/.claude/skills/` | ✅ 支持 |
| Codex | `~/.codex/skills/` | ✅ 支持 |
| Cursor | `~/.cursor/skills-cursor/` | ✅ 支持 |
| WorkBuddy | marketplace | 🔜 计划中 |
| Trae | 内置 | 🔜 计划中 |

## 使用

```
/product-pyramid
```

或者直接说：
- "帮我分析一下这个产品想法"
- "验证一下这个想法"
- "帮我做一下竞品分析"

### 使用示例

```
你: /product-pyramid

Claude: Phase 0: 收集产品信息
请告诉我：
1. 产品名称是什么？
2. 一句话描述：这个产品为谁解决了什么问题？
3. 目标用户是谁？
4. 当前阶段：想法 / 原型 / MVP / 已上线？

你: 产品叫 IdeaCraft，为想要分析自己想法的人给一张结构化的专业分析报告...

Claude: [逐层引导分析，最终生成完整的产品决策报告]
```

### 完整报告示例

查看 [IdeaCraft 产品决策报告](examples/ideacraft-report.md) — 一个真实产品的完整分析报告，展示了框架的输出质量。

## 框架来源

基于产品决策金字塔方法论：

| 层级 | 主题 | 核心内容 |
|------|------|---------|
| 第一层 | 信念与思维 | 理想信念、产品哲学、思维方式 |
| 第二层 | 产品定位与市场 | TAM/SAM/SOM、市场时机、竞品分析 |
| 第三层 | 用户需求分析 | 身份/资源/动机、用户画像、场景、故事 |
| 第四层 | UI/UX 设计 | 设计原则、信息架构、交互流程 |
| 第五层 | 商业化 | 核心价值、定价、营销 |
| 第六层 | 落地执行 | MVP、里程碑、验证指标 |

## 依赖

- **Node.js** — 脚本运行环境（几乎所有系统都有）
- **[agent-reach](https://github.com/Zheng-314/agent-reach)** — 用于竞品调研和市场数据搜索（可选，没有则手动输入数据）

## 目录结构

```
product-pyramid/
├── SKILL.md                    # 主入口：流程编排和规则
├── README.md                   # 本文件
├── LICENSE                     # MIT License
├── install.sh                  # 一行安装脚本
├── references/                 # 方法论详述（逐层）
│   ├── 01-vision.md            # 理想信念 & 产品哲学
│   ├── 02-positioning.md       # 产品定位 & 市场分析（TAM/SAM/SOM、竞品）
│   ├── 03-user-insight.md      # 用户需求（画像、场景、故事、MVP）
│   ├── 04-design.md            # UI/UX 设计原则
│   └── 05-commercial.md        # 商业化策略（定价、营销十法）
├── scripts/                    # 可执行工具
│   ├── market-calc.sh          # TAM/SAM/SOM 计算器（node 实现，跨平台）
│   ├── competitor-research.sh  # 竞品研究搜索查询生成
│   ├── quality-check.sh        # 报告质量检查（23项检查，评分系统）
│   ├── generate-report.sh      # JSON → Markdown 报告生成
│   └── schema.json             # 报告数据结构定义（JSON Schema）
└── templates/
    └── report.md               # 报告模板
```

## 脚本说明

### market-calc.sh — 市场规模计算器

```bash
bash scripts/market-calc.sh <total_users> <avg_price_cny> <geo_ratio> <convert_ratio>

# 示例
bash scripts/market-calc.sh 65000000 120 0.08 0.03
# → TAM=78亿, SAM=6.24亿, SOM=1872万
```

### quality-check.sh — 质量检查

```bash
bash scripts/quality-check.sh <report.json>

# 输出示例：
# === 产品决策报告质量检查 ===
# 总评分: 100% (23/23)
# ✓ Layer 1: 理想信念: 3/3 (100%)
# ✓ Layer 2: 市场分析: 8/8 (100%)
# ...
# 质量等级: A+ — 完美，可以直接输出报告
```

### generate-report.sh — 报告生成

```bash
bash scripts/generate-report.sh <input.json> [output.md]

# 示例
bash scripts/generate-report.sh data.json report.md
```

## License

MIT
