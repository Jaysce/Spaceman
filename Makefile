
PROJECT = Spaceman
ARCHIVE = build/$(PROJECT).xcarchive
APP = build/$(PROJECT).app
PBXPROJ = $(PROJECT).xcodeproj/project.pbxproj
VERSION = $(shell awk -F'[";]' '/MARKETING_VERSION/ { print $$2; exit }' $(PBXPROJ))
IMAGE = build/$(PROJECT)-$(VERSION).dmg

.DEFAULT_GOAL := help

.PHONY: help # See https://tinyurl.com/makefile-autohelp
help: ## Print help for each target
	@awk -v tab=14 'BEGIN{FS="(:.*## |##@ |@## )";c="\033[36m";m="\033[0m";y="  ";a=2;h()}function t(s){gsub(/[ \t]+$$/,"",s);gsub(/^[ \t]+/,"",s);return s}function u(g,d){split(t(g),f," ");for(j in f)printf"%s%s%-"tab"s%s%s\n",y,c,t(f[j]),m,d}function h(){printf"\nUsage:\n%smake %s<target>%s\n\nRecognized targets:\n",y,c,m}/\\$$/{gsub(/\\$$/,"");b=b$$0;next}b{$$0=b$$0;b=""}/^[-a-zA-Z0-9*\/%_. ]+:.*## /{p=sprintf("\n%"(tab+a)"s"y,"");gsub(/\\n/,p);if($$1~/%/&&$$2~/^%:/){n=split($$2,q,/%:|:% */);for(i=2;i<n;i+=2){g=$$1;sub(/%/,q[i],g);u(g,q[i+1])}}else if($$1~/%/&&$$2~/%:[^%]+:[^%]+:%/){d=$$2;sub(/^.*%:/,"",d);sub(/:%.*/,"",d);n=split(d,q,/:/);for(i=1;i<=n;i++){g=$$1;d=$$2;sub(/%/,q[i],g);sub(/%:[^%]+:%/,q[i],d);u(g,d)}}else u($$1,$$2)}/^##@ /{gsub(/\\n/,"\n");if(NF==3)tab=$$2;printf"\n%s\n",$$NF}END{print""}' $(MAKEFILE_LIST) # v1.62

.PHONY: build
build: ## Make the archive file
	make $(ARCHIVE)

$(ARCHIVE): $(PBXPROJ)
	xcodebuild -workspace $(PROJECT).xcodeproj/project.xcworkspace -scheme $(PROJECT) -configuration Release clean archive -archivePath $(ARCHIVE)

.PHONY: export
export: ## Make the app file
	make $(APP)

$(APP): $(ARCHIVE)
	xcodebuild -exportArchive -archivePath $(ARCHIVE) -exportOptionsPlist $(PROJECT)/exportOptions.plist -exportPath build
	touch $(APP)

.PHONY: image
image: ## Make the dmg image file
	make $(IMAGE)

$(IMAGE): $(APP)
	hdiutil create          \
		-volname $(PROJECT) \
		-srcfolder $(APP)   \
		-format UDZO        \
		-ov $(IMAGE)

all: image ## Make all of the above

##@ Publishing

.PHONY: publish
publish: ## Publish the main branch website on Github Pages
	cp README.md website
	build/make-appcast.sh > website/appcast.xml
	git subtree push --prefix website origin main:github-pages

.PHONY: publish-force
# git subtree split --prefix website -b github-pages # create a local github-pages branch containing the splitted output folder
# git push -f origin github-pages:github-pages       # force push the github-pages branch to origin
publish-force: ## Publish the main branch website on Github Pages (force push)
	git checkout main && \
		git push --force origin `git subtree split --prefix website main`:github-pages

