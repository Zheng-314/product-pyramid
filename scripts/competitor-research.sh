#!/usr/bin/env bash
# competitor-research.sh - 竞品研究辅助脚本
# Usage: bash competitor-research.sh <product_keyword> [--json]
# 通过 agent-reach 的能力搜索竞品信息
# 注意: 此脚本生成搜索查询，实际搜索由 Claude 通过 agent-reach 执行

set -euo pipefail

KEYWORD="${1:?Usage: $0 <product_keyword> [--json]}"
JSON_MODE="${2:-}"

# 生成搜索查询列表
QUERIES=(
  "$KEYWORD 竞品分析"
  "$KEYWORD 市场规模"
  "$KEYWORD alternatives"
  "$KEYWORD vs competitors"
  "site:producthunt.com $KEYWORD"
  "site:36kr.com $KEYWORD"
)

if [ "$JSON_MODE" = "--json" ]; then
  echo "{"
  echo "  \"keyword\": \"$KEYWORD\","
  echo "  \"queries\": ["
  for i in "${!QUERIES[@]}"; do
    comma=","
    if [ $i -eq $((${#QUERIES[@]} - 1)) ]; then comma=""; fi
    echo "    \"${QUERIES[$i]}\"$comma"
  done
  echo "  ],"
  echo "  \"sources\": ["
  echo "    {\"name\": \"ProductHunt\", \"url\": \"https://www.producthunt.com/search?q=$KEYWORD\"},"
  echo "    {\"name\": \"36Kr\", \"url\": \"https://36kr.com/search/articles/$KEYWORD\"},"
  echo "    {\"name\": \"Crunchbase\", \"url\": \"https://www.crunchbase.com/textsearch?q=$KEYWORD\"},"
  echo "    {\"name\": \"GitHub\", \"url\": \"https://github.com/search?q=$KEYWORD&type=repositories\"}"
  echo "  ]"
  echo "}"
else
  echo "=== 竞品研究搜索查询 ==="
  echo ""
  echo "关键词: $KEYWORD"
  echo ""
  echo "建议搜索查询:"
  for q in "${QUERIES[@]}"; do
    echo "  - $q"
  done
  echo ""
  echo "建议搜索来源:"
  echo "  - ProductHunt: https://www.producthunt.com/search?q=$KEYWORD"
  echo "  - 36Kr: https://36kr.com/search/articles/$KEYWORD"
  echo "  - Crunchbase: https://www.crunchbase.com/textsearch?q=$KEYWORD"
  echo "  - GitHub: https://github.com/search?q=$KEYWORD&type=repositories"
fi
