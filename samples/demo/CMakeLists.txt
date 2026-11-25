cmake_minimum_required(VERSION 3.12)
project(pdfsolid_demo VERSION 1.3.0 LANGUAGES C CXX OBJC OBJCXX)

set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0" CACHE STRING "Minimum macOS version")
set(PDFSOLID_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../lib" CACHE PATH
    "Directory containing PDFSolid.framework and SDK dylibs")

find_library(PDFSOLID_FRAMEWORK PDFSolid PATHS "${PDFSOLID_LIB_DIR}" NO_DEFAULT_PATH)
if(NOT PDFSOLID_FRAMEWORK)
    message(FATAL_ERROR "PDFSolid.framework not found in ${PDFSOLID_LIB_DIR}")
endif()

add_executable(pdfsolid_demo Objective-C/tutorial/main.mm)
target_compile_features(pdfsolid_demo PRIVATE cxx_std_17)
target_compile_options(pdfsolid_demo PRIVATE -fobjc-arc)
target_link_libraries(pdfsolid_demo PRIVATE
    "${PDFSOLID_FRAMEWORK}"
    "-framework Foundation"
    "-framework AppKit"
)
set_target_properties(pdfsolid_demo PROPERTIES
    BUILD_RPATH "${PDFSOLID_LIB_DIR}"
)
