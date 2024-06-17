.PHONY: all check_claid_sdk android_package

all: check_claid_sdk

MAKEFILE_PATH := $(realpath $(firstword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(dir $(MAKEFILE_PATH))
DATATYPES_DIR := $(MAKEFILE_DIR)datatypes


PROTO_FILES := $(wildcard $(DATATYPES_DIR)*.proto)
HAS_DATATYPES := $(shell find $(DATATYPES_DIR) -type f -name *.proto | wc -l)
ANDROID_CPP_PROTO_DIR := $(MAKEFILE_DIR)src/android/claid_package/${package_name}/src/main/cpp/generated_datatypes

ANDROID_DIR := $(MAKEFILE_DIR)src/android/claid_package
AAR_DIR := $(ANDROID_DIR)/${package_name}/build/outputs/aar

FLUTTER_DIR := $(MAKEFILE_DIR)src/flutter/claid_package

check_claid_sdk:
ifdef CLAID_SDK_HOME
	@echo "CLAD SDK found under $(CLAID_SDK_HOME)"
	@true
else
	@echo "Error! CLAID_SDK_HOME is not set! Cannot find CLAID SDK"
	@false
endif

android_package: check_claid_sdk
	@if [ -n "$(CLAID_SDK_HOME)" ]; then \
		echo "Building Android package..."; \
	else \
		echo "Cannot build Android package without CLAID SDK"; \
		false; \
	fi

	echo "Project path is $(MAKEFILE_DIR)"


	@if [ $(HAS_DATATYPES) -gt 0 ]; then \
		echo "Generating protobuf files";\
		rm -fr $(ANDROID_CPP_PROTO_DIR); \
		mkdir -p $(ANDROID_CPP_PROTO_DIR); \
		protoc --cpp_out=$(ANDROID_CPP_PROTO_DIR) --proto_path=$(DATATYPES_DIR) $(DATATYPES_DIR)/*.proto; \
	else \
		echo "Info: No datatypes found to process."; \
	fi

	 

	rm -fr $(MAKEFILE_DIR)src/android/claid_package/${package_name}/libs/claid*.aar
	mkdir -p $(MAKEFILE_DIR)src/android/claid_package/${package_name}/libs/
	cp $(CLAID_SDK_HOME)/bin/android/claid-debug.aar $(MAKEFILE_DIR)src/android/claid_package/${package_name}/libs/
	cd $(MAKEFILE_DIR)src/android/claid_package && ./gradlew build

.PHONY: generate_dart_proto
generate_dart_proto:
	@if [ $(HAS_DATATYPES) -gt 0 ]; then \
		echo "Generating dart protobuf files";\
		rm -fr $(FLUTTER_DIR)/lib/generated\
		mkdir -p $(FLUTTER_DIR)/lib/generated\
		protoc -I$(DATATYPES_DIR)/ --dart_out=$(FLUTTER_DIR)/lib/generated \
			$(DATATYPES_DIR)/*.proto\
	else \
		echo "Info: No datatypes found to process."; \
	fi

	

	
flutter_package: check_claid_sdk generate_dart_proto android_package
	echo "Building flutter package"
	cp $(AAR_DIR)/${package_name}-debug.aar $(FLUTTER_DIR)/android/libs/
