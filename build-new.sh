#!/bin/bash

lang=$1

if [ $(uname) == "Darwin" ]
then
    soext="dylib"
else
    soext="so"
fi

# Retrieve sources.
git clone "https://github.com/tree-sitter/tree-sitter-${lang}.git" \
    --depth 1
cp tree-sitter-lang.in "tree-sitter-${lang}/src"
cp emacs-module.h "tree-sitter-${lang}/src"
cp "tree-sitter-${lang}/grammar.js" "tree-sitter-${lang}/src"
cd "tree-sitter-${lang}/src"

# The dynamic module's c source.

# Build.
cc -c -I. parser.c
# Compile scanner.c.
if test -f scanner.c
then
    cc -fPIC -c -I. scanner.c
fi
# Compile scanner.cc.
if test -f scanner.cc
then
    c++ -fPIC -I. -c scanner.cc
fi
# Link.
if test -f scanner.cc
then
    c++ -fPIC -shared *.o -o "libtree-sitter-${lang}.${soext}"
else
    cc -fPIC -shared *.o -o "libtree-sitter-${lang}.${soext}"
fi

# Copy out.

mkdir -p ../../dist
cp "libtree-sitter-${lang}.${soext}" ../../dist
cd ../../
rm -rf "tree-sitter-${lang}"
