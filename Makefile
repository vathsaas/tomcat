.PHONY: release package-jar docker
.DEFAULT_GOAL = release

SRCDIR            := $(shell pwd)
BUILD_NUMBER      ?= 1
ITERATION         := $(BUILD_NUMBER).git+$(shell git rev-parse --short HEAD)
APPNAME	          = xen-tomcat
FPM_CONTAINER     = skandyla/fpm
BUILD_PATH        = /opt/xen/tomcat
DOCKER_RUN_FPM    = docker run --rm -i -v $(SRCDIR):/code/tomcat/ -w /code/tomcat $(FPM_CONTAINER)
ISODATE           = $(shell date -u +%Y%m%d_%H%M%S)

SHORT_GIT_COMMIT ?= $(shell git rev-parse --short HEAD)
GIT_TAG          ?= $(shell git show-ref --tags -d \
               | grep $(SHORT_GIT_COMMIT) \
               | sed -e 's,.* refs/tags/,,' -e 's/\\^{}//')
LATEST_GIT_TAG   ?= $(shell git tag | sort -r -t. -n -k1,1 -k2,2 -k3,3 | sed -n 1p)

ifneq "$(strip $(GIT_TAG))" ""
    VERSION = $(GIT_TAG)
else
    VERSION = $(shell date +%s)
endif

release: docker package-jar

package-jar:
	$(DOCKER_RUN_FPM) \
		              -s dir \
					  -t rpm \
						-v $(VERSION) \
						--iteration=$(ITERATION) \
					  -n $(APPNAME) \
					  $(BUILD_PATH)/

docker:
	docker pull $(FPM_CONTAINER)
