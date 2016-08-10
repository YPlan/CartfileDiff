TEMPORARY_FOLDER?=/tmp/cartfilediff.dst
PREFIX?=/usr/local

XCODEFLAGS=-workspace 'CartfileDiff.xcworkspace' -scheme 'cartfilediff' DSTROOT=$(TEMPORARY_FOLDER)

OUTPUT_PACKAGE=CartfileDiff.pkg
OUTPUT_FRAMEWORK=CartfileDiffKit.framework

BUILT_BUNDLE=$(TEMPORARY_FOLDER)/Applications/cartfilediff.app
CARTFILEDIFFKIT_BUNDLE=$(BUILT_BUNDLE)/Contents/Frameworks/$(OUTPUT_FRAMEWORK)
CARTFILEDIFF_EXECUTABLE=$(BUILT_BUNDLE)/Contents/MacOS/cartfilediff

FRAMEWORKS_FOLDER=/Library/Frameworks
BINARIES_FOLDER=/usr/local/bin

VERSION_STRING=$(shell agvtool what-marketing-version -terse1)
COMPONENTS_PLIST=Sources/Components.plist

.PHONY: all bootstrap clean install package test uninstall

all: bootstrap
	xcodebuild $(XCODEFLAGS) build

bootstrap:
	git submodule update --init --recursive

test: clean bootstrap
	xcodebuild $(XCODEFLAGS) test

clean:
	rm -f "$(OUTPUT_PACKAGE)"
	rm -rf "$(TEMPORARY_FOLDER)"
	xcodebuild $(XCODEFLAGS) clean

install: package
	sudo installer -pkg CartfileDiff.pkg -target /

uninstall:
	rm -rf "$(FRAMEWORKS_FOLDER)/$(OUTPUT_FRAMEWORK)"
	rm -f "$(BINARIES_FOLDER)/cartfilediff"

installables: clean bootstrap
	xcodebuild $(XCODEFLAGS) install

	mkdir -p "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)" "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)"
	mv -f "$(CARTFILEDIFFKIT_BUNDLE)" "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)/$(OUTPUT_FRAMEWORK)"
	mv -f "$(CARTFILEDIFF_EXECUTABLE)" "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/cartfilediff"
	# rm -rf "$(BUILT_BUNDLE)"

prefix_install: installables
	mkdir -p "$(PREFIX)/Frameworks" "$(PREFIX)/bin"
	cp -Rf "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)/$(OUTPUT_FRAMEWORK)" "$(PREFIX)/Frameworks/"
	cp -f "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/cartfilediff" "$(PREFIX)/bin/"
	install_name_tool -add_rpath "@executable_path/../Frameworks/$(OUTPUT_FRAMEWORK)/Versions/Current/Frameworks/"  "$(PREFIX)/bin/cartfilediff"

package: installables
	pkgbuild \
		--component-plist "$(COMPONENTS_PLIST)" \
		--identifier "com.yplanapp.cartfilediff" \
		--install-location "/" \
		--root "$(TEMPORARY_FOLDER)" \
		--version "$(VERSION_STRING)" \
		"$(OUTPUT_PACKAGE)"
