(require 'url)
(require 'json)

(defcustom nc2lt2cp/libretranslate-api-url "http://localhost:5000/translate"
  "URL of the translation API."
  :type 'string)

(defcustom nc2lt2cp/libretranslate-source-lang "en"
  "Source language for translation."
  :type 'string)

(defcustom nc2lt2cp/libretranslate-target-lang "de"
  "Target language for translation."
  :type 'string)

(defcustom nc2lt2cp/org-file "~/translated-text.org"
  "Path to the Org file for storing translated text."
  :type 'string)


;; Function to translate text using LibreTranslate
(defun libretranslate-text (text source-lang target-lang)
  (let* ((api-url nc2lt2cp/libretranslate-api-url)
	 (url-request-method "POST")
	 (url-request-extra-headers '(("Content-Type" . "application/json")))
	 (url-request-data (json-encode-alist `(("q" . ,text)
						("source" . ,nc2lt2cp/libretranslate-source-lang)
						("target" . ,nc2lt2cp/libretranslate-target-lang))))
	 (response-buffer (url-retrieve-synchronously api-url))
	 translation-response)
    (with-current-buffer response-buffer
      (goto-char (point-min))
      (re-search-forward "^$")
      (delete-region (point) (point-min))
      (setq translation-response (json-read)))
    (message "Translation response: %s" translation-response)
    (cdr (assoc 'translatedText translation-response))))

(defun capture-translate-and-write-to-org ()
  (interactive)
  (let* ((source-lang "en") ; Change the source language if needed
	 (target-lang "de") ; Change the target language if needed
	 (org-file nc2lt2cp/org-file) ; Change the Org file path if needed
	 extracted-text
	 translated-text)
    (shell-command "normcap")
    (setq extracted-text (shell-command-to-string "xclip -o -selection clipboard"))
    (setq translated-text (libretranslate-text extracted-text source-lang target-lang))
    (with-current-buffer (find-file-noselect org-file)
      (goto-char (point-max))
      (insert (concat "\n* Extracted Text\n" extracted-text "\n* Translated Text\n" translated-text "\n"))
      (save-buffer))
    (unless (get-buffer-window (find-buffer-visiting org-file) t)
      (switch-to-buffer-other-window (find-buffer-visiting org-file)))))

