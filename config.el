;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Takeshi Tsukamoto"
      user-mail-address "dev@itome.team")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))
;;
(setq doom-font (if (eq system-type 'gnu/linux)
                    (font-spec :family "JetBrains Mono" :size 18 :weight 'semi-bold :line-height 1.3)
                  (font-spec :family "JetBrains Mono" :size 12 :weight 'semi-bold :line-height 1.3))
      doom-variable-pitch-font (if (eq system-type 'gnu/linux)
                                   (font-spec :family "Noto Sans JP" :size 18)
                                 (font-spec :family "Noto Sans JP" :size 12)))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-nord)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(keyboard-translate ?\C-h ?\C-?)

(add-to-list 'default-frame-alist '(fullscreen . maximized))

(setq-hook! '(web-mode-hook typescript-tsx-mode-hook vue-mode-hook)
  web-mode-style-padding 0
  web-mode-script-padding 0
  web-mode-block-padding 0
  web-mode-code-indent-offset 2
  web-mode-enable-auto-quoting nil
  web-mode-css-indent-offset 2
  web-mode-markup-indent-offset 2)

(setq-hook! 'which-key-mode-hook
  which-key-idle-delay 0.5)

(after! corfu
  (setq corfu-min-width 40
        corfu-max-width 40))

(after! vertico-posframe
  (setq vertico-posframe-parameters '((left-fringe . 8) (right-fringe . 8))
        vertico-multiform-commands '((+default/search-buffer indexed)
                                     (+default/search-project indexed)
                                     (t posframe))))

(after! vertico
  (add-hook 'vertico-mode-hook #'vertico-multiform-mode))

(map! :after treemacs
      :map treemacs-mode-map
      (:prefix-map ("p" . "project")
                   "d" #'treemacs-remove-project-from-workspace
                   "a" #'treemacs-add-project-to-workspace)
      (:prefix-map ("c" . "create")
                   "f" #'treemacs-create-file
                   "d" #'treemacs-create-dir))

(map! :leader
      (:prefix-map ("c" . "code")
       :desc "Jump back" "b" #'xref-go-back))

(setq-hook! 'treemacs-mode-hook treemacs-filewatch-mode t)
(setq-hook! 'typescript-tsx-mode-hook +format-with-lsp nil)
(setq-hook! 'typescript-mode-hook +format-with-lsp nil)

(add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-tsx-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-tsx-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . typescript-tsx-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . typescript-tsx-mode))

(define-derived-mode vue-mode web-mode "Vue")
(add-to-list 'auto-mode-alist '("\\.vue\\'" . vue-mode))
(add-hook 'vue-mode-local-vars-hook #'lsp! 'append)

(defun vue-eglot-init-options ()
  (let ((tsdk-path (expand-file-name
                    "lib"
                    (shell-command-to-string "npm list --global --parseable typescript | head -n1 | tr -d \"\n\""))))
    `(:typescript (:tsdk ,tsdk-path
                   :languageFeatures (:completion
                                      (:defaultTagNameCase "both"
                                       :defaultAttrNameCase "kebabCase"
                                       :getDocumentNameCasesRequest nil
                                       :getDocumentSelectionRequest nil)
                                      :diagnostics
                                      (:getDocumentVersionRequest nil))
                   :documentFeatures (:documentFormatting
                                      (:defaultPrintWidth 100
                                       :getDocumentPrintWidthRequest nil)
                                      :documentSymbol t
                                      :documentColor t)))))
(after! eglot
  (setq eglot-ignored-server-capabilities '(:inlayHintProvider))
  (add-to-list 'eglot-server-programs
               `(vue-mode . ("vue-language-server" "--stdio" :initializationOptions ,(vue-eglot-init-options))))
  (add-to-list 'eglot-server-programs
               `(typescript-tsx-mode . ("typescript-language-server" "--stdio"))))

(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)))
