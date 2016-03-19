
BRANCH?=$(shell git rev-parse --abbrev-ref HEAD)

all: test clean

watch: test_deps
	while sleep 1; do \
		find defaults/ handlers/ meta/ tasks/ templates/ \
		| entr -d make vagrant_up; \
	done

test: test_deps vagrant_up

integration_test: clean integration_test_deps vagrant_up clean

test_deps:
	rm -rf tests/ansible-city.gocd_server
	ln -s .. tests/ansible-city.gocd_server
	ansible-galaxy install --force -p tests -r tests/local_requirements.yml

integration_test_deps:
	sed -i.bak \
		-E 's/(.*)version: (.*)/\1version: origin\/$(BRANCH)/' \
		tests/integration_requirements.yml
	rm -rf tests/ansible-city.*
	ansible-galaxy install -p tests -r tests/integration_requirements.yml
	mv tests/integration_requirements.yml.bak tests/integration_requirements.yml

vagrant_up:
	cd tests/vagrant && vagrant up --no-provision
	cd tests/vagrant && vagrant provision

vagrant_ssh:
	cd tests/vagrant && vagrant up --no-provision
	cd tests/vagrant && vagrant ssh

clean:
	rm -rf tests/ansible-city.*
	cd tests/vagrant && vagrant destroy
