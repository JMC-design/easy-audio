(in-package :cl-flac)

(deftype u8 () '(unsigned-byte 8))

(defclass metadata-header ()
  (last-block-p type length rawdata))

(defclass streaminfo (metadata-header)
  (minblocksize
   maxblocksize
   minframesize
   maxframesize
   samplerate
   channels-1
   bitspersample-1
   totalsamples
   md5))

(defclass frame ()
  ((streaminfo :accessor frame-streaminfo :initarg :streaminfo)
   (blocking-strategy :accessor frame-blocking-strategy)
   (block-size :accessor frame-block-size)
   (sample-rate :accessor frame-sample-rate)
   (channel-assignment :accessor frame-channel-assignment)
   (sample-size :accessor frame-sample-size)
   (number :accessor frame-number)
   crc-8))

(defparameter +block-name+ '(streaminfo padding application seektable vorbis-comment cuesheet picture)) ;; In case of using sbcl defconstant will give an error
(defconstant +frame-sync-code+ 16382) ; 11111111111110

;; Other stuff

(defun get-reader (code)
  (if (= code 127) (error "Code 127 is invalid"))
  (let ((sym-name (intern (concatenate 'string (symbol-name (nth code +block-name+)) "-READER")
			  (find-package :cl-flac)))) ;; FIXME :: it would be better if +block-name+ is assoc list
    (symbol-function sym-name)))

(defun bytes-to-integer-big-endian (list)
  (let* ((mul (expt 2 (* 8 (1- (length list)))))
	 (position-value (* mul (car list))))
    (if (cdr list)
	(+ position-value (bytes-to-integer-big-endian (cdr list)))
      position-value)))

(defun read-to-integer (stream num &optional (func #'bytes-to-integer-big-endian))
  (let ((lst (make-list num)))
    (read-sequence lst stream)
    (funcall func lst)))
