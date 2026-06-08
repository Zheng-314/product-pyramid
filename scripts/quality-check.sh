#!/usr/bin/env bash
# quality-check.sh - 检查产品决策报告的完整性
# Usage: bash quality-check.sh <report.json>
# 输出: 质量评分和缺失项

set -euo pipefail

INPUT="${1:?Usage: $0 <report.json>}"

if [ ! -f "$INPUT" ]; then
  echo "Error: $INPUT not found"
  exit 1
fi

# 用 node 处理中文引号问题并执行检查
node -e "
const fs = require('fs');
let raw = fs.readFileSync('$INPUT', 'utf-8');
// 替换中文引号为单引号
raw = raw.replace(/[“”‘’「」『』]/g, \"'\");
const data = JSON.parse(raw);

const checks = [
  { layer: 'Layer 1: 理想信念', field: 'vision.type', label: '产品类型', required: true },
  { layer: 'Layer 1: 理想信念', field: 'vision.belief', label: '核心信念', required: true },
  { layer: 'Layer 1: 理想信念', field: 'vision.philosophy', label: '产品哲学', required: true },
  { layer: 'Layer 2: 市场分析', field: 'positioning.oneLiner', label: '一句话描述', required: true },
  { layer: 'Layer 2: 市场分析', field: 'positioning.userValue', label: '用户价值', required: true },
  { layer: 'Layer 2: 市场分析', field: 'positioning.market.tam', label: 'TAM 估算', required: true },
  { layer: 'Layer 2: 市场分析', field: 'positioning.market.sam', label: 'SAM 估算', required: true },
  { layer: 'Layer 2: 市场分析', field: 'positioning.market.som', label: 'SOM 估算', required: true },
  { layer: 'Layer 2: 市场分析', field: 'positioning.timing', label: '市场时机分析', required: true },
  { layer: 'Layer 2: 市场分析', field: 'positioning.competitors', label: '竞品分析', required: true },
  { layer: 'Layer 2: 市场分析', field: 'positioning.differentiation', label: '差异化定位', required: true },
  { layer: 'Layer 3: 用户需求', field: 'users.identity', label: '用户身份', required: true },
  { layer: 'Layer 3: 用户需求', field: 'users.motivation', label: '用户动机', required: true },
  { layer: 'Layer 3: 用户需求', field: 'users.personas', label: '用户画像', required: true },
  { layer: 'Layer 3: 用户需求', field: 'users.scene', label: '核心场景', required: true },
  { layer: 'Layer 3: 用户需求', field: 'users.story.core', label: '核心用户故事', required: true },
  { layer: 'Layer 4: 产品设计', field: 'design.form', label: '产品形态', required: true },
  { layer: 'Layer 4: 产品设计', field: 'design.corePath', label: '核心路径', required: true },
  { layer: 'Layer 5: 商业化', field: 'commercial.coreValue', label: '核心价值', required: true },
  { layer: 'Layer 5: 商业化', field: 'commercial.pricing', label: '定价策略', required: true },
  { layer: 'Layer 6: 落地执行', field: 'execution.mvp', label: 'MVP 范围', required: true },
  { layer: 'Layer 6: 落地执行', field: 'execution.firstUsers', label: '第一批用户', required: true },
  { layer: 'Layer 6: 落地执行', field: 'execution.metrics', label: '验证指标', required: true },
];

function get(obj, path) {
  return path.split('.').reduce((o, k) => (o && o[k] !== undefined) ? o[k] : null, obj);
}

function isValid(val) {
  if (val === null || val === undefined) return false;
  if (typeof val === 'string') return val.trim().length > 0 && !val.includes('{');
  if (Array.isArray(val)) return val.length > 0;
  if (typeof val === 'object') return Object.keys(val).length > 0;
  return true;
}

let total = 0, passed = 0, failed = [];
let layerStats = {};

for (const check of checks) {
  total++;
  const val = get(data, check.field);
  const ok = isValid(val);

  if (!layerStats[check.layer]) layerStats[check.layer] = { total: 0, passed: 0 };
  layerStats[check.layer].total++;

  if (ok) {
    passed++;
    layerStats[check.layer].passed++;
  } else {
    failed.push(check);
  }
}

const score = Math.round((passed / total) * 100);

console.log('=== 产品决策报告质量检查 ===');
console.log('');
console.log('总评分: ' + score + '% (' + passed + '/' + total + ')');
console.log('');

for (const [layer, stat] of Object.entries(layerStats)) {
  const icon = stat.passed === stat.total ? '✓' : '✗';
  const pct = Math.round((stat.passed / stat.total) * 100);
  console.log(icon + ' ' + layer + ': ' + stat.passed + '/' + stat.total + ' (' + pct + '%)');
}

if (failed.length > 0) {
  console.log('');
  console.log('--- 缺失项 ---');
  for (const f of failed) {
    console.log('  ✗ [' + f.layer + '] ' + f.label + ' (' + f.field + ')');
  }
}

console.log('');

let grade;
if (score >= 95) grade = 'A+ — 完美，可以直接输出报告';
else if (score >= 85) grade = 'A — 优秀，补充缺失项后输出';
else if (score >= 70) grade = 'B — 良好，有几个关键项需要补充';
else if (score >= 50) grade = 'C — 及格，多个关键项缺失';
else grade = 'D — 不及格，需要大幅补充';

console.log('质量等级: ' + grade);
console.log(JSON.stringify({ score, grade, total, passed, failed: failed.map(f => f.field) }));
"
