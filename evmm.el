(cl-defstruct vm
  "Virtual machine struct representation"
  (backend 'kvm)
  (name nil)
  (description "")
  (disk nil)
  (img nil)
  (ram 1024)
  (cpu 1))


(defun start-vm (vm)
  (interactive "vVM? ")
  (when (vm-p vm)
    (cond ((eq (vm-backend vm) 'kvm) (start-kvm vm))
	  (t (error "Sadly, the backend is not provided.")))))

(defun start-kvm (vm)
  (async-shell-command
   (concat "qemu-kvm "
	   (if (vm-name vm) (format "-name '%s' " (vm-name vm)))
	   (if (vm-img vm) (format "-cdrom '%s' " (vm-img vm)))
	   (if (vm-disk vm) (format "-hda '%s' " (vm-disk vm)))
	   "-m " (number-to-string (vm-ram vm)) " "
	   "-smp " (number-to-string (vm-cpu vm)))))


;;; Example to work with

(defvar a
  (make-vm :name "Windows 10 dev"
	   :description "Dev environment"
	   :disk (concat (getenv "HOME") "/vms/windev.qcow")))

(start-kvm a)

(provide 'evmm)
