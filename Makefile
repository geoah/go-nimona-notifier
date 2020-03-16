VERSION = $(shell yq r pubspec.yaml 'version')

CERT_NAME := Developer ID Application: George Antoniadis (LNCQ7FYZE7)
APPLE_USERNAME := george@noodles.gr
APPLE_PASSWORD := @keychain:AC_PASSWORD

.PHONY: build
build:
	@rm -f osx/notifier.app.zip
	@rm -f bindata.go
	@codesign \
		-s "$(CERT_NAME)" \
		-fv \
		--entitlements entitlements.xml \
		--deep \
		--options runtime \
		--timestamp \
		osx/notifier.app
	@ditto \
		-c \
		-k \
		--rsrc \
		--keepParent \
		osx/notifier.app \
		osx/notifier.app.zip
	@xcrun altool \
		--notarize-app \
		--primary-bundle-id "io.nimona.notifier" \
		--username "$(APPLE_USERNAME)" \
		--password "$(APPLE_PASSWORD)" \
		--file osx/notifier.app.zip
	@go-bindata -pkg notifier osx

.PHONE: build-verify
build-verify:
	@xcrun altool \
		--username "$(APPLE_USERNAME)" \
		--password "$(APPLE_PASSWORD)" \
		--notarization-info $(REQ_ID)