.PHONY: help
help:
	@echo "Usage for libvirt-k8s-provisioner:"
	@echo "    create                   to create the cluster"
	@echo "    debug                    to create the cluster with debug options"
	@echo "    destroy                  to destroy the cluster"
.PHONY: install
create:
	ansible-playbook main.yml
.PHONY: debug
debug:       
	ansible-playbook main.yml -vv
.PHONY: debug
destroy:
	ansible-playbook 99_cleanup.yml -v
