# Polytexy

![Polytexy Logo.](./logo.png)

Command-line utility that converts Markdown files into well-formed PDFs, EPUBs, and stand-alone HTML files.

## Features

* Polytexy's generated PDF files use the [Humanize](https://github.com/ShenZhouHong/latex-essay) LaTeX documentclass, a best-in-class LuaLaTeX template for academic typesetting.
* Polytexy outputs EPUB files with properly formatted tags and metadata, allowing for easy use and distribution on mobile devices.
* Stand-alone HTML files with embedded fonts allows for content to be shared on static site servers.

## Examples

Here are some examples of polytexy's outputs. Given the following markdown file (lorem ipsum): 

* [Example markdown input](./example.md)

Polytexy outputs the following:

* [Example PDF output](./example.pdf)

EPUB and HTML output examples will be provided later.

## Installation

Polytexy is a bash script which uses `pandoc`, `latexmk`, `lualatex`, and `python` in order to convert markdown documents into well-formed PDFs, EPUBs, and stand-alone HTML files. In order to use polytexy, first make sure that all dependencies are installed and available:

```bash
sudo apt install pandoc latexmk texlive
```

Next, ensure the `polytexy` file is given executable permissions.


```bash
sudo chmod +x polytexy
```

The `polytexy` script is now ready for use. In order to have the command available for the user, ensure that the directory is available within your `$PATH`. This can be done by adding the following line to your `~/.bashrc` file:

```bash
# Append the polytexy directory to the user's $PATH
PATH="/path/to/polytexy":$PATH
```

Now run `source ~/.bashrc` or restart your terminal, in order to have the changes take effect.

## Usage

Polytexy takes one (or more) markdown files as inputs, and converts them into PDF, HTML, and EPUB files.

```
Polytexy: Markdown to PDF, HTML, & EPUB Converter
    Usage: polytexy.sh file1.md [file2.md ...]
    Convert one or more .md files to .pdf, .html, & .epub (w/ pandoc)
```

### Using `polytexy` on the command line

For a quick test, you may run `polytexy` on the provided `example.md` file in this repository.

```
polytexy example.md
```

The utility will generate `example.pdf`, `example.html`, and `example.epub`.

### Using `polytexy` with `make`

Polytexy can also be used to compile multiple markdown files in a directory using a makefile. Here is a sample makefile that outputs PDF files from markdown files in a directory:

```make
# Makefile for converting Markdown (.md) files to PDF using 'polytexy'

# Find all Markdown (.md) files in the current directory, excluding those in IGNORE_FILES
IGNORE_FILES := README.md
MARKDOWN_FILES := $(filter-out $(IGNORE_FILES), $(wildcard *.md))

# Create a list of PDF filenames by replacing the .md extension with .pdf
PDF_FILES := $(MARKDOWN_FILES:.md=.pdf)

# Default target: Convert all Markdown files to PDF
all: $(PDF_FILES)

# Rule for converting a .md file to a .pdf file
%.pdf: %.md
	polytexy $<

# Target for cleaning up generated PDF files
clean:
	rm -f $(PDF_FILES)

# Declare 'all' and 'clean' as phony targets (not files)
.PHONY: all clean
```

After saving the above file as `makefile` in the directory with the markdown source files, it can be invoked by running `make` on the command line:

```bash
make
```

## Markdown Metadata

In order to generate the output files with the correct metadata, `polytexy` requires additional information specified as a `yaml` file at the beginning of every markdown document. The following snippet is an example of the metadata fields supported.

Note that some fields such as `title`, `author`, and `date` are required.

```yaml
--- 
# General document information (title, author, and date required)
title: Test Document 1
subtitle: Test document subtitle
author: # Supports both single author value, or list of multiple authors
    - John Smith
    - Jane Doe
description: |
    File description test string.
date: 2020-12-26
lang: en-US

# PDF/A metadata (all optional)
url_link: https://example.com/
git_link: https://example.com/

# LaTeX specific options (all optional)
documentclass:
    - protrudelabels    # Remove to disable label protrusion
    - onehalfspacing    # or doublespacing, singlespacing
    - extraligatures    # Remove for less decorative ligatures
    - notitlepage       # or titlepage
    - widemargins       # For LaTeX-style wide margins. Remove for narrower margins
    - nosectionnumbers  # Disable section numbering
    - a4paper

# Titling and Table of Content Options (all optional)
maketitle:
    omitdate: false         # Do not typeset the date in the title
    omitauthor: false       # Do not typeset the author in the title
maketoc:
    clearpage: true         # Set the table of contents on its own page.

# Fancyhdr options for headers and footers (all optional)
header:
    left: Polytexy
    center:
    right: Example
footer:
    left: Footer Left
    center:
    right: Footer Right

csquotes: true
---
```

## License and credits

Polytexy is available under AGPLv3.

Polytexy depends on [pandoc](https://github.com/jgm/pandoc), a universal document converter written by John MacFarlane. Pandoc is licensed under GPLv2.

