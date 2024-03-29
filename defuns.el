;; ==== MY CUSTOM FUNCTIONS =====
;; ==============================

(defun toggle-frame-split ()
  "If the frame is split vertically, split it horizontally or vice versa.
   Assumes that the frame is only split into two."
  (interactive)
  (unless (= (length (window-list)) 2) (error "Can only toggle a frame split in two"))
  (let ((split-vertically-p (window-combined-p)))
    (delete-window)                     ; closes current window
    (if split-vertically-p
        (split-window-horizontally)
      (split-window-vertically)) ; gives us a split with the other window twice
    (switch-to-buffer nil))) ; restore the original window in this part of the frame

(global-set-key (kbd "C-x |") 'toggle-frame-split)

;; sudo edit
(defun sudo-edit (&optional arg)
  "Edit currently visited file as root.
   With a prefix ARG prompt for a file to visit.
   Will also prompt for a file to visit if current
   buffer is not visiting a file."

  (interactive "P")
  (if (or arg (not buffer-file-name))
      (find-file (concat "/sudo:root@localhost:"
                         (ido-read-file-name "Find file(as root): ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

(defun occur-non-ascii ()
  "Find any non-ascii characters in the current buffer."
  (interactive)
  (occur "[^[:ascii:]]"))

(defun my-short-jira-ticket-link ()
  "Target a link at point of the Jira ticket form. e.g: VB-888

   Env var EMACS_MY_JIRA_URL needs to be set with a
   domain (without https://) such as: my-url.atlassian.net"
  (save-excursion
    (let* ((beg (progn (skip-chars-backward "[:alnum:]-") (point)))
           (end (progn (skip-chars-forward "[:alnum:]-") (point)))
           (str (buffer-substring-no-properties beg end)))
      (save-match-data
        (when (string-match "[[:upper:]]+-[[:digit:]]+" str)
          `(url
            ,(format "https://%s/browse/%s"
                     (getenv "EMACS_MY_JIRA_URL")
                     (match-string 0 str))
            ,beg . ,end))))))

(defun my-visit-bitbucket-cloud-new-pull-request-url ()
  "Go to Bitbucket Cloud to create a new Pull Request for current git repo"
  (interactive)
  (let* ((url (vc-git-repository-url "."))
         (url-str (split-string url "[@.:/]+"))
         (workspace (nth 3 url-str))
         (repo (nth 4 url-str)))
    (browse-url
     (format "https://bitbucket.com/%s/%s/pull-requests/new"
             workspace repo))))
