;======================================================================
; load-path
;======================================================================
(add-to-list 'load-path "~/.emacs.d/site-lisp/")
(add-to-list 'load-path "~/.emacs.d/auto-install/")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; shell settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; use bash
(setq explicit-shell-file-name "/bin/bash")
;; PATH
(setq exec-path (cons "/usr/local/bin/" exec-path))
(setenv "PATH"
		(concat '"/usr/local/bin:" (getenv "PATH")))
(setenv "LANG"  "ja_JP.UTF-8")
;; color


;======================================================================
; 言語文字コード関連の設定
;======================================================================
(set-language-environment "Japanese")
(cd (decode-coding-string default-directory file-name-coding-system))
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
;; #* というバックアップファイルを作らない
(setq auto-save-default nil)
;; *.~ というバックアップファイルを作らない
(setq make-backup-files nil)
;; GCの頻度を減らす
(setq gc-cons-threshold 5242880)
;; スクロールで改行を入れない
(setq next-line-add-newlines nil)
;; 色づけ
(global-font-lock-mode t)
;; tab キーでインデントを実行
(setq tabs-always-indent t)

;; 改行コードを表示
(setq eol-mnemonic-dos "(CRLF)")
(setq eol-mnemonic-mac "(CR)")
(setq eol-mnemonic-unix "(LF)")

;; 同名のファイルを開いたとき親のディレクトリ名も表示
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

;; 置換をリージョン指定可能に
(defadvice query-replace (around ys:qr-region)
  (if (and transient-mark-mode mark-active)
      (save-restriction
        (narrow-to-region (region-beginning) (region-end))
        ad-do-return)
    ad-do-return))
(defadvice query-replace-regexp (around ys:qrr-region)
  (if (and transient-mark-mode mark-active)
      (save-restriction
        (narrow-to-region (region-beginning) (region-end))
        ad-do-return)
    ad-do-return))
(ad-enable-advice 'query-replace 'around 'ys:qr-region)
(ad-enable-advice 'query-replace-regexp 'around 'ys:qrr-region)

;; yank した文字列をハイライト表示
(when (or window-system (eq emacs-major-version '21))
  (defadvice yank (after ys:highlight-string activate)
    (let ((ol (make-overlay (mark t) (point))))
      (overlay-put ol 'face 'highlight)
      (sit-for 0.5)
      (delete-overlay ol)))
  (defadvice yank-pop (after ys:highlight-string activate)
    (when (eq last-command 'yank)
      (let ((ol (make-overlay (mark t) (point))))
        (overlay-put ol 'face 'highlight)
        (sit-for 0.5)
        (delete-overlay ol)))))

;; ファイルの履歴
(require 'recentf)
(recentf-mode t)
(setq recentf-exclude '("^\\.emacs\\.bmk$"))
(setq recentf-max-menu-items 10)
(setq recentf-max-saved-items 20)

;; ファイルの位置を保存
(setq save-place-file "~/.emacs.d/saveplace")
(setq-default save-place t)
(require 'saveplace)

;; point-undo								
(require 'point-undo)
(define-key global-map (kbd "<f7>") 'point-undo)
(define-key global-map (kbd "S-<f7>") 'point-redo)

;; popwin
;;(require 'popwin)
;;(setq display-buffer-function 'popwin:display-buffer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auto-install
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'auto-install)
(setq auto-install-directory "~/.emacs.d/auto-install/")
(auto-install-update-emacswiki-package-name t)
(auto-install-compatibility-setup)             ; 互換性確保

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; anything
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'anything)
(require 'anything-startup)
;; search for files in the project
(require 'anything-project)
(global-set-key (kbd "M-t") 'anything-project)
(ap:add-project
 :name 'rails
 :look-for '(Rakefile)
 :exclude-regexp '("/tmp" "/vendor" "/script"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sr-speedbar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'sr-speedbar)
(setq sr-speedbar-right-side nil)
(sr-speedbar-refresh-turn-off)
 ;; other-windowでspeedbarをskip
(setq sr-speedbar-skip-other-window-p t)
;; switch sr-speedbar <=> current window
(defvar previously-selected-window nil)
(defadvice sr-speedbar-select-window
  (before save-previous-window activate)
  "Memorize current window before switcing to sr-speedbar window."
  (setq previously-selected-window (selected-window)))
(defun sr-speedbar-toggle-window-selection ()
  "Switch to sr-speedbar window. If already switched, switch back to previous window."
  (interactive)
  (if (sr-speedbar-exist-p)
      (if (sr-speedbar-window-p)
		  (select-window previously-selected-window)
		(sr-speedbar-select-window))
		(error "sr-speedbar window not present.")))
;; select sr-speedbar window
(define-key global-map (kbd "<f11>") 'sr-speedbar-toggle-window-selection)
;; refresh speedbar
(define-key global-map (kbd "C-<f11>") 'speedbar-refresh)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; emacs-lisp-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'emacs-lisp-mode-hook '(lambda () (show-paren-mode t)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; paredit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(autoload 'paredit-mode "paredit"
   "Minor mode for pseudo-structurally editing Lisp code." t)
(add-hook 'emacs-lisp-mode-hook       (lambda () (paredit-mode +1)))
(add-hook 'lisp-mode-hook             (lambda () (paredit-mode +1)))
(add-hook 'lisp-interaction-mode-hook (lambda () (paredit-mode +1)))
(add-hook 'scheme-mode-hook           (lambda () (paredit-mode +1)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sequential-command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'sequential-command)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; yasnippet
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'load-path "~/.emacs.d/site-lisp/yasnippet/")
(require 'yasnippet) ;; not yasnippet-bundle
(yas/initialize)
(yas/load-directory "~/.emacs.d/site-lisp/yasnippet/snippets/")
(define-key global-map (kbd "C-c y") 'yas/expand)

;;one-shot snippet
(defvar yas/oneshot-snippet nil)
(defun yas/register-oneshot-snippet (s e)
  (interactive "r")
  (setq yas/oneshot-snippet (bufer-substring-no-properties s e))
  (delete-region s e)
  (yas/expand-oneshot-snippet)
  (message "%s" (substitute-command-keys "Press \\[yas/expand-oneshot-snippet] to expand.")))
(defun yas/expand-oneshot-snippet ()
  (interactive)
  (if (string< "0.6" yas/version)
      (yas/expand-snippet yas/oneshot-snippet)
    (yas/expand-snippet (point) (point) yas/oneshot-snippet)))
;; M-w M-wでone-shot snippetを登録
(define-sequential-command kill-ring-save-x
  kill-ring-save yas/register-oneshot-snippet)
(define-key esc-map "w" 'kill-ring-save-x) ; M-w
(define-key global-map "\C-\M-y" 'yas/expand-oneshot-snippet)

;;snippet展開時にauto-completeを無効化
(add-hook 'yas/before-expand-snippet-hook '(lambda () (setq ac-auto-start nil)))
(add-hook 'yas/after-exit-snippet-hook '(lambda () (setq ac-auto-start t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; packeage.el
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;package.el
(require 'package)
;;リポジトリにMarmaladeを追加
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
;; elpaを追加
(add-to-list 'package-archives '("elpa" . "http://tromey.com/elpa/"))
;;インストールするディレクトリを指定
(setq package-user-dir (concat user-emacs-directory "packages/"))
;;インストールしたパッケージにロードパスを通してロードする
(package-initialize)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ruby, rails関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(autoload 'ruby-mode "ruby-mode" "Mode for editing ruby source files" t)
(setq auto-mode-alist (cons '("\\.rb$" . ruby-mode) auto-mode-alist))
(setq interpreter-mode-alist (append '(("ruby" . ruby-mode)) interpreter-mode-alist))
(autoload 'run-ruby "inf-ruby" "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby" "Set local key defs for inf-ruby in ruby-mode")
(add-hook 'ruby-mode-hook '(lambda () (inf-ruby-keys)))

;; rubydb
(autoload 'ruby "rubydb2x"
  "run rubydb on program file in buffer *gud-file*.
the directory containing file becomes the initial working directory
and source-file directory for your debugger." t)

;; ruby-electric.el --- electric editing commands for ruby files
(require 'ruby-electric)
(add-hook 'ruby-mode-hook '(lambda () (ruby-electric-mode t)))
(setq ruby-electric-expand-delimiters-list t)
(setq ruby-indent-level 2)
(setq ruby-indent-tabs-mode nil)

;; use rvm
(add-to-list 'load-path (expand-file-name "~/.emacs.d/site-lisp/rvm.el"))
(require 'rvm)
(rvm-use-default) ;; use rvm's default ruby for the current Emacs session

;;yaml
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(add-hook 'yaml-mode-hook
	  '(lambda ()
	     (define-key yaml-mode-map "\C-m" 'newline-and-indent)))

;;coffee-mode
(add-to-list 'load-path "~/.emacs.d/site-lisp/coffee-mode/")
(require 'coffee-mode)
(add-to-list 'auto-mode-alist '("\\.coffee$" . coffee-mode))

;; haml-mode
(require 'haml-mode)
 (add-hook 'haml-mode-hook
	   '(lambda ()
	      (setq indent-tabs-mode nil)
	      (define-key haml-mode-map "\C-m" 'newline-and-indent)))
(add-to-list 'auto-mode-alist '("\\.haml$" . haml-mode))

;;sass-mode
(require 'sass-mode)
(add-to-list 'auto-mode-alist '("\\.sass$" . sass-mode))

;; scss-mode
(add-to-list 'load-path (expand-file-name "~/.emacs.d/site-lisp/scss-mode"))
(autoload 'scss-mode "scss-mode")
(setq scss-compile-at-save nil) ;; 自動コンパイルをオフにする
(add-to-list 'auto-mode-alist '("\\.scss\\'" . scss-mode))

;; rinari
(require 'ido)
(ido-mode t)
(add-to-list 'load-path "~/.emacs.d/site-lisp/rinari")
(require 'rinari)
(defun switch-to-or-start-autotest () 	; run autotest or display autotest buffer
  (interactive)
  (if (get-buffer "*autotest*")
	  (switch-to-buffer "*autotest*")
	(autotest)))
(define-key rinari-minor-mode-map (kbd "C-c , a") 'switch-to-or-start-autotest)
;; set current directory to rinari root berfore executing autotest,
;; so that autotest will find spec directory
(defadvice autotest (before move-to-rinari-root activate)
  "Set current directory to rirari root"
  (if (assoc 'rinari-minor-mode minor-mode-alist)
	  (cd (rinari-root))))


;; rhtml mode
(add-to-list 'load-path "~/.emacs.d/site-lisp/rhtml")
(require 'rhtml-mode)
(add-hook 'rhtml-mode-hook
    (lambda () (rinari-launch)))

;; rspec-mode
(add-to-list 'load-path "~/.emacs.d/site-lisp/rspec-mode")
(require 'rspec-mode)

;; autotest
(require 'autotest)
(setq autotest-command "bundle exec autotest")

;; run spork
(defun spork ()
  "Create a new buffer and start spork process on it. If the buffer already exists"
  (interactive)
  (if (get-buffer "*spork*")
	  (switch-to-buffer "*spork*")
	(progn (switch-to-buffer (generate-new-buffer "*spork*"))
		   (compilation-shell-minor-mode t)
		   (start-process "*autotest*" (current-buffer) "spork")
		   )))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auto-complete
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'load-path "~/.emacs.d/site-lisp/auto-complete/")
(require 'auto-complete-config)
(ac-config-default)
(auto-complete-mode t)
;; C-n, C-p候補選択（ポップアップ時）
(setq ac-use-menu-map t)
(define-key ac-menu-map (kbd "\C-n") 'ac-next)
(define-key ac-menu-map "\C-p" 'ac-previous)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; visual-bookmark
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'bm)
(global-set-key (kbd "<C-f2>") 'bm-toggle)
(global-set-key (kbd "<f2>") 'bm-next)
(global-set-key (kbd "<S-f2>") 'bm-previous)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; elisp開発用
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; displays summary
(require 'summarye)
;; 使い捨てファイル
(require 'open-junk-file)
(define-key global-map (kbd "\C-x\C-z") 'open-junk-file)
;; lispxmp
(require 'lispxmp)
(define-key emacs-lisp-mode-map "\C-c\C-e" 'lispxmp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; その他
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; one-key
;;(require 'one-key)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; キーバインドの設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; switch option key with command key
(setq ns-command-modifier (quote meta))
;; anything
(global-set-key (kbd "M-1") 'anything)
;; descbind-anything
(global-set-key (kbd "C-<f12>") 'descbinds-anything)
;; anything-apropos
(global-set-key (kbd "M-<f12>") 'anything-apropos)
;; anything-locate
(global-set-key (kbd "<f12>") 'anything-locate)
;; M-g で指定行へジャンプ
(global-set-key "\M-g" 'goto-line)
;; ウィンドウのサイズ調整
(global-set-key "\M-[" 'shrink-window-horizontally)
(global-set-key "\M-]" 'enlarge-window-horizontally)
;; toggle auto-complete
(global-set-key (kbd "C-c a") 'auto-complete-mode)
;; C-a2度押しで back-to-indentation, 3度押しでbeginning-of-buffer
(global-set-key (kbd "C-a") 'seq-home)
;; C-jを reindent-then-newline-and-indentに
(global-set-key (kbd "C-j") 'reindent-then-newline-and-indent)

;; windmove
(global-set-key (kbd "M-<left>")  'windmove-left)
(global-set-key (kbd "M-<right>") 'windmove-right)
(global-set-key (kbd "M-<up>")    'windmove-up)
(global-set-key (kbd "M-<down>")  'windmove-down)

;; C-zでundo
(global-set-key (kbd "C-z") 'undo)

;; M-n, M-pで複数行スクロール
(defvar jump-scroll-amount 10
  "*The number of lines that jump-forward/backward command scrolls")
(defun jump-forward (&optional nums)
  "Move the cursor forward by the given or predefined number of lines."
  (interactive)
  (next-line (or nums jump-scroll-amount)))
(defun jump-backward (&optional nums)
  "Move the cursor backward by the given or predefined number of lines."
  (interactive)
  (previous-line (or nums jump-scroll-amount)))
;; M-n, M-pにbind
(global-set-key (kbd "M-n") 'jump-forward)
(global-set-key (kbd "M-p") 'jump-backward)

;; C-tでother-window
(global-set-key (kbd "C-t") 'other-window)
;; C-hをbackspaceに
(global-set-key (kbd "C-h") 'backward-delete-char)
;; shell
(global-set-key (kbd "<f6>") 'shell)
;; open shell on current directory
(defun shell-on-current-dir ()
  "Open shell on current default directry"
  (interactive)
  (shell (convert-standard-filename default-directory)))
(global-set-key (kbd "C-<f6>") 'shell-on-current-dir)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; key-chord
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'key-chord)
(key-chord-mode t)
;; last-kbd-macro
(key-chord-define-global "lk" 'kmacro-end-and-call-macro)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 画面の初期化
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; スクロールで改行を入れない
(setq next-line-add-newlines t)
;; スクロールバー非表示
(scroll-bar-mode nil)
;; 色づけ
(global-font-lock-mode t)
;; tab キーでインデントを実行
(setq tabs-always-indent t)
;; タブ長の設定
(setq tab-width 4)
(setq default-tab-width 4)
;; enable menubar
(menu-bar-mode 1)
;; diable toolbar
(tool-bar-mode -1)
;; 括弧の対応をハイライト
(setq show-paren-mode t)
;; 起動時の画面はいらない
(setq inhibit-startup-message t)
;; アクティブなリージョンをハイライト
(setq transient-mark-mode t)
;;speedbarを初期表示
(sr-speedbar-open)
(speedbar-toggle-show-all-files)
(sr-speedbar-refresh-turn-off)

;; color theme
(add-to-list 'load-path "~/.emacs.d/site-lisp/color-theme-6.6.0/")
(require 'color-theme)
(eval-after-load "color-theme"
  '(progn
     (setq color-theme-is-global t)
     (color-theme-initialize)
     (color-theme-billw)))

;; full-screen
(ns-toggle-fullscreen)
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
