;;; msn.el --- Client to get BibTeX entries from MathSciNet

;; Copyright (C) 2001 by Nevin Kapur

;; Author: Nevin Kapur <kapur@mts.jhu.edu>
;; Keywords: tex, www, wp
;; Created: May 25, 2001
;; Version: 1.1
;; URL: http://www.mts.jhu.edu/~kapur/emacs/msn.el
;; Compatibility: XEmacs 21.1, 21.4

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with XEmacs; see the file COPYING.  If not, write to the Free
;; Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
;; 02111-1307, USA.



;;; Commentary:

;; If, like me, you use LaTeX/BibTeX to manage the references in your
;; technical writings, you will find the database at MathSciNet
;; (http://www.ams.org/mathscinet) useful. It provides a standardized
;; format for references which can be put directly in a .bib file.

;; This library provides an interface to this facility. On invocation,
;; it queries the user for an author and title and fetches the BibteX
;; entries using the form at http://www.ams.org/mathscinet/search. The
;; result will be a

;; (a) W3 buffer with the search results, or
;; (b) bibtex-mode buffer with the search results parsed out

;; depending on the variable msn-use-w3. The default is to use W3.

;; Note: Access to the database is restricted and subscribtion is
;; required.

;;; Usage:
;; byte-compile-file and put it in your load-path. In your
;; initialization file:

;; (require 'msn)

;; M-x msn invokes the interface.


;; $Id: msn.el,v 1.1.1.1 2001/09/17 15:37:05 nevin Exp $

;; $Log: msn.el,v $
;; Revision 1.1.1.1  2001/09/17 15:37:05  nevin
;; Initial import.
;;
;; Revision 1.6  2001/06/10 02:07:39  kapur
;; * msn.el (msn-fetch): Revision from Carl Mueller
;; <cmlr@math.rochester.edu>: Break up parameters for the input to
;; MSN form.
;;
;; Revision 1.4  2001/05/26 13:25:00  kapur
;; - Doc fixes.
;;
;; Revision 1.3  2001/05/26 02:55:13  kapur
;; * msn.el: Option to use either W3 or bibtex-mode.
;;
;; Revision 1.2  2001/05/26 01:55:56  kapur
;; * msn.el: Initial working version.
;;
;; Revision 1.1.1.1  2001/05/25 22:29:17  kapur
;; Skeleton.
;;


;;; Code:

(defvar msn-use-w3 nil
  "Use W3 to render the results of the search. If this variable is set to nil then the BibTeX information will be parsed and presented in a BibTeX buffer.")

;; These functions are modified versions from Eric Marsden's
;; dictweb.el.

(defun msn ()
  "Run the MathSciNet client."
  (interactive)
  (let ((author (read-string "Author: "))
	(title (read-string "Title: ")))
    (pop-to-buffer "*MathSciNet Results*")
    (erase-buffer)
    (msn-fetch author title)
    (cond (msn-use-w3
	   (w3-region (point-min) (point-max)))
	  (t
	   (msn-wash)
	   (bibtex-mode)
	   (font-lock-mode 1)
	   (goto-char (point-min))))
  (setq buffer-file-name nil)))

(defun msn-fetch (author title)
  "Fetch data and print it in the current buffer."
  (require 'url)
  (let* ((pairs `(("bdlback" . "r=1")
		  ("dr" . "all")
		  ("l" . "20")
		  ("pg3" . "TI")
		  ("s3" . ,title)
		  ("pg4" . "ICN")
		  ("s4" . ,author)
		  ("fn" . "130")
		  ("fmt" . "bibtex")
		  ("bdlall" . "Retrieve+All")))
	 (url-request-data (msn-form-encode pairs))
	 (url-request-method "POST")
	 (url-request-extra-headers
	  '(("Content-type" . "application/x-www-form-urlencoded"))))
    (url-insert-file-contents "http://www.ams.org/msnmain/MathSci")))

(defun msn-wash ()
  "Wash the output returned."
  (goto-char (point-min))
  (let ((case-fold-search t))
    (when (re-search-forward "^@" nil t)
      (delete-region (point-min) (match-beginning 0)))
    (goto-char (point-max))
    (when (re-search-backward "</pre>" nil t)
      (delete-region (point-max) (match-beginning 0)))
    ;; Handle the case when nothing matches
    (goto-char (point-min))
    (when (re-search-forward "No Records Selected" nil t)
      (delete-region (point-min) (match-beginning 0)))
    (goto-char (point-max))
    (when (re-search-backward "</title>" nil t)
      (delete-region (point-max) (match-beginning 0)))))

	 
(defun msn-form-encode (pairs)
  "Return PAIRS encoded for forms."
  (require 'w3-forms)
  (mapconcat
   (function
    (lambda (data)
      (concat (w3-form-encode-xwfu (car data)) "="
	      (w3-form-encode-xwfu (cdr data)))))
   pairs "&"))


(provide 'msn)

;;; msn.el ends here
