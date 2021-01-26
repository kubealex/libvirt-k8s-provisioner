.PHONY: bootstrap
bootstrap:
        pip3 install ansible
.PHONY: install
install:
        ansible-playbook main.yml
.PHONY: debug
debug:        
		ansible-playbook main.yml -vv
