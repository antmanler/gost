NAME=gost
HARDWARE=amd64
PKG=github.com/antmanler/gost
GITREV=$(shell git rev-parse --short HEAD)$(shell if ! git diff --quiet HEAD; then echo "-dirty"; fi )
VERSION=dev
RELEASE_VERSION=2.0-$(shell date +%Y%m%d)

build: gost

release: VERSION=$(RELEASE_VERSION)
release: build
	@rm -rf release && mkdir release
	GZIP=-9 tar -zcf release/$(NAME)_$(RELEASE_VERSION)_linux_$(HARDWARE).tgz -C build/linux gost
	GZIP=-9 tar -zcf release/$(NAME)_$(RELEASE_VERSION)_darwin_$(HARDWARE).tgz -C build/darwin gost
	GZIP=-9 tar -zcf release/$(NAME)_$(RELEASE_VERSION)_windows_$(HARDWARE).tgz -C build/windows gost.exe

gost: build_dir
	GO15VENDOREXPERIMENT=1 GOOS=linux GOARCH=amd64 \
		go build -tags netgo -installsuffix netgo -ldflags \
		"-X main.version=$(VERSION) -X main.gitRev=$(GITREV)" \
		-o build/linux/gost .
	GO15VENDOREXPERIMENT=1 GOOS=darwin GOARCH=amd64 \
		go build -tags netgo -installsuffix netgo -ldflags \
		"-X main.version=$(VERSION) -X main.gitRev=$(GITREV)" \
		-o build/darwin/gost .
	GO15VENDOREXPERIMENT=1 GOOS=windows GOARCH=amd64 \
		go build -tags netgo -installsuffix netgo -ldflags \
		"-X main.version=$(VERSION) -X main.gitRev=$(GITREV)" \
		-o build/windows/gost.exe .

build_dir:
	@mkdir -p build/linux
	@mkdir -p build/darwin
	@mkdir -p build/windows

.PHONY: build
