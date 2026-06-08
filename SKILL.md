---
name: product-pyramid
description: 产品决策金字塔——按六层框架（信念→市场→用户→设计→商业化→执行）系统化分析产品想法，自动做竞品调研、市场数据收集、TAM/SAM/SOM 计算，最终生成结构化产品决策报告。Use when user wants to validate a product idea, do product analysis, create a product report, market research, or says "产品分析" / "验证想法" / "产品金字塔" / "竞品分析".
---

# 产品决策金字塔

从底层信念到顶层落地的完整产品决策框架。不把理想信念虚化，而是做成高度逻辑化、可付诸实践的原则。

## 数据结构

分析过程中持续填充 JSON 数据，schema 见 [scripts/schema.json](scripts/schema.json)。最终通过 [scripts/generate-report.sh](scripts/generate-report.sh) 生成报告。

## 流程

### Phase 0: 收集产品信息

向用户收集：
- 产品名称和一句话描述
- 目标用户群体
- 当前阶段（想法/原型/MVP/已上线）

如果有具体产品，用 `/agent-reach` 搜索产品现状（ProductHunt、36Kr、GitHub）。

### Phase 1: 理想信念与产品哲学
→ [references/01-vision.md](references/01-vision.md)

交互式引导，逐个问题讨论：
1. 底层动力是什么？使命驱动还是体验驱动？
2. 产品类型判断：改变世界 vs 做好一个产品（依据：影响人群规模和程度）
3. 如果是改变世界的产品：判断是否依赖用户、效率是否远高于现有方案

每回答一个问题，填充 `vision` 字段。

### Phase 2: 产品定位与市场分析
→ [references/02-positioning.md](references/02-positioning.md)

**真实数据收集**：
1. 用 `/agent-reach` 搜索竞品信息，填充 `positioning.competitors[]`
2. 搜索市场规模报告、行业数据
3. 用 `scripts/competitor-research.sh <keyword> --json` 生成搜索查询

**计算市场规模**：
```bash
bash scripts/market-calc.sh <total_users> <avg_price> <geo_ratio> <convert_ratio>
```

**交互式引导**：
1. 一句话描述、用户价值、商业价值
2. TAM/SAM/SOM（用真实数据支撑，不要编造）
3. 市场时机：技术成熟度、社会环境、竞品窗口期
4. 竞品四象限定位和心智差异化分析

### Phase 3: 用户需求分析
→ [references/03-user-insight.md](references/03-user-insight.md)

交互式引导：
1. 身份、资源、动机三维度分析
2. 创建 1-3 个用户画像（带姓名、年龄、行为、痛点、引言）
3. 核心场景描述（时间、地点、情绪、行为）
4. 核心用户故事 + MVP 范围定义

### Phase 4: UI/UX 设计原则
→ [references/04-design.md](references/04-design.md)

交互式引导：
1. 产品形态确认（硬件/Web/移动端/AI原生）
2. 核心页面信息架构
3. 用户核心路径（从进入到完成目标的最短路径）

### Phase 5: 商业化策略
→ [references/05-commercial.md](references/05-commercial.md)

交互式引导：
1. 核心价值提炼（"如果只宣传一个点"思路）
2. 定价策略（用竞品价格数据支撑）
3. 营销故事和内容策略

### Phase 6: 落地执行

综合前五层，明确：
1. MVP 功能范围（P0/P1/P2 优先级）
2. 第一批用户来源
3. 关键里程碑和验证指标
4. 风险与应对策略

## 生成报告

1. 将所有分析结果写入 `/tmp/product-report.json`（遵循 schema.json 格式）
2. 运行质量检查：
   ```bash
   bash scripts/quality-check.sh /tmp/product-report.json
   ```
3. 如果评分 < 85%，补充缺失项后重新检查
4. 评分达标后生成报告：
   ```bash
   bash scripts/generate-report.sh /tmp/product-report.json product-report.md
   ```
5. 展示报告给用户，确认后保存

## 规则

1. **逐层推进**：完成当前层再进入下一层，不跳过
2. **真实数据**：竞品、市场数据用 agent-reach 搜索，不要编造。找不到的数据标注"待验证"
3. **给出建议**：每个问题先给推荐答案，让用户确认或修改
4. **追问深入**：回答模糊或矛盾时追问直到清晰
5. **诚实反馈**：想法有明显问题直接指出，不说好话
6. **质量门控**：报告生成前必须通过质量检查（≥85%）
