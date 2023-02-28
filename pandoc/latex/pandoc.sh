#!/usr/bin/env bash

# Markdown to LaTeX conversion script    
set -eEu -o pipefail

# Retrieve script source directory as DIR. This allows relative pathing to work
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if pandoc is available
if ! command -v pandoc &> /dev/null 
then
    echo "Error: pandoc is not available. Please install pandoc before running this script."
    exit 1
fi

# If no arguments were provided or the --help/-h flag was passed, print usage information
if [[ $# -eq 0 ]] || [[ $1 == "-h" || $1 == "--help" ]] 
then
    echo "Markdown to LaTeX Converter (w/ Pandoc)"
    echo "Usage: $(basename $0) file1.md [file2.md ...]"
    echo "Convert one or more Markdown files to LaTeX using pandoc."
    exit 0
fi

# Run the command multiple times, once for each file to build.
for file in "$@"
do
    filename="$(basename $file .md)" # Name of the file without extension
    # $DIR    local path of the script 
    # ${file} local path of the file
    
    pandoc "${file}" \
    --defaults "$DIR/defaults.yaml" \
    --to  "$DIR/latex-writer.lua"  \
    --out "$DIR/../../output/latex/${filename}".tex
done