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
  "List of virtual machines."
  :type '(repeat vm))

(defun evmm-start-vm (vm)
  "Start the given vm using qemu-kvm. Other backends will be added
later (VBox, VMware, and libvirtd)"
  (async-shell-command
   (concat "qemu-kvm "
	   (if (vm-name vm) (format "-name '%s' " (vm-name vm)))
	   (if (vm-img vm) (format "-cdrom '%s' " (vm-img vm)))
	   (if (vm-disk vm) (format "-hda '%s' " (vm-disk vm)))
	   "-m " (number-to-string (vm-ram vm)) " "
	   "-smp " (number-to-string (vm-cpu vm)))))

(defun evmm-create-qemu-disk (vm size format)
  "Create a new disk image using qemu-img"
  (if (file-exists-p (vm-disk vm))
      (error "The disk already exists")
    (concat "qemu-img create "
	    (if format (concat "-f " format))
	    " " (vm-disk vm)
	    (number-to-string size))))	; TODO: Change to MB or signifier

(defun evmm--test ()
  "Example to work with"
  (defvar windowyyyy
    (make-vm :name "Windows 10 dev"
	     :description "Dev environment"
	     :disk (concat (getenv "HOME") "/vms/windev.qcow")
	     :ram 8192))
  (start-kvm windowyyyy))

(provide 'evmm)
