#DEVCONTAINER := ~/.devcontainers/bin/devcontainer
DEVCONTAINER := devcontainer

.PHONY: build build-dind build-golang-alpine build-golang-dind

build: build-dind build-golang-alpine build-golang-dind

build-dind:
	$(DEVCONTAINER) build --workspace-folder $(CURDIR) --config $(CURDIR)/.devcontainer/dind/devcontainer.json --image-name cc-dind

build-golang-alpine:
	$(DEVCONTAINER) build --workspace-folder $(CURDIR) --config $(CURDIR)/.devcontainer/golang-alpine/devcontainer.json --image-name cc-golang-alpine

build-golang-dind:
	$(DEVCONTAINER) build --workspace-folder $(CURDIR) --config $(CURDIR)/.devcontainer/golang-dind/devcontainer.json --image-name cc-golang-dind
