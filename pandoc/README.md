# About the `./pandoc` directory

The `pandoc/` directory contains the core configuration which allows `polytexy` to work. Polytexy depends upon a set of custom pandoc writers and filters to generate PDFs, EPUBs, and stand-alone htmls, and this directory contains their configuration.

```
.
├── epub/
├── fonts/
├── html/
├── latex/
├── ae-ligature.csv
├── oe-ligature.csv
├── diaeresis.csv
├── custom.csv
├── string-substitution.py
└── utilities.lua
```