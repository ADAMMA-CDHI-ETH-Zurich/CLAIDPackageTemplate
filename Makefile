.PHONY: all check_claid_sdk android_package

all: check_claid_sdk

MAKEFILE_PATH := $(realpath $(firstword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(dir $(MAKEFILE_PATH))
DATATYPES_DIR := $(MAKEFILE_DIR)datatypes

PROTO_FILES := $(wildcard $(DATATYPES_DIR)*.proto)
HAS_DATATYPES := $(shell find $(DATATYPES_DIR) -type f -name *.proto | wc -l)

ANDROID_DIR := $(MAKEFILE_DIR)packaging/android/claid_package/${package_name}
AAR_DIR := $(ANDROID_DIR)/build/outputs/aar

ANDROID_CPP_PROTO_DIR := $(ANDROID_DIR)/src/main/cpp/generated_datatypes

FLUTTER_DIR := $(MAKEFILE_DIR)packaging/flutter/claid_package
FLUTTER_CPP_PROTO_DIR := $(FLUTTER_DIR)/android/src/main/generated_datatypes/cpp
FLUTTER_DART_PROTO_DIR := $(FLUTTER_DIR)/lib/datatypes

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
		@echo "Building Android package..."; \
	else \
		@echo "Cannot build Android package without CLAID SDK"; \
		false; \
	fi

	@echo "Project path is $(MAKEFILE_DIR)"


	@if [ $(HAS_DATATYPES) -gt 0 ]; then \
		@echo "Generating protobuf files";\
		rm -fr $(ANDROID_CPP_PROTO_DIR); \
		mkdir -p $(ANDROID_CPP_PROTO_DIR); \
		protoc --cpp_out=$(ANDROID_CPP_PROTO_DIR) --proto_path=$(DATATYPES_DIR) $(DATATYPES_DIR)/*.proto; \
	else \
		echo "Info: No datatypes found to process."; \
	fi

	 

	rm -fr $(ANDROID_DIR)/libs/claid*.aar
	mkdir -p $(ANDROID_DIR)/libs/
	cp $(CLAID_SDK_HOME)/bin/android/claid-debug.aar $(ANDROID_DIR)/libs/
	cd $(ANDROID_DIR)/.. && ./gradlew build && cd $(MAKEFILE_DIR) && rm -fr build/android/ && mkdir -p build/android && cp $(AAR_DIR)/*.aar build/android/	

.PHONY: generate_dart_proto
generate_dart_proto:
	@if [ $(HAS_DATATYPES) -gt 0 ]; then \
		echo "Generating dart protobuf files";\
		rm -fr $(FLUTTER_DIR)/lib/generated\
		mkdir -p $(FLUTTER_DIR)/lib/generated\
		protoc -I$(DATATYPES_DIR)/ --dart_out=$(FLUTTER_DIR)/lib/generated \
			$(DATATYPES_DIR)/*.proto\
	else \
		@echo "Info: No datatypes found to process."; \
	fi

	

	
flutter_package: check_claid_sdk
	@if [ -n "$(CLAID_SDK_HOME)" ]; then \
		echo "Building Flutter package..."; \
	else \
		echo "Cannot build Flutter package without CLAID SDK"; \
		false; \
	fi

	@echo "Project path is $(MAKEFILE_DIR)"

	@if [ $(HAS_DATATYPES) -gt 0 ]; then \
		echo "Generating protobuf files";\
		rm -fr $(FLUTTER_CPP_PROTO_DIR); \
		rm -fr $(FLUTTER_DART_PROTO_DIR); \
		mkdir -p $(FLUTTER_CPP_PROTO_DIR); \
		mkdir -p $(FLUTTER_DART_PROTO_DIR); \
		protoc --cpp_out=$(FLUTTER_CPP_PROTO_DIR) --proto_path=$(DATATYPES_DIR) $(DATATYPES_DIR)/*.proto; \
		protoc -I$(DATATYPES_DIR)/ --dart_out=$(FLUTTER_DART_PROTO_DIR)\
			$(DATATYPES_DIR)/*.proto;\
	else \
		@echo "Info: No datatypes found to process."; \
	fi

	@echo "Building flutter package";
	rm -fr build/flutter
	mkdir -p build/flutter
	cp -L -r $(FLUTTER_DIR) $(MAKEFILE_DIR)build/flutter/claid_package
	@echo "Built flutter package";
	
