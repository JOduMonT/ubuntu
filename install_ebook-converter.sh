#!/usr/bin/env bash
set -euo pipefail

# Convert EPUB and PDF to Markdown

apt install -y pandoc poppler-utils

## pandoc book.epub -t markdown -o book.md
## pdftotext book.pdf book.md
