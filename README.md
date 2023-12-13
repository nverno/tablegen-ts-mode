## tablegen-ts-mode - Emacs major mode for TableGen from LLVM

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

A major mode for editing TableGen files. 

This mode provides the following features for TableGen source buffers:

  - font-locking
  - indentation
  - structural navigation with tree-sitter objects
  - imenu
  
![example](doc/tablegen.png)

## Installation

Emacs 29.1 or above with tree-sitter support is required. 

Tree-sitter starter guide: https://git.savannah.gnu.org/cgit/emacs.git/tree/admin/notes/tree-sitter/starter-guide?h=emacs-29

### Install tree-sitter parser for TableGen

```elisp
(add-to-list
 'treesit-language-source-alist
 '(tablegen "https://github.com/Flakebi/tree-sitter-tablegen"))
(treesit-install-language-grammar 'tablegen)
```

### Install tablegen-ts-mode.el from source

- Clone this repository
- Add the following to your emacs config

```elisp
(require "[cloned nverno/tablegen-ts-mode]/tablegen-ts-mode.el")
```
