;;; init-local.el    -*- lexical-binding: t; -*-


;;Set default font on both .emacs and .Xresources
(set-frame-font "Dejavu Sans Mono-14")


;;Color theme
(add-to-list 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory))
;; (load-theme 'sanityinc-tomorrow-bright t)
(load-theme 'acme t)

;; case-insensitive search
(setq case-fold-search t)


(unless (package-installed-p 'imenu-anywhere)
  (package-install 'imenu-anywhere))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

(use-package use-package-ensure-system-package
  :ensure t)

;;; FROM julienfantin
(require 'use-config) ;;customizes use-package
(use-package ace-window
  :ensure t
  :commands (aw-window-list)
  :config
  (setq aw-keys '(?1 ?2 ?3 ?4 ?5 ?6 ?7 ?8 ?9 ?0)
        aw-scope 'frame))



(use-package swiper
  :ensure t
  :commands (-swiper-thing-at-point)
  :bind
  ((:map swiper-map
         ("C-r" . ivy-previous-line-or-history)))
  :custom
  ;; Always recentre when leaving Swiper
  (swiper-action-recenter t)
  ;; Jump to the beginning of match when leaving Swiper
  (swiper-goto-start-of-match t)
  ;; C-k C-g to go back to where the research started
  ;; (swiper-stay-on-quit t)
  )

;;;###autoload
(defun ivy-with-thing-at-point (cmd)
  (let ((ivy-initial-inputs-alist
         (list
          (cons cmd (thing-at-point 'symbol)))))
    (funcall cmd)))

;;;###autoload
(defun -swiper-thing-at-point ()
  (interactive)
  (ivy-with-thing-at-point 'swiper))

(use-package avy
  :ensure t
  :custom
  (avy-style 'at-full)
  (avy-background t)
  (avy-all-windows t)
  (avy-timeout-seconds 0.28)
  :config
  ;; Use C-' in isearch to bring up avy
  (avy-setup-default))

(use-package deadgrep
  :ensure t
  :ensure-system-package (rg . "ripgrep"))

(use-package easy-kill
  :ensure t
  :bind
  ([remap kill-ring-save] . #'easy-kill)
  ([remap mark-sexp] . #'easy-mark))

(use-package dired
  :hook (dired-mode . dired-hide-details-mode)
  :bind
  ("C-x C-j" . dired-jump)
  (:map dired-mode-map
              ("RET" . dired-find-alternate-file)
              ("^" . (lambda () (interactive) (find-alternate-file ".."))))
  :custom
  (dired-auto-revert-buffer t)
  (dired-recursive-copies 'always)
  (dired-recursive-deletes ' always))

(use-package dired-k
  :ensure t
  :after dired
  :hook
  (dired-initial-position . dired-k)
  (dired-after-readin     . dired-k-no-revert)
  :custom
  (dired-k-style nil)
  (dired-listing-switches "-alh")
  (dired-k-human-readable t))

;; ** Dired extensions

(use-package dired-hacks-utils
  :ensure t
  :after dired
  :bind
  (:map dired-mode-map
        (("n" . dired-hacks-next-file)
         ("p" . dired-hacks-previous-file))))

(use-package dired-narrow
  :ensure t
  :after dired
  :bind (:map dired-mode-map
              ("/" . dired-narrow-fuzzy)))

(use-package dired-x
  :after dired
  :custom
  (dired-omit-files "^\\.\\|^#.#$\\|.~$"))

(use-package sudo-edit :ensure t)


(use-package hydra
  :ensure  t
  :config
  (use-package lv
    :custom
    (lv-use-separator t)))

(defhydra hydra-search (global-map "<f3>" :color red)
  "Buffers"
  ("s"     -swiper-thing-at-point "swiper")
  ("S"     swiper-all "swiper-all")
  ("j"     avy-goto-char-timer "avy-char")
  ("g"     counsel-rg "ripgrep")
  ("G"     counsel-git-grep "git-grep")
  ("p"     projectile-find-file "(projectile) find-file")
  ("i"     counsel-imenu "imenu")
  ("I"     ivy-imenu-anywhere "imenu")
  ("r"     ivy-resume "ivy-resume")
  ("q"     ignore :exit t)
  )


(defun --temp-buffers ()
  "Return a list of temp buffers."
  (cl-remove-if-not
   (lambda (buffer)
     (string-match-p  "\\*temp" (buffer-name buffer)))
   (buffer-list)))

;;;###autoload
(defun -temp-buffer (arg)
  "Create or switch to *temp* buffer.
When called with 'ARG' always create a new temp buffer."
  (interactive "P")
  (let* ((n (if (equal '(4) arg) (length (--temp-buffers)) 0))
         (name (format "*temp%s" (if (>= 0 n) "*" (format "-%s*" n))))
         (buffer (get-buffer-create name))
         (mode major-mode))
    (with-current-buffer buffer
      (funcall mode)
      (switch-to-buffer buffer))))

;;;###autoload
(defun -switch-to-last-buffer ()
  "Switch to the most recently used buffer."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) t)))



(define-key global-map [f2] nil)
(defhydra hydra-buffers (global-map "<f2>" :color red)
  "Buffers"
  ("TAB"   -switch-to-last-buffer "last")
  ("b"     ivy-switch-buffer "switch")
  ("n"     next-buffer "next")
  ("p"     previous-buffer "prev")
  ("h"     bury-buffer "hide")
  ("k"     kill-buffer-and-window "kill")
  ("f"     counsel-find-file "find-file")
  ("r"     revert-buffer "revert")
  ("t"     -temp-buffer "temp")
  ("q"     ignore :exit t))


(hydra-set-property 'hydra-buffers :verbosity 1)



;;-----------------------------------------------------------------------------
;;; Lisp

(require 'paren-face)
(defun dim-parentheses ()
  (paren-face-mode)
  (setq hippie-expand-dabbrev-as-symbol t))

(add-hook 'lisp-mode-hook 'dim-parentheses)

(setq inferior-lisp-program "~/sources/ccl/lx86cl64")



(use-package pulse-eval
  ;; :after lisp-minor-mode
  :hook
  (lisp-mode . pulse-eval-mode)
  (inferior-lisp-mode . pulse-eval-mode)
  (emacs-lisp-mode . pulse-eval-mode)
  (lisp-interaction-mode . pulse-eval-mode)
  :custom
  (pulse-eval-iterations 1)
  (pulse-eval-delay .13))

(use-package lispy
  :ensure t
  :config
  (progn
    (after 'pulse-eval
      (add-to-list
       'pulse-eval-advices-alist
       (cons 'lispy-mode '((lispy-eval . pulse-eval-highlight-forward-sexp-advice))))))
  :custom
  (lispy-no-permanent-semantic t)
  (lispy-close-quotes-at-end-p t)
  (lispy-eval-display-style 'overlay)
  (lispy-visit-method 'projectile)
  (lispy-compat '(edebug cider))
  (lispy-avy-style-char 'at-full)
  (lispy-avy-style-paren 'at-full)
  (lispy-avy-style-symbol 'at-full)
  (lispy-safe-copy t)
  (lispy-safe-delete t)
  (lispy-safe-paste t))

(use-package lispy-mnemonic
  :commands lispy-mnemonic-mode
  ;; :after lisp-minor-mode
  :hook
  (lisp-mode . lispy-mnemonic-mode)
  (inferior-lisp-mode . lispy-mnemonic-mode)
  (emacs-lisp-mode . lispy-mnemonic-mode)
  (lisp-interaction-mode . lispy-mnemonic-mode))

(global-superword-mode 1)
(diminish 'superword-mode)

;;---------------------------------------------------------------------------------------------------



;;Shell customization
(add-hook
 'shell-mode-hook
 (lambda ()
   ;; Allow use of meta-p and meta-n for command completion.  Multiple
   ;; meta-p/meta-n commands cycle backward/forward through previous matching
   ;; commands. From emacs-acl2.el
   (define-key comint-mode-map "\ep" 'comint-previous-matching-input-from-input)
   (define-key comint-mode-map "\en" 'comint-next-matching-input-from-input)
   ;;shell mode specifics from snarfed.org
   (setq comint-scroll-to-bottom-on-input t)  ;; always insert at the bottom
   (setq comint-scroll-to-bottom-on-output nil) ;; always add output at the bottom
   (setq comint-input-ignoredups t)           ;; no duplicates in command history
   (setq comint-buffer-maximum-size 20000)    ;; max length of the buffer in lines
   (setq comint-get-old-input (lambda () "")) ;; what to run when i press enter on line above the current prompt
   (setq comint-input-ring-size 5000)         ; max shell history size
   (setq protect-buffer-bury-p nil)

   ;;from https://www.gnu.org/software/emacs/manual/efaq-w32.html#Using-shell
   (setq comint-scroll-show-maximum-output 'this)
   (make-variable-buffer-local 'comint-completion-addsuffix)
   (setq comint-completion-addsuffix t)
   (setq comint-eol-on-send t)
   (setq w32-quote-process-args ?\")

   (when (eq 'cygwin system-type)
     (setq explicit-shell-file-name "/bin/bash")
     (setq ediff-shell explicit-shell-file-name)    ; Ediff shell
     (setq explicit-bash-args '("--login" "-i"))
     )

   ))
;;bindings

;; ;;mini-buffer history completetion
;; (define-key minibuffer-local-map
;;   (kbd "M-p") 'previous-complete-history-element)
;; (define-key minibuffer-local-map
;;   (kbd "M-n") 'next-complete-history-element)


(global-set-key (kbd "C-s") 'swiper-isearch)
(global-set-key "\M-g" 'avy-goto-line)
(global-set-key (kbd "C-q") 'previous-line)
(global-set-key (kbd "C-z") 'next-line)
(global-set-key [f5] 'save-buffer)

;; (global-set-key [f8]  'enter-theorem-other-window-like-sedan)
(global-set-key [f6]  'ivy-switch-buffer)
(global-set-key [(control tab)] 'ace-window)

;; (global-set-key (kbd "C-x f") 'find-file) ; annoying mistakes
;; (global-set-key (kbd "C-x C-k") 'kill-buffer-without-process) ; annoying mistakes
(define-key global-map [(insert)] nil) ; disable annoying overwrite mode
(global-set-key (kbd "C-c !") 'org-time-stamp-inactive)

(defun join-next-line ()
  (interactive)
  (join-line 1))
(global-set-key (kbd "C-\\") 'join-next-line)

(global-set-key (kbd "M-SPC") 'hippie-expand)
(setq hippie-expand-try-functions-list
      '(try-expand-dabbrev-visible
        try-expand-dabbrev
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill
        try-expand-list
        try-expand-line
        try-complete-file-name-partially
        try-complete-file-name
        ;; try-complete-lisp-symbol
        ;; try-complete-lisp-symbol-partially
        ))



(provide 'init-local)
