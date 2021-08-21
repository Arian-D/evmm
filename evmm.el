(cl-defstruct vm
  "Virtual machine struct representation"
  (backend 'kvm)
  (name nil)
  (description "")
  (disk nil)
  (img nil)
  (ram 1024)
  (cpu 1))

(defcustom evmm-vms ()
  "List of virtual machines."		 ; TODO: Add examples
  :type '(repeat vm))

(defun evmm-start-vm (vm)
  "Start the given vm using qemu-kvm. Other backends will be added
later (VBox, VMware, and libvirtd)"
  (interactive
   (list
    (let ((vm-name (completing-read "> " (mapcar 'vm-name evmm-vms))))
      (car (seq-filter
	    (lambda (the-vm)
	      (string-equal (vm-name the-vm) vm-name))
	    evmm-vms)))))
  (async-shell-command
   (concat "qemu-system-x86_64 "
	   (if (vm-backend vm) " -enable-kvm ")
	   (if (vm-name vm) (format " -name '%s' " (vm-name vm)))
	   (if (vm-img vm) (format " -cdrom '%s' " (vm-img vm)))
	   (if (vm-disk vm) (format " -hda '%s' " (vm-disk vm)))
	   " -m " (number-to-string (vm-ram vm))
	   " -smp " (number-to-string (vm-cpu vm))
	   " -daemonize"
	   )))

(defun evmm-create-qemu-disk (vm size format)
  "Create a new disk image using qemu-img"
  (if (file-exists-p (vm-disk vm))
      (error "The disk already exists")
    (async-shell-command
     (concat "qemu-img create "
	     (if format (concat "-f " format))
	     " " (vm-disk vm)
	     " " (number-to-string size) "G"))))	; TODO: Change to MB or `string'

(defun evmm-install-vm ()
  "Interactive function to install an OS."
  (interactive)
  (let* ((img (read-file-name "Image location (usually ends in .iso): "))
	 (disk (read-file-name
		"Disk that will be created (Should end in vmdk or qcow): "))
	 (ram (read-number "Amount of RAM in MB: " 2048))
	 (cpu (read-number "Number of CPU cores for the VM: " 2))
	 (name (read-buffer "What would you like to call it? "))
	 (created-vm (make-vm :name name
			      :disk disk
			      :ram ram
			      :img img
			      :cpu cpu)))
    ;; Create the disk if it doesn't already exist
    (unless (file-exists-p disk)
      (let ((size
	     (read-number "How big should the disk be (in G)? " 20)))
	(evmm-create-qemu-disk created-vm size "qcow2")))  ; TODO: Detect the format based on file extension
    ;; Add it to our list of VMs without the `img'
    (add-to-list 'evmm-vms
		 (make-vm :name name
			  :disk disk
			  :ram ram
			  :cpu cpu))
    (evmm-start-vm created-vm)))

(provide 'evmm)
