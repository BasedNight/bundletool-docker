# Notes on the following Docker command:
# -u "$$(id -u)":"$$(id -g)": run Docker as the current user to avoid permission problems when bind mounting working directory
# --env-file .env: load environment variables (keystore pass, key alias, etc.) into container
# -v "$(CURDIR)":/work -w /work: bind current directory to /work in container and set it as the working directory
# -lc …: run bundletool command within container so that environment variables loaded from .env are properly expanded
# $ is reserved in Make syntax, so use double $ to escape it, i.e. $$ = $ after make processing

%.apks: %.aab .env keystore.bak.jks
	docker run --rm \
    -u "$$(id -u)":"$$(id -g)" \
	--env-file .env \
	-v "$(CURDIR)":/work -w /work \
    --entrypoint /bin/sh \
    bundletool:1.18.2 \
	-lc 'bundletool build-apks \
	--bundle=$< \
	--output=$@ \
	--ks=keystore.bak.jks \
	--ks-key-alias="$$KEYSTORE_KEY_ALIAS" \
	--ks-pass=pass:"$$KEYSTORE_PASS" \
	--key-pass=pass:"$$KEY_PASS" \
	--mode=universal'

%.zip: %.apks
	cp $< $@

%.apk: %.zip
	unzip $<
	mv universal.apk $@

clean:
	rm toc.pb
