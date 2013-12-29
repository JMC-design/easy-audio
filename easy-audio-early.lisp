;; Copyright (c) 2012-2013, Vasily Postnicov
;; All rights reserved.

;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are met: 

;; 1. Redistributions of source code must retain the above copyright notice, this
;;   list of conditions and the following disclaimer. 
;; 2. Redistributions in binary form must reproduce the above copyright notice,
;;   this list of conditions and the following disclaimer in the documentation
;;   and/or other materials provided with the distribution. 

;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
;; ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
;; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;; Comment it out if you do not want restrictions
(eval-when (:load-toplevel :compile-toplevel :execute)
  (pushnew :easy-audio-use-fixnums *features*)
  (pushnew :easy-audio-unsafe-code *features*))

(eval-when (:load-toplevel :compile-toplevel :execute)
  (defun type-decl-func (stream sub-char num)
    (declare (ignore sub-char num))
    (let ((type (read stream))
          (form (read stream)))
      #-easy-audio-use-fixnums (declare (ignore type))
      #+easy-audio-use-fixnums `(the ,type ,form)
      #-easy-audio-use-fixnums form))

  (set-dispatch-macro-character #\# #\f #'type-decl-func))

(defpackage easy-audio-debug
  (:use :cl)
  (:nicknames :debug)
  (:export #:*current-condition*
           #:with-interactive-debug))

(in-package :easy-audio-debug)

(defvar *current-condition*)

(defmacro with-interactive-debug (&body body)
  (let ((debugger-hook (gensym)))
    `(let ((,debugger-hook *debugger-hook*))
       (flet ((,debugger-hook (condition me)
                (declare (ignore me))
                (let ((*debugger-hook* ,debugger-hook)
                      (*current-condition* condition))
                  (invoke-debugger condition))))

         (let ((*debugger-hook* #',debugger-hook))
           ,@body)))))
