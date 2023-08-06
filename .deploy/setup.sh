#!/usr/bin/env bash

# Install dependencies
echo "----------"
echo "Installing dependencies"
echo "----------"

pip install mkdocs-material

echo "----------"
echo "Successfully installed dependencies"
echo "----------"


# Setup MKDocs directory
echo "----------"
echo "Setting up new mkdocs directory"
echo "----------"

# create and load MKDocs configuration
cd .
cat > mkdocs.yml << EOF
# MKDocs config document
site_name: docusaurus-local

theme:
    name: material
    palette:
        primary: blue
    features:
        - navigation.path

nav:
    - documentation:
        - index.md
    - sub-section:
        - additional.md

copyright: Copyright; 2023 - Sev1Tech
extra:
    generator: false
EOF

echo "creating index.md"

# Create and load initial index.md
cd ./
mkdir docs
cd ./docs
cat > index.md << EOF
# Welcome to Docusaurus - docusaurus-static
To find out more, see [mkdocs.org](https://www.mkdocs.org). 

## commands
`mkdocs -h` for help

## Project Layout
    mkdocs.yml    # The configuration file.
    docs/
        index.md  # The documentation homepage.
        ...       # Other markdown pages, images and other files.
EOF

# Create and load initial "additional" content
cd ./docs
cat > additional.md << EOF
# Start Making Documentation
Share with your team.
EOF

echo " ----> EVERYTHING IS GOOD TO GO <----"
echo "ctrl-c to stop local web server"


# return to root and serve mkdocs
cd ../
mkdocs serve