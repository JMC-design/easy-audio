(in-package :cl-flac)

(defun open-flac (name)
  (let ((stream (open name :element-type '(unsigned-byte 8))))

    ;; Checking if stream is flac stream
    (let ((flac-header-array (make-array 4 :element-type 'u8)))
      (read-sequence flac-header-array stream)
      (if (not (string= "fLaC" (babel:octets-to-string flac-header-array))) (error "Stream is not flac stream")))


    (let* ((bitreader (make-reader :stream stream))
	   (metadata-blocks
	    (loop for metadata-block = (metadata-reader bitreader)
		  collect metadata-block
		  while (null (slot-value metadata-block 'last-block-p)))))
      
      (values
       metadata-blocks
       bitreader))))
