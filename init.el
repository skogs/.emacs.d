(require 'cl)

;; dir of elisp files
(push "~/.emacs.d" load-path)
(require 'tree)

(when (>= emacs-major-version 23)
   (cua-mode t)
   (ido-mode t)
   (ido-everywhere t)
   (setq ido-enable-flex-matching t) ; fuzzy matching is a must have
)

(when (>= emacs-major-version 24)
  (require 'package)
  (package-initialize)
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
  (require 'evil)
  (evil-mode 1)
  (setq evil-default-cursor t)
  (setq evil-want-fine-undo t)
  (evil-set-toggle-key "C-<escape>")
)

(defun init ()
   (interactive)
   (find-file "~/.emacs.d/init.el"))

(autoload 'ace-jump-mode "ace-jump-mode" "Emacs quick move minor mode" t)

;;If you use evil
(define-key evil-normal-state-map (kbd "j") 'evil-ace-jump-char-mode)
(define-key evil-normal-state-map (kbd "SPC") 'evil-scroll-down)
(define-key evil-normal-state-map (kbd "S-SPC") 'evil-scroll-up)
(evil-define-motion evil-ace-jump-char-mode (count)
  :type exclusive
  (ace-jump-mode 5)
  (recursive-edit))
(add-hook 'ace-jump-mode-end-hook 'exit-recursive-edit)

(if tool-bar-mode (tool-bar-mode -1))
(if menu-bar-mode (menu-bar-mode -1))
(global-auto-revert-mode 1)
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq make-backup-files  nil) ; Don't want any backup files
(setq auto-save-default   nil) ; Don't want any auto saving
(show-paren-mode t) ; match brackets
(setq-default cursor-type 'bar)
(defalias 'yes-or-no-p 'y-or-n-p)

(defun my-c-mode-common-hook ()
  (setq c-basic-offset 4)
  (setq indent-tabs-mode nil)
  (c-toggle-hungry-state 1)
  (define-key c-mode-base-map (kbd "RET") 'newline-and-indent)
)
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

(setq indent-tabs-mode nil)
(setq tab-width 4)

(add-hook 'shell-mode-hook
   '(lambda ()
      (local-set-key '[(tab)] 'comint-dynamic-complete)
      (rename-buffer (generate-new-buffer-name "shell"))))

(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(setq lua-indent-level 3)

;;set modes
(setq auto-mode-alist
      (append '(("\\.[ch]$" . c++-mode)
                ("\\.bid$"  . c++-mode)
                ("\\.min$"  . makefile-mode)
                ("\\.mak$"  . makefile-mode)
                ("\\.lua$"  . lua-mode)
                ("\\.java$"  . java-mode)
                ("\\.rb$"   . ruby-mode)
                ("\\.min$"  . makefile-mode)
                ("\\.cif$"  . lua-mode))
              auto-mode-alist))

;; Frame title bar formatting to show full path of file
(setq-default
 frame-title-format
 (list '((buffer-file-name " %f" (dired-directory
                   dired-directory
                  (revert-buffer-function " %b"
                  ("%b - Dir:  " default-directory)))))))

(setq ediff-split-window-function 'split-window-vertically)

;; Completion function for tags.  Does normal try-completion,
;; but builds tags-completion-table on demand.
(defun tags-complete-tag (string predicate what)
  (save-excursion
    ;; If we need to ask for the tag table, allow that.
    (if (eq what t)
    (all-completions string (tags-completion-table) predicate)
      (try-completion string (tags-completion-table) predicate))))

(defun he-tag-beg ()
  (let ((p
         (save-excursion
           (backward-word 1)
           (point))))
    p))

(defun try-expand-tag (old)
  (unless  old
    (he-init-string (he-tag-beg) (point))
    (setq he-expand-list (sort
                          (all-completions he-search-string 'tags-complete-tag) 'string-lessp)))
  (while (and he-expand-list
              (he-string-member (car he-expand-list) he-tried-table))
              (setq he-expand-list (cdr he-expand-list)))
  (if (null he-expand-list)
      (progn
        (when old (he-reset-string))
        ())
    (he-substitute-string (car he-expand-list))
    (setq he-expand-list (cdr he-expand-list))
    t))

(setq hippie-expand-try-functions-list
   '(
     try-expand-dabbrev-visible
     try-expand-dabbrev-from-kill
     try-expand-dabbrev-all-buffers
     try-expand-tag
     try-expand-line-all-buffers
     try-complete-file-name-partially
     try-complete-file-name
))

(defun dos()
  "Select DOS newlines (see 'unix')"
  (interactive)
  (set-buffer-file-coding-system 'iso-latin-1-dos))

(defun unix()
  "Select UNIX newlines (see 'dos')"
  (interactive)
  (set-buffer-file-coding-system 'iso-latin-1-unix))

(defun smart-tab ()
  "This smart tab is minibuffer compliant: it acts as usual in
    the minibuffer. Else, if mark is active, indents region. Else if
    point is at the end of a symbol, expands it. Else indents the
    current line."
  (interactive)
  (if (minibufferp)
      (minibuffer-complete)
    (if mark-active
        (indent-region (region-beginning)
                       (region-end))
      (if (looking-at "\\_>")
          (hippie-expand nil)
        (indent-for-tab-command)))))

(defun colorscheme-darkslate ()
   (interactive)
   (set-background-color "grey15")
   (set-foreground-color "grey")
   (set-cursor-color "white")
   (custom-set-faces
    '(font-lock-builtin-face ((t (:foreground "aquamarine"))))
    '(font-lock-comment-face ((t (:foreground "light blue"))))
    '(font-lock-constant-face ((t (:foreground "pale green"))))
    '(font-lock-doc-face ((t (:foreground "light sky blue"))))
    '(font-lock-doc-string-face ((t (:foreground "sky blue"))))
    '(font-lock-function-name-face ((t (:bold t :foreground "aquamarine" :weight bold))))
    '(font-lock-keyword-face ((t (:bold t :foreground "pale turquoise" :weight bold))))
    '(font-lock-reference-face ((t (:foreground "pale green"))))
    '(font-lock-string-face ((t (:foreground "light sky blue"))))
    '(font-lock-type-face ((t (:bold t :foreground "sky blue" :weight bold))))
    '(font-lock-variable-name-face ((t (:bold t :foreground "turquoise" :weight bold))))
    '(font-lock-warning-face ((t (:bold t :foreground "Red" :weight bold))))
    ))

;; Pick color scheme
;(colorscheme-darkslate)

(defun byte-compile-directory (dir)
  "compiles all .el files in a directory (or tries)"
  (interactive "DByte compile directory: ")
  (and (file-directory-p dir)
       (mapcar (lambda (file)
                 (or (file-newer-than-file-p (concat file "c") file)
                     (byte-compile-file file)))
               (directory-files dir t "^.*\.el$"))
       dir))

(defun shell-bottom (arg)
  (interactive "p")
  (if (eq arg 1)
      (shell)
    (shell (concat "AltShell-" (number-to-string arg))))
  (goto-char (point-max)))

;; Let's use CYGWIN bash...
;;
(setq binary-process-input t)
(setq w32-quote-process-args ?\")
(setenv "SHELL" shell-file-name)
(setq explicit-shell-file-name shell-file-name)
(setq explicit-sh-args '("-login" "-i"))

; Customized key-bindings go below
(global-set-key (kbd "<tab>")	'smart-tab)                ; Tab does auto-completion
(global-set-key "\t"         'smart-tab)                ; Tab does auto-completion
                                                           ; based on words from all buffers and later tags
(global-set-key (kbd "<f1>")    'delete-other-windows)
(global-set-key (kbd "<f4>")    'query-replace-regexp)
(global-set-key (kbd "<f5>")   'tree-grep-at-point)
(global-set-key (kbd "<f6>")   'tree-find-file)
(global-set-key (kbd "<S-6>") 'tree-hyperjump)
(global-set-key (kbd "<f12>")    'kill-this-buffer)

(global-set-key (kbd "C-<tab>") 'ido-switch-buffer)
(global-set-key [(control tab)] 'ido-switch-buffer)

(global-set-key (kbd "C-c C-p") 'tree-find-file)
(global-set-key (kbd "C-c C-g") 'tree-grep)
(global-set-key (kbd "C-x C-p") 'tree-find-file)
(global-set-key (kbd "C-x C-g") 'tree-grep)

(global-set-key (kbd "M-?")	'etags-select-find-tag-at-point) ; M-? finds all occurances of a tag
