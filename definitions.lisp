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

(defgeneric metadata-body-reader (stream data))

(defclass subframe ()
  ((wasted-bps :accessor subframe-wasted-bps :initarg :wasted-bps)))

(defclass subframe-constant (subframe)
  ((constant-value :accessor subframe-constant-value)))

(defclass subframe-verbatim (subframe)
  ((buffer :accessor subframe-verbatim-buffer)))

(defclass subframe-lpc (subframe)
  ((warm-up :accessor subframe-warm-up)
   (predictor-coeff :accessor subframe-lpc-predictor-coeff)
   (coeff-shift :accessor subframe-lpc-coeff-shift)
   (residual :accessor subframe-residual)))

(defgeneric subframe-body-reader (stream subframe frame))
(defgeneric subframe-decode (subframe frame))

(defclass frame ()
  ((streaminfo :accessor frame-streaminfo :initarg :streaminfo)
   (blocking-strategy :accessor frame-blocking-strategy)
   (block-size :accessor frame-block-size)
   (sample-rate :accessor frame-sample-rate)
   (channel-assignment :accessor frame-channel-assignment)
   (sample-size :accessor frame-sample-size)
   (number :accessor frame-number)
   (crc-8 :accessor frame-crc-8)
   (subframes :accessor frame-subframes)
   (crc-16 :accessor frame-crc-16)))

(defparameter +block-name+ '(streaminfo padding application seektable vorbis-comment cuesheet picture)) ;; In case of using sbcl defconstant will give an error
(defconstant +frame-sync-code+ 16382) ; 11111111111110

;; Other stuff

(defun get-metadata-type (code)
  (if (= code 127) (error "Code 127 is invalid"))
  (nth code +block-name+))

(defun bytes-to-integer-big-endian (array)
  (declare (type (simple-array u8) array))
  (loop for i below (length array) sum
	(let ((mul (expt 2 (* 8 (- (length array) 1 i)))))
	 (* mul (aref array i)))))

(defun read-to-integer (stream num &optional (func #'bytes-to-integer-big-endian))
  (let ((buffer (make-array num :element-type 'u8)))
    (read-sequence buffer stream)
    (funcall func buffer)))

(defun octets-to-n-bit-bytes (array new-array n)
  "n mod 8 must be 0
   big endian
   definitely a bottleneck"
  (declare
   (type (simple-array u8) array)
   (type integer n))
  (let ((scale (/ n 8)))
    
    (loop for i below (length new-array) do
	  (let ((start (* i scale)))
	    (setf (aref new-array i)
		  (loop for j from start to (+ start scale -1) sum
			(* (expt 2 (* 8 (+ start scale (- 0 1 j))))
			   (aref array j))))))
    new-array))
