#!/usr/bin/env bash
# market-calc.sh - TAM/SAM/SOM 计算器
# Usage: bash market-calc.sh <total_users> <avg_price> <geo_ratio> <convert_ratio>
# Example: bash market-calc.sh 100000000 100 0.01 0.05
#   → TAM=100亿, SAM=1亿, SOM=500万
# 依赖: node（跨平台，无需 bc）

set -euo pipefail

if [ $# -lt 4 ]; then
  echo "Usage: $0 <total_users> <avg_price_cny> <geo_ratio> <convert_ratio>"
  echo ""
  echo "  total_users   : TAM 目标用户总数"
  echo "  avg_price_cny : 平均客单价（元）"
  echo "  geo_ratio     : SAM/TAM 比例（你能触达的比例，0-1）"
  echo "  convert_ratio : SOM/SAM 比例（你能转化的比例，0-1）"
  echo ""
  echo "Example: $0 100000000 100 0.01 0.05"
  exit 1
fi

TOTAL_USERS=$1
AVG_PRICE=$2
GEO_RATIO=$3
CONVERT_RATIO=$4

node -e "
const totalUsers = Number('$TOTAL_USERS');
const avgPrice = Number('$AVG_PRICE');
const geoRatio = Number('$GEO_RATIO');
const convertRatio = Number('$CONVERT_RATIO');

const tam = totalUsers * avgPrice;
const sam = tam * geoRatio;
const som = sam * convertRatio;
const tamUsers = totalUsers;
const samUsers = Math.round(totalUsers * geoRatio);
const somUsers = Math.round(totalUsers * geoRatio * convertRatio);

const fmt = (v) => {
  if (v >= 1e8) return (v / 1e8).toFixed(2) + ' 亿元';
  if (v >= 1e4) return (v / 1e4).toFixed(2) + ' 万元';
  return v.toFixed(2) + ' 元';
};

const fmtNum = (n) => n.toLocaleString('en-US');

console.log('=== 市场规模计算 ===');
console.log('');
console.log('输入参数:');
console.log('  目标用户总数: ' + fmtNum(totalUsers));
console.log('  平均客单价:   ¥' + avgPrice);
console.log('  地域覆盖比:   ' + (geoRatio * 100).toFixed(1) + '%');
console.log('  转化率:       ' + (convertRatio * 100).toFixed(1) + '%');
console.log('');
console.log('结果:');
console.log('  TAM (理论最大市场): ' + fmt(tam));
console.log('  SAM (可触达市场):   ' + fmt(sam));
console.log('  SOM (可获取市场):   ' + fmt(som));
console.log('');

// JSON 输出（供报告生成使用）
const json = {
  tam: { users: tamUsers, revenue: tam, formatted: fmt(tam) },
  sam: { users: samUsers, revenue: sam, formatted: fmt(sam) },
  som: { users: somUsers, revenue: som, formatted: fmt(som) }
};
console.log(JSON.stringify(json, null, 2));
"
