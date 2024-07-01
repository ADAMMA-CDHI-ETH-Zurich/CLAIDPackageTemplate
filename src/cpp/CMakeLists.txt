cmake_minimum_required(VERSION 3.10)
project(${package_name})

if(NOT DEFINED ENV{CLAID_SDK_HOME})
    message(FATAL_ERROR "CLAID SDK not found! Make sure to install CLAID SDK and set CLAID_SDK_HOME environment variable.")
endif()

# Collect all .proto files
file(GLOB_RECURSE PROTO_SRC_FILES ${CMAKE_CURRENT_LIST_DIR}/generated_datatypes/*.pb.cc)
file(GLOB_RECURSE PROTO_HDR_FILES ${CMAKE_CURRENT_LIST_DIR}/generated_datatypes/*.pb.hh)

# Include the generated files
include_directories(${PROTO_HDR_FILES})

add_library( CLAID SHARED IMPORTED )
# You can define two import-locations: one for debug and one for release.
set_target_properties( CLAID PROPERTIES IMPORTED_LOCATION $ENV{CLAID_SDK_HOME}/bin/android/native/${ANDROID_ABI}/libclaid_capi_android.so )

# Add executable and link libraries
add_library(${package_name} 
    SHARED
    main.cpp 
${PROTO_SRCS})



if(ANDROID)
        find_library( # Sets the name of the path variable.
                log-lib

                # Specifies the name of the NDK library that
                # you want CMake to locate.
                log)

        find_library( # Sets the name of the path variable.
                android-lib

                # Specifies the name of the NDK library that
                # you want CMake to locate.
                android )

        target_link_libraries( # Specifies the target library.
                ${package_name}
                # Links the target library to the log library
                # included in the NDK.

                ${log-lib}
                ${android-lib}
                ${CLAID})
endif()