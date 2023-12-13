;;; tablegen-ts-mode.el --- Major mode for LLVM TableGen -*- lexical-binding: t; -*-

;; Author: Noah Peart <noah.v.peart@gmail.com>
;; URL: https://github.com/nverno/tablegen-ts-mode
;; Version: 0.0.1
;; Package-Requires: ((emacs "29.1"))
;; Created: 12 December 2023
;; Keywords: languages llvm tablegen

;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:
;; Major mode for LLVM TableGen files.
;;; Code:

(require 'treesit)
(require 'c-ts-common)                  ; comment indentation + filling


(defcustom tablegen-ts-mode-indent-level 2
  "Number of spaces for each indententation step."
  :group 'tablegen
  :type 'integer
  :safe 'integerp)

(defface tablegen-ts-mode-class-face
  '((t (:inherit font-lock-function-name-face)))
  "Face for class names in `tablegen-ts-mode'."
  :group 'tablegen-ts)

;;; Syntax

(defvar tablegen-ts-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?+   "."      table)
    (modify-syntax-entry ?-   "."      table)
    (modify-syntax-entry ?=   "."      table)
    (modify-syntax-entry ?_   "_"      table)
    (modify-syntax-entry ?%   "_"      table)
    (modify-syntax-entry ?!   "_"      table)
    (modify-syntax-entry ?$   "' _"    table)
    (modify-syntax-entry ?<   "("      table)
    (modify-syntax-entry ?>   ")"      table)
    (modify-syntax-entry ?|   "."      table)
    (modify-syntax-entry ?\'  "\""     table)
    (modify-syntax-entry ?\240 "."     table)
    (modify-syntax-entry ?/   ". 124b" table)
    (modify-syntax-entry ?*   ". 23"   table)
    (modify-syntax-entry ?\n  "> b"    table)
    (modify-syntax-entry ?\^m "> b"    table)
    table)
  "Syntax table for `tablegen-ts-mode'.")

;;; Indentation

(defvar tablegen-ts-mode--indent-rules
  `((tablegen
     ((parent-is "file") parent 0)
     ((node-is ")") parent-bol 0)
     ((node-is "}") parent-bol 0)
     ((node-is "]") parent-bol 0)
     ((node-is "preprocessor") parent-bol 0)
     ((and (parent-is "multiline_comment") c-ts-common-looking-at-star)
      c-ts-common-comment-start-after-first-star -1)
     ;; ((parent-is "multiline_comment") prev-adaptive-prefix 0)
     ((parent-is "code_string") no-indent)
     (no-node parent-bol 0)
     (catch-all parent-bol tablegen-ts-mode-indent-level)))
  "Tree-sitter indentation rules for `tablegen-ts-mode'.")

;;; Font-Lock

(defvar tablegen-ts-mode--feature-list
  '(( comment definition)
    ( keyword string)
    ( variable type constant number assignment function)
    ( operator bracket delimiter))
  "`treesit-font-lock-feature-list' for `tablegen-ts-mode'.")

(defvar tablegen-ts-mode--keywords
  '("class" "field" "code"
    "let" "defvar" "def" "defset" "defm"
    "foreach" "in" "if" "then" "else"
    "multiclass" "assert")
  "TableGen keywords for tree-sitter font-locking.")

(defvar tablegen-ts-mode--font-lock-settings
  (treesit-font-lock-rules
   :default-language 'tablegen

   :feature 'keyword
   `(["include" (preprocessor)] @font-lock-preprocessor-face
     [,@tablegen-ts-mode--keywords "!cond" (operator_keyword)] @font-lock-keyword-face
     ((comment) @font-lock-preprocessor-face
      (:match "\\`.*RUN\\'" @font-lock-preprocessor-face)))

   :feature 'comment
   '([(multiline_comment) (comment)] @font-lock-comment-face)

   :feature 'string
   '([(string_string) (code_string)] @font-lock-string-face)

   :feature 'number
   '((number) @font-lock-number-face)

   :feature 'definition
   '((class name: (identifier) @tablegen-ts-mode-class-face)
     (multiclass (identifier) @tablegen-ts-mode-class-face)
     (template_arg (identifier) @font-lock-variable-name-face)
     (def (value (identifier) @font-lock-function-name-face))
     (def (value (value (identifier) @font-lock-function-name-face)
                 "#" (value (identifier) @font-lock-variable-use-face)))
     (defm (value (identifier) @font-lock-function-name-face))
     (defm (value (value (identifier) @font-lock-function-name-face)
                  "#" (value (identifier) @font-lock-variable-use-face)))
     (defset (_) (identifier) @font-lock-variable-name-face)
     (defvar (identifier) @font-lock-variable-name-face)
     (let (let_item (identifier) @font-lock-variable-name-face))
     (let_inst (identifier) @font-lock-variable-name-face)
     (foreach (identifier) @font-lock-variable-name-face))

   :feature 'type
   '((type _ @font-lock-type-face ["<" ">"] :* @font-lock-bracket-face)
     ((identifier) @font-lock-type-face
      (:match "\\`_*[A-Z][A-Z0-9_]+\\'" @font-lock-type-face))
     (dag_arg (value (identifier) @font-lock-type-face) ":" (var))
     (parent_class_list (identifier) @font-lock-type-face
                        (value (identifier) @font-lock-type-face) :?)
     (parent_class_list argument: (value (identifier) @font-lock-variable-use-face)))

   :feature 'assignment
   '((instruction (identifier) @font-lock-variable-name-face)
     ((instruction) @_instr
      (:match "=" @_instr)))

   :feature 'constant
   '(["true" "false"] @font-lock-constant-face)

   :feature 'function
   '(["!cond" (operator_keyword)] @font-lock-function-call-face)

   :feature 'variable
   '((var) @font-lock-variable-name-face
     (dag_arg (value (identifier) @font-lock-variable-name-face))
     (operator argument: (value (identifier) @font-lock-variable-use-face))
     (value (identifier) @font-lock-variable-use-face))

   :feature 'operator
   `(["#" "-" "..." "=" "?"] @font-lock-operator-face)

   :feature 'delimiter
   '(["." "," ";" ":"] @font-lock-delimiter-face)

   :feature 'bracket
   '(["(" ")" "{" "}" "[" "]" "<" ">"] @font-lock-bracket-face))
  "Tree-sitter font-lock settings for TableGen.")

;;; Navigation

(defun tablegen-ts-mode--defun-name (node)
  "Find name of NODE."
  (let ((node (pcase (treesit-node-type node)
                ("class" (treesit-node-child-by-field-name node "name"))
                ((or "def" "defm" "multiclass")
                 (treesit-node-child node 1))
                (_ nil))))
    (and node (treesit-node-text node))))

(defun tablegen-ts-mode--imenu-valid-p (node)
  "Return non-nil if NODE should be included in imenu."
  (tablegen-ts-mode--defun-name node))

(defvar tablegen-ts-mode--sentence-nodes
  (rx bos (or "statement"
              "class"
              "multiclass"
              "body_item"
              "def" "defm" "defvar" "defset")
      eos)
  "See `treesit-sentence-type-regexp' for more information.")

(defvar tablegen-ts-mode--sexp-nodes nil
  "See `treesit-sexp-type-regexp' for more information.")

(defvar tablegen-ts-mode--text-nodes
  (rx (or "string_string" "code_string" "comment" "multiline_comment"))
  "See `treesit-text-type-regexp' for more information.")

;;;###autoload
(define-derived-mode tablegen-ts-mode prog-mode "TableGen"
  "Major mode for editing TableGen source code.

\\{tablegen-ts-mode-map}"
  :group 'tablegen
  (when (treesit-ready-p 'tablegen)
    (treesit-parser-create 'tablegen)

    ;; Comments
    (c-ts-common-comment-setup)

    ;; Indentation
    (setq-local treesit-simple-indent-rules tablegen-ts-mode--indent-rules)

    ;; Font-Locking
    (setq-local treesit-font-lock-settings tablegen-ts-mode--font-lock-settings)
    (setq-local treesit-font-lock-feature-list tablegen-ts-mode--feature-list)

    ;; Navigation
    (setq-local treesit-defun-tactic 'nested)
    (setq-local treesit-defun-name-function #'tablegen-ts-mode--defun-name)
    (setq-local treesit-defun-type-regexp
                (rx bos (or "class" "multiclass" "def" "defm") eos))

    (setq-local treesit-thing-settings
                `((tablegen
                   (sexp ,tablegen-ts-mode--sexp-nodes)
                   (sentence ,tablegen-ts-mode--sentence-nodes)
                   (text ,tablegen-ts-mode--text-nodes))))

    ;; Imenu
    (setq-local treesit-simple-imenu-settings
                '(("Class" "\\`\\(?:\\(?:multi\\)?class\\)\\'"
                   tablegen-ts-mode--imenu-valid-p)
                  ("Def" "\\`\\(?:defm?\\)\\'"
                   tablegen-ts-mode--imenu-valid-p)))

    (treesit-major-mode-setup)))

(when (treesit-ready-p 'tablegen)
  (add-to-list 'auto-mode-alist '("\\.td\\'" . tablegen-ts-mode)))

(provide 'tablegen-ts-mode)
;; Local Variables:
;; coding: utf-8
;; indent-tabs-mode: nil
;; End:
;;; tablegen-ts-mode.el ends here
