SHELL=/bin/bash
include default.profile
-include custom.profile

define replace-profile =
sed \
-e "s#\$$PORT#$(PORT)#g" \
-e "s#\$$FQDN#$(FQDN)#g" \
-e "s#\$$DOCUMENT_ROOT#$(DOCUMENT_ROOT)#g" \
-e "s#\$$UNRESTRICTED_IP#$(UNRESTRICTED_IP)#g" \
-e "s#\$$PASSWD_FILE#$(PASSWD_FILE)#g" \
-e "s#\$$ALBUM_DIR#$(ALBUM_DIR)#g" \
-e "s#\$$RESIZED_DIR#$(RESIZED_DIR)#g" \
-e "s#\$$RESOURCES_DIR#$(RESOURCES_DIR)#g" \
-e "s#\$$CACHE_PATH#$(CACHE_PATH)#g" \
-e "s#\$$TMP_PATH#$(TMP_PATH)#g" \
-e "s#\$$INDEX_BACKEND#$(INDEX_BACKEND)#g" \
-e "s#\$$RESIZED_BACKEND#$(RESIZED_BACKEND)#g" \
-e "s#\$$XSLT_FILE#$(XSLT_FILE)#g" \
-e "s#\$$SIZE_THUMB#$(SIZE_THUMB)#g" \
-e "s#\$$SIZE_FULL#$(SIZE_FULL)#g" \
< $< > $@
endef

all: build/config/album.conf build/config/album_index.xslt build/config/.htpasswd build/config/album_plugins.conf build/resources/css build/resources/js build/resources/galleria build/bin/force-update-cache.sh build/bin/synchronize.sh build/bin/update-cache.sh
.PHONY: all

clean:
	rm -rf build
.PHONY: clean

build/config:
	[[ -d $@ ]] || mkdir -p $@

build/resources:
	[[ -d $@ ]] || mkdir -p $@

build/bin:
	[[ -d $@ ]] || mkdir -p $@

default.profile:
	true

custom.profile:
	[[ -f $@ ]] || touch $@

build/config/album.conf: config/album.conf build/config default.profile custom.profile
	$(replace-profile)

build/config/%: config/% build/config
	cp $< $@

build/config/plugins.conf: build/config
	rm -f $@
	touch $@
	for dir in $(PLUGINS); do \
	  if [ -d plugins/$$dir/config/ ]; then \
	    cat plugins/$$dir/config/* >> $@; \
	  fi \
	done

build/config/album_plugins.conf: build/config/plugins.conf
	$(replace-profile)

config/.htpasswd:
	touch $@

build/resources/%: resources/% build/resources
	cp -r $< $@
	for dir in $(PLUGINS); do \
	  if [ -d plugins/$$dir/$< ]; then \
	    file=$$(ls -1 $@/album.* | tail -1); \
	    cat plugins/$$dir/$</* >> $$file; \
	  fi \
	done

build/bin/album.profile: default.profile custom.profile
	cat default.profile custom.profile > $@

build/bin/%: bin/% build/bin build/bin/album.profile
	cp $< $@
	chmod +x $@

install_srv: all
	su -c "\
	cp build/config/album.conf /etc/nginx/$(FQDN);\
	cp build/config/album_plugins.conf /etc/nginx/$(FQDN)_plugins.conf;\
	cp build/config/album_index.xslt $(XSLT_FILE);\
	cp build/config/.htpasswd $(PASSWD_FILE);\
	chmod 740 $(PASSWD_FILE);\
	chown :$(SRV_GROUP) $(PASSWD_FILE);\
	/etc/init.d/nginx reload"
.PHONY: install_srv

install_app: all	
	mkdir -p $(DOCUMENT_ROOT)
	mkdir -p $(DOCUMENT_ROOT)$(ALBUM_DIR)
	mkdir -p $(DOCUMENT_ROOT)$(RESOURCES_DIR)
	cp -r build/resources/* $(DOCUMENT_ROOT)$(RESOURCES_DIR)
	mkdir -p $(DOCUMENT_ROOT)$(RESIZED_DIR)
	chmod 2775 $(DOCUMENT_ROOT)$(RESIZED_DIR)
	chown :$(SRV_GROUP) $(DOCUMENT_ROOT)$(RESIZED_DIR)
	mkdir -p $(CACHE_PATH)
	mkdir -p $(BIN_PATH)
	cp build/bin/* $(BIN_PATH)
.PHONY: install_app

install: install_app install_srv
.PHONY: install
