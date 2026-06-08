#!/usr/bin/env bash
# generate-report.sh - 从 JSON 数据生成产品决策报告
# Usage: bash generate-report.sh <input.json> [output.md]
# 输入: JSON 文件（各层分析结果）
# 输出: Markdown 报告

set -euo pipefail

INPUT="${1:?Usage: $0 <input.json> [output.md]}"
OUTPUT="${2:-product-report-$(date +%Y%m%d).md}"

if [ ! -f "$INPUT" ]; then
  echo "Error: $INPUT not found"
  exit 1
fi

# 用 node 解析 JSON 并生成报告（内置中文引号处理）
node -e "
const fs = require('fs');
let raw = fs.readFileSync('$INPUT', 'utf-8');
// 替换中文引号为单引号，避免 JSON 解析错误
raw = raw.replace(/[“”‘’「」『』]/g, \"'\");
const data = JSON.parse(raw);
const d = new Date().toISOString().split('T')[0];

const section = (title, content) => \`## \${title}\n\n\${content}\n\n\`;

const table = (headers, rows) => {
  const h = '| ' + headers.join(' | ') + ' |';
  const sep = '| ' + headers.map(() => '---').join(' | ') + ' |';
  const r = rows.map(row => '| ' + row.join(' | ') + ' |').join('\n');
  return h + '\n' + sep + '\n' + r;
};

let report = \`# 产品决策报告

> 产品名称：\${data.name || '{产品名称}'}
> 分析日期：\${d}
> 分析人：\${data.author || '{姓名}'}

---

\`;

// Layer 1
if (data.vision) {
  report += section('一、信念与愿景', \`
### 产品类型
\${data.vision.type || ''}

### 核心信念
\${data.vision.belief || ''}

### 产品哲学
\${data.vision.philosophy || ''}
\`.trim());
}

// Layer 2
if (data.positioning) {
  const p = data.positioning;
  report += section('二、产品定位与市场分析', \`
### 一句话描述
\${p.oneLiner || ''}

### 价值分析

\${table(
  ['维度', '描述'],
  [
    ['用户价值', p.userValue || ''],
    ['商业价值', p.bizValue || ''],
    ['感知价值', p.perceivedValue || '']
  ]
)}

### 市场规模

\${table(
  ['层级', '估算', '依据'],
  [
    ['TAM', p.market?.tam?.formatted || '', p.market?.tam?.reason || ''],
    ['SAM', p.market?.sam?.formatted || '', p.market?.sam?.reason || ''],
    ['SOM', p.market?.som?.formatted || '', p.market?.som?.reason || '']
  ]
)}

### 市场时机

| 维度 | 分析 |
| --- | --- |
| 技术成熟度 | \${p.timing?.tech || ''} |
| 社会/政策环境 | \${p.timing?.social || ''} |
| 竞品窗口期 | \${p.timing?.competition || ''} |

### 竞品分析

\${(p.competitors || []).map((c, i) => \`
**\${c.name}**
- 心智定位: \${c.positioning || ''}
- 弱点: \${c.weakness || ''}
- 用户规模: \${c.users || ''}
\`).join('\n')}

### 差异化定位
\${p.differentiation || ''}
\`.trim());
}

// Layer 3
if (data.users) {
  const u = data.users;
  report += section('三、用户需求分析', \`
### 目标用户

| 维度 | 描述 |
| --- | --- |
| 身份 | \${u.identity || ''} |
| 资源 | \${u.resources || ''} |
| 动机 | \${u.motivation || ''} |

### 用户画像

\${(u.personas || []).map(p => \`
#### \${p.name}，\${p.age}岁，\${p.job}
- 日常行为: \${p.behavior || ''}
- 痛点: \${p.pain || ''}
- 引言: \"\${p.quote || ''}\"
\`).join('\n')}

### 核心场景

**场景描述**: \${u.scene?.description || ''}

**对产品设计的指导**:
\${(u.scene?.guidance || []).map(g => '- ' + g).join('\n')}

### 用户故事

**核心故事**:
> \${u.story?.core || ''}

**辅助故事**:
\${(u.story?.auxiliary || []).map((s, i) => (i+1) + '. ' + s).join('\n')}
\`.trim());
}

// Layer 4
if (data.design) {
  report += section('四、产品设计', \`
### 产品形态
\${data.design.form || ''}

### 设计原则
\${(data.design.principles || []).map(p => '- ' + p).join('\n')}

### 核心页面架构
\${data.design.architecture || ''}

### 用户核心路径
\${data.design.corePath || ''}
\`.trim());
}

// Layer 5
if (data.commercial) {
  const c = data.commercial;
  report += section('五、商业化策略', \`
### 核心价值提炼
\${c.coreValue || ''}

### 定价策略

\${table(
  ['方案', '价格', '理由'],
  (c.pricing || []).map(p => [p.plan, p.price, p.reason])
)}

### 营销故事
\${c.story || ''}

### 内容策略
\${c.contentStrategy || ''}
\`.trim());
}

// Layer 6
if (data.execution) {
  const e = data.execution;
  report += section('六、落地执行', \`
### MVP 功能范围

\${table(
  ['优先级', '功能', '服务的用户故事'],
  (e.mvp || []).map(m => [m.priority, m.feature, m.story])
)}

### 第一批用户
\${e.firstUsers || ''}

### 关键里程碑

\${table(
  ['阶段', '目标', '时间'],
  (e.milestones || []).map(m => [m.phase, m.goal, m.time])
)}

### 验证指标
\${(e.metrics || []).map(m => '- ' + m).join('\n')}
\`.trim());
}

// 风险
if (data.risks && data.risks.length) {
  report += section('七、风险与挑战', table(
    ['风险', '应对策略'],
    data.risks.map(r => [r.risk, r.mitigation])
  ));
}

// 总结
if (data.summary) {
  report += section('八、总结', data.summary);
}

fs.writeFileSync('$OUTPUT', report);
console.log('Report generated: $OUTPUT');
"
