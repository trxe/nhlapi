#/bin/bash

pandoc --standalone --css=styling.css -V lang=en -V highlighting-css= --mathjax \
       -t markdown-smart --to=html5 README.md -o index.html