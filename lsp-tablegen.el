;;; lsp-tablegen.el --- TableGen client -*- lexical-binding: t; -*-

;; Author: Noah Peart <noah.v.peart@gmail.com>
;; URL: https://github.com/nverno/tablegen-ts-mode
;; Version: 0.0.1
;; Package-Requires: ((emacs "29.1") (lsp-mode "8"))
;; Created: 12 December 2023
;; Keywords: languages llvm tablegen

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; LSP client for LLVM TableGen language.
;;
;;; Code:

(require 'lsp-mode)

(defgroup lsp-tablegen nil
  "LSP support for TableGen."
  :group 'lsp-mode
  :link '(url-link "https://github.com/llvm/llvm-project"))

(defcustom lsp-tablegen-executable '("tblgen-lsp-server-15")
  "Command to run the TableGen language server."
  :group 'lsp-tablegen
  :risky t
  :type '(repeat string))

(cl-pushnew 'lsp-tablegen lsp-client-packages)
(add-to-list 'lsp-language-id-configuration '("\\.td\\'" . "tablegen"))

(lsp-register-client
 (make-lsp-client
  :new-connection (lsp-stdio-connection (lambda () lsp-tablegen-executable))
  :activation-fn (lsp-activate-on "tablegen")
  :priority -1
  :major-modes '(tablegen-ts-mode tablegen-mode)
  :server-id 'tblgen))

(lsp-consistency-check lsp-tablegen)

(provide 'lsp-tablegen)
;;; lsp-tablegen.el ends here
