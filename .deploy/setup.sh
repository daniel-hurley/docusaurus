#!/usr/bin/env bash

#                                                   Install dependencies
pip install mkdocs-material


#                                                   Setup MKDocs directory (if non-existent)
cd .
mkdocs="./mkdocs.yml"

if [[ -f "$mkdocs" ]]; then
    echo "File $mkdocs exists, skipping."
else
    echo "File $mkdocs does not exist, creating."
    cat > mkdocs.yml << EOF
# MKDocs config document
site_name: docusaurus

theme:
    name: material
    logo: assets/docusaurus-logo.png
    favicon: assets/docusaurus-logo.png
    palette:
        primary: blue

nav:
    - Home: index.md
    - Structure: format/start.md
    - Hardware:
        - Start: hardware/start.md
        - abstract: hardware/abstract/start.md
        - cpu-arch: hardware/cpu-arch/start.md
    - Network Engineering:
        - Start: net-eng/start.md
        - Network Engineering: net-eng/*
    - Software Engineering:
        - Start: soft-eng/start.md
        - Software Engineering: soft-eng/*
    - Systems Engineering:
        - Start: sys-eng/start.md
        - Linux: sys-eng/linux/linux.md

markdown_extensions:
    - toc:
        permalink: true

plugins:
    - search


copyright: Copyright; 2023 - Docusaurus
extra:
    generator: false
EOF
fi
#                                                   Create and load initial index.md
if [ -f "./readme.md" ]; then
    cp ./readme.md ./docs/index.md
    echo "appended text" >> ./docs/index.md
else
    echo "readme.md not found!"
fi

#                                                   return to root and serve mkdocs
mkdocs serve