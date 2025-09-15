
PROJECT  = Spaceman
APPNAME  = $(PROJECT).app
BUILDDIR = build
ARCHIVE  = $(BUILDDIR)/$(PROJECT).xcarchive
IMAGEDIR = $(BUILDDIR)/diskimage
APPFILE  = $(IMAGEDIR)/$(APPNAME)
PBXPROJ  = $(PROJECT).xcodeproj/project.pbxproj
VERSION  = $(shell awk -F'["; ]*' '/MARKETING_VERSION/ { print $$3; exit }' $(PBXPROJ))
IMAGE    = $(BUILDDIR)/$(PROJECT)-$(VERSION).dmg
AUTHOR   = ruittenb
DOMAIN   = dev.$(AUTHOR).$(PROJECT)

.DEFAULT_GOAL := help

.PHONY: help # See https://tinyurl.com/makefile-autohelp
help: ## Print help for each target
	@awk -v tab=15 'BEGIN{FS="(:.*## |##@ |@## )";c="\033[36m";m="\033[0m";y="  ";a=2;h()}function t(s){gsub(/[ \t]+$$/,"",s);gsub(/^[ \t]+/,"",s);return s}function u(g,d){split(t(g),f," ");for(j in f)printf"%s%s%-"tab"s%s%s\n",y,c,t(f[j]),m,d}function h(){printf"\nUsage:\n%smake %s<target>%s\n\nRecognized targets:\n",y,c,m}/\\$$/{gsub(/\\$$/,"");b=b$$0;next}b{$$0=b$$0;b=""}/^[-a-zA-Z0-9*\/%_. ]+:.*## /{p=sprintf("\n%"(tab+a)"s"y,"");gsub(/\\n/,p);if($$1~/%/&&$$2~/^%:/){n=split($$2,q,/%:|:% */);for(i=2;i<n;i+=2){g=$$1;sub(/%/,q[i],g);u(g,q[i+1])}}else if($$1~/%/&&$$2~/%:[^%]+:[^%]+:%/){d=$$2;sub(/^.*%:/,"",d);sub(/:%.*/,"",d);n=split(d,q,/:/);for(i=1;i<=n;i++){g=$$1;d=$$2;sub(/%/,q[i],g);sub(/%:[^%]+:%/,q[i],d);u(g,d)}}else u($$1,$$2)}/^##@ /{gsub(/\\n/,"\n");if(NF==3)tab=$$2;printf"\n%s\n",$$NF}END{print""}' $(MAKEFILE_LIST) # v1.62

.PHONY: build
build: ## Make the archive file
	make $(ARCHIVE)

$(ARCHIVE): $(PBXPROJ)
	xcodebuild -workspace $(PROJECT).xcodeproj/project.xcworkspace -scheme $(PROJECT) -configuration Release clean archive -archivePath $(ARCHIVE)

.PHONY: export
export: ## Make the app file
	make $(APPFILE)

$(APPFILE): $(ARCHIVE)
	xcodebuild -exportArchive -archivePath $(ARCHIVE) -exportOptionsPlist $(PROJECT)/exportOptions.plist -exportPath $(IMAGEDIR)
	touch $(APPFILE)

.PHONY: image
image: ## Make the dmg image file
	make $(IMAGE)

$(IMAGE): $(APPFILE)
	create-dmg \
		--volname "Spaceman Installer"                           \
		--volicon $(IMAGEDIR)/.VolumeIcon.icns                   \
		--background $(IMAGEDIR)/.background/dmg-background.tiff \
		--window-pos 200 120                                     \
		--window-size 640 440                                    \
		--icon-size 128                                          \
		--icon Spaceman.app 170 170                              \
		--icon Applications 470 170                              \
		--hide-extension Spaceman.app                            \
		--app-drop-link 470 170                                  \
		--no-internet-enable                                     \
		$(IMAGE)                                                 \
		$(IMAGEDIR) # source folder

all: image ## Make all of the above


##@ Publishing:

.PHONY: tag
tag: ## Tag the current HEAD with the version from the XCode project
	git tag v$(VERSION)
	git push --tags

.PHONY: appcast
appcast: ## Prepare appcast for publishing
	git checkout main
	$(BUILDDIR)/make-appcast.sh > website/appcast.xml
	git add website/appcast.xml
	@printf "\nCreated appcast.xml, now please commit it\n"

.PHONY: publish
publish: ## Publish the main branch appcast on Github Pages
	git subtree push --prefix website origin main:github-pages

.PHONY: publish-force
# git subtree split --prefix website -b github-pages # create a local github-pages branch containing the splitted output folder
# git push -f origin github-pages:github-pages       # force push the github-pages branch to origin
publish-force: ## Publish the main branch appcast on Github Pages (force push)
	git checkout main
	git push --force-with-lease origin `git subtree split --prefix website main`:github-pages


##@ Homebrew:

.PHONY: brew-update
brew-update: ## Update the spaceman.rb file with the correct version
	cd $(shell brew --repo ruittenb/tap)/Casks &&                           \
	awk -v version=$(VERSION) -v shaout="$(shell shasum -a 256 $(IMAGE))" ' \
	/version "[0-9.]"/ {                                                    \
		print "  version \"" version "\""; next                             \
	}                                                                       \
	/sha256/ {                                                              \
		split(shaout, sha);                                                 \
		print "  sha256 \"" sha[1] "\""; next                               \
	} {                                                                     \
		print                                                               \
	}' < spaceman.rb > spaceman.rb.new
	mv spaceman.rb.new spaceman.rb
	@echo "Please verify the file spaceman.rb and run 'make brew-publish'"

.PHONY: brew-publish
brew-publish: ## Publish the new spaceman.rb so that homebrew can find it
	cd $(shell brew --repo ruittenb/tap)     && \
	git commit Casks -m "Version $(VERSION)" && \
	git push


##@ Defaults:

.PHONY: defaults-clear
defaults-clear: ## Clear app defaults
	defaults delete $(DOMAIN)

.PHONY: defaults-get
defaults-get: ## Show stored app defaults
	defaults read $(DOMAIN) # spaceNameCache

