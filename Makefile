# See: http://clarkgrubb.com/makefile-style-guide
SHELL             := bash
.SHELLFLAGS       := -eu -o pipefail -c
.DEFAULT_GOAL     := default
.DELETE_ON_ERROR:
.SUFFIXES:

# Constants, these can be overwritten in your Makefile.local
BUILD_SERVER := magneticio/buildserver

# if Makefile.local exists, include it.
ifneq ("$(wildcard Makefile.local)", "")
	include Makefile.local
endif

# Directories
PROJECT := vamp-gateway-agent
SRCDIR  := $(CURDIR)
DESTDIR := target

# Determine which version we're building
ifeq ($(shell git describe --tags),$(shell git describe --abbrev=0 --tags))
	export VERSION := $(shell git describe --tags)
else
	export VERSION := katana
endif


# Using our buildserver which contains all the necessary dependencies
.PHONY: default
default: docker-context docker


.PHONY: docker-context
docker-context:
	@echo "Creating docker build context"
	mkdir -p $(DESTDIR)/docker
	cp $(SRCDIR)/Dockerfile $(DESTDIR)/docker/Dockerfile
	cp -Rf $(SRCDIR)/files $(DESTDIR)/docker
	echo $(VERSION) $$(git describe --tags) > $(DESTDIR)/docker/version

.PHONY: docker
docker:
	docker build \
		--tag=magneticio/$(PROJECT):$(VERSION) \
		--file=$(DESTDIR)/docker/Dockerfile \
		$(DESTDIR)/docker

.PHONY: clean
clean:
	rm -rf $(DESTDIR)/docker

.PHONY: clean-docker
clean-docker:
	docker rmi magneticio/$(PROJECT):$(VERSION)
