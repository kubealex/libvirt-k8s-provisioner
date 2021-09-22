.PHONY: help
help:
	@echo "Usage for libvirt-k8s-provisioner:"
	@echo "    setup                    to install required collections"
	@echo "    create                   to create the cluster"
	@echo "    debug                    to create the cluster with debug options"
	@echo "    destroy                  to destroy the cluster"
.PHONY: setup
setup:
	@ansible-galaxy collection install -r requirements.yml
.PHONY: create
create:
	@ansible-playbook main.yml
.PHONY: debug
debug:       
	@ansible-playbook main.yml -vv
.PHONY: destroy
destroy:
	@ansible-playbook 99_cleanup.yml
