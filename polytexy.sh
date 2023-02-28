#!/usr/bin/env bash

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
    echo "Polytexy: Markdown to PDF, HTML, & EPUB Converter"
    echo "    Usage: $(basename $0) file1.md [file2.md ...]"
    echo "    Convert one or more .md files to .pdf, .html, & .epub (w/ pandoc)"
    exit 0
fi

# Temporarily set ./pandoc/latex as a TEXINPUT, so our class files can be found by latexmk.
export TEXINPUTS=".:$DIR/pandoc/latex:"

# Run the command multiple times, once for each file to build.
# ${file} local path of the file
for file in "$@"
do
    filename="$(basename $file .md)" # Name of the file without extension

    # For HTML
    pandoc "${file}" \
    --defaults "$DIR/pandoc/html/defaults.yaml" \
    --out      "${filename}".html

    # For EPUB
    pandoc "${file}" \
    --defaults "$DIR/pandoc/epub/defaults.yaml" \
    --out      "${filename}".epub

    # For PDF via LaTeX
    pandoc "${file}" \
    --defaults "$DIR/pandoc/latex/defaults.yaml" \
    --to       "$DIR/pandoc/latex/latex-writer.lua"  \
    --out      "${filename}".tex

    # Build PDF from LaTeX via LuaLaTeX
    latexmk -pdf -lualatex -outdir=. "${filename}".tex

    # Cleanup LaTeX Build Artifacts
    latexmk -c
    rm "${filename}.xmpdata"
    rm "${filename}.tex"
    rm "pdfa.xmpi"
done