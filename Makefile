.PHONY: help
help:
	@echo "Usage for libvirt-k8s-provisioner:"
	@echo "    create                   to create the cluster"
	@echo "    debug                    to create the cluster with debug options"
	@echo "    destroy                  to destroy the cluster"
	@echo "    setup                    to install Ansible 2.10"
.PHONY: bootstrap
setup:
	pip3 install ansible
.PHONY: install
create:
	ansible-playbook main.yml
.PHONY: debug
debug:       
	ansible-playbook main.yml -vv
.PHONY: debug
destroy:
	ansible-playbook 99_cleanup.yml 

.PHONY: check
check:
ifneq (,$(shell lsb_release -si))
	echo "HI"
else echo "HIHO"
endif 

