#
# Copyright (C) 2008 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

###########################################################
## Output the command lines, or not
###########################################################
ifeq ($(strip $(SHOW_COMMANDS)),)
hide := @
else
hide :=
endif

reeftas-emu : MACHINE := reeftas-qemux86

TOP := $(abspath .)
OUT ?= $(abspath $(TOP)/out/$(MACHINE))

REEFTAS_DOCKER_BUILDER_IMAGE := reeftas-builder
REEFTAS_DOCKER_EMULATOR_IMAGE := reeftas-emulator
REEFTAS_DOCKER_IMAGE_VERSION ?= latest
REEFTAS_DOCKER_BUILDER_IMAGE_ID := $(shell docker images -q $(REEFTAS_DOCKER_BUILDER_IMAGE):$(REEFTAS_DOCKER_IMAGE_VERSION))
REEFTAS_DOCKER_EMULATOR_IMAGE_ID := $(shell docker images -q $(REEFTAS_DOCKER_EMULATOR_IMAGE):$(REEFTAS_DOCKER_IMAGE_VERSION))
IMAGE ?= reeftas-image

build-reeftas-docker-image:
ifeq ($(REEFTAS_DOCKER_BUILDER_IMAGE_ID),)
	cd $(TOP)/build/docker/builder && docker build -t $(REEFTAS_DOCKER_BUILDER_IMAGE):$(REEFTAS_DOCKER_IMAGE_VERSION) .
endif

build-reeftas-emu-docker-image:
ifeq ($(REEFTAS_DOCKER_EMULATOR_IMAGE_ID),)
	cd $(TOP)/build/docker/emulator && docker build -t $(REEFTAS_DOCKER_EMULATOR_IMAGE):$(REEFTAS_DOCKER_IMAGE_VERSION) .
endif

$(OUT):
	$(hide) mkdir -p $@

reeftas: build-reeftas-docker-image $(OUT)
	$(hide) bash $(TOP)/build/docker/builder/run.sh \
					--rm \
					-v $(TOP):$(TOP) \
					-e REEFTAS_ROOT=$(TOP) \
				 	-e REEFTAS_OUT=$(OUT) \
					-e MACHINE=$(MACHINE) \
					-e IMAGE=$(IMAGE) \
					$(REEFTAS_DOCKER_BUILDER_IMAGE):$(REEFTAS_DOCKER_IMAGE_VERSION)

reeftas-emu : reeftas build-reeftas-emu-docker-image
	$(hide) bash $(TOP)/build/docker/emulator/run.sh \
					--rm \
					-v $(TOP):$(TOP) \
					-e REEFTAS_ROOT=$(TOP) \
				 	-e REEFTAS_OUT=$(OUT) \
					-e MACHINE=$(MACHINE) \
					-e IMAGE=$(IMAGE) \
					$(REEFTAS_DOCKER_EMULATOR_IMAGE):$(REEFTAS_DOCKER_IMAGE_VERSION)
clean:
	$(hide) rm -fr $(OUT)
	$(hide) docker rmi $(REEFTAS_DOCKER_BUILDER_IMAGE):$(REEFTAS_DOCKER_IMAGE_VERSION)
	$(hide) docker rmi  $(REEFTAS_DOCKER_EMULATOR_IMAGE):$(REEFTAS_DOCKER_IMAGE_VERSION)

.PHONY:reeftas
all:reeftas
