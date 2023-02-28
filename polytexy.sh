#!/usr/bin/env bash

set -eEu -o pipefail

# Retrieve script source directory as DIR. This allows relative pathing to work
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Iterate over the array and check if each dependency is available
dependencies=(pandoc latexmk lualatex)
for dependency in "${dependencies[@]}"
do
    if ! command -v "${dependency}" &> /dev/null
    then
        echo "Error: ${dependency} is not available. Please install ${dependency} before running this script."
        exit 1
    fi
done

# Define a function for printing usage instructions
print_usage() {
    echo "Polytexy: Markdown to PDF, HTML, & EPUB Converter"
    echo "    Usage: $(basename $0) file1.md [file2.md ...]"
    echo "    Convert one or more .md files to .pdf, .html, & .epub (w/ pandoc)"
}

# If no arguments were provided or the --help/-h flag was passed, print usage information
if [[ $# -eq 0 ]] || [[ $1 == "-h" || $1 == "--help" ]] 
then
    print_usage
    exit 0
fi

build_html() {
    local file="$1"
    local filename="$(basename "$file" .md)"
    pandoc "$file" --defaults "$DIR/pandoc/html/defaults.yaml" --out "$filename.html"
}

build_epub() {
    local file="$1"
    local filename="$(basename "$file" .md)"
    pandoc "$file" --defaults "$DIR/pandoc/epub/defaults.yaml" --out "$filename.epub"
}

build_latex() {
    local file="$1"
    local filename="$(basename "$file" .md)"
    pandoc "${file}" \
    --defaults "$DIR/pandoc/latex/defaults.yaml" \
    --to       "$DIR/pandoc/latex/latex-writer.lua"  \
    --out      "${filename}".tex
}

build_pdf() {
    local file="$1"
    local filename="$(basename "$file" .md)"

    # Temporarily set ./pandoc/latex as a TEXINPUT, so our class files can be found by latexmk.
    export TEXINPUTS=".:$DIR/pandoc/latex:"

    # Build PDF from LaTeX source file via LuaLaTeX
    latexmk -silent -pdf -lualatex -outdir=. "${filename}".tex

    # Cleanup LaTeX Build Artifacts
    latexmk -silent -c
    rm -v "${filename}.xmpdata"
    rm -v "${filename}.tex"
    rm -v "pdfa.xmpi"
}

# ${file} local path of the file
for file in "$@"
do
    # First, check if the file has .md extension
    if [[ ! $file == *.md ]]
    then
        echo "Error: $file does not have .md extension. Conversion stopped."
        exit 1
    fi

    build_html  ${file}
    build_epub  ${file}
    build_latex ${file}
    build_pdf   ${file}
    echo "Successfully converted ${file} into PDF, HTML, and EPUB."
done