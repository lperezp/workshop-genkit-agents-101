#!/bin/bash
# Exporta los codelabs y restaura el GA4 ID
GA4_ID="G-Q3CXWBNR7T"

claat export content/codelab.md
claat export content/codelab-en.md

for dir in workshop-genkit-agents-101 workshop-genkit-agents-101-en; do
  sed -i '' "s/ga4id=\"\"/ga4id=\"$GA4_ID\"/g" "$dir/index.html"
  sed -i '' "s/codelab-ga4id=\"\"/codelab-ga4id=\"$GA4_ID\"/g" "$dir/index.html"
done

echo "Export done. GA4 ID restored: $GA4_ID"
