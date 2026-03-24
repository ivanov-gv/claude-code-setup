.PHONY: build build-dind build-golang-alpine build-golang-dind

build: build-dind build-golang-alpine build-golang-dind

build-dind:
	devcontainer build --workspace-folder . --config .devcontainer/dind/devcontainer.json --image-name cc-dind

build-golang-alpine:
	devcontainer build --workspace-folder . --config .devcontainer/golang-alpine/devcontainer.json --image-name cc-golang-alpine

build-golang-dind:
	devcontainer build --workspace-folder . --config .devcontainer/golang-dind/devcontainer.json --image-name cc-golang-dind
