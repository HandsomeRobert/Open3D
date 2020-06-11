if (FILAMENT_PRECOMPILED_ROOT)
    if (EXISTS "${FILAMENT_PRECOMPILED_ROOT}")
        set(FILAMENT_ROOT "${FILAMENT_PRECOMPILED_ROOT}")
    else()
        message(FATAL_ERROR "Filament binaries not found in ${FILAMENT_PRECOMPILED_ROOT}")
    endif()
else()
    set(FILAMENT_ROOT ${CMAKE_BINARY_DIR}/downloads/filament)

    if (USE_VULKAN AND (ANDROID OR WIN32 OR WEBGL OR IOS))
        MESSAGE(FATAL_ERROR "Downloadable version of Filament supports vulkan only on Linux and Apple")
    endif()

    set(DOWNLOAD_PATH ${CMAKE_BINARY_DIR}/downloads)
    set(TAR_PWD ${DOWNLOAD_PATH})

    if (NOT EXISTS ${FILAMENT_ROOT}/README.md)

        if (NOT EXISTS ${ARCHIVE_FILE})
            set(ARCHIVE_FILE ${CMAKE_BINARY_DIR}/downloads/filament.tgz)

            # Setup download links =============================================
            set(DOWNLOAD_URL_PRIMARY "https://storage.googleapis.com/isl-datasets/open3d-dev/filament-20200220-linux.tgz")
            set(DOWNLOAD_URL_FALLBACK "https://github.com/google/filament/releases/download/v1.4.5/filament-20200127-linux.tgz")

            if (WIN32 OR EMSCRIPTEN_WIN32)
                set(DOWNLOAD_URL_PRIMARY "https://storage.googleapis.com/isl-datasets/open3d-dev/filament-20200127-windows.tgz")
                set(DOWNLOAD_URL_FALLBACK "https://github.com/google/filament/releases/download/v1.4.5/filament-20200127-windows.tgz")
                
                file(MAKE_DIRECTORY ${FILAMENT_ROOT})
                set(TAR_PWD ${FILAMENT_ROOT})
            elseif (APPLE OR EMSCRIPTEN_APPLE)
                set(DOWNLOAD_URL_PRIMARY "https://storage.googleapis.com/isl-datasets/open3d-dev/filament-20200127-mac-10.14-resizefix2.tgz")
                set(DOWNLOAD_URL_FALLBACK "https://github.com/google/filament/releases/download/v1.4.5/filament-20200127-mac.tgz")
            endif()
            # ==================================================================

            file(DOWNLOAD ${DOWNLOAD_URL_PRIMARY} ${ARCHIVE_FILE} SHOW_PROGRESS STATUS DOWNLOAD_RESULT)
            if (NOT DOWNLOAD_RESULT EQUAL 0)
                file(DOWNLOAD ${DOWNLOAD_URL_FALLBACK} ${ARCHIVE_FILE} SHOW_PROGRESS STATUS DOWNLOAD_RESULT)
            endif()
        endif()

        execute_process(COMMAND ${CMAKE_COMMAND} -E tar -xf ${ARCHIVE_FILE} WORKING_DIRECTORY ${TAR_PWD})
    endif()

    if (EMSCRIPTEN)
        set(ARCHIVE_FILE ${CMAKE_BINARY_DIR}/downloads/filament-wasm.tgz)
        if (NOT EXISTS ${FILAMENT_ROOT/lib/wasm})
            if (NOT EXISTS ${ARCHIVE_FILE})
                set(ARCHIVE_FILE ${CMAKE_BINARY_DIR}/downloads/filament-wasm.tgz)
                # ==============================================================
                set(DOWNLOAD_URL_PRIMARY "http://localhost:8080/filament-wasm.tgz")
                set(DOWNLOAD_URL_FALLBACK "http://localhost:8000/filament-wasm.tgz")
                # ==============================================================
                file(DOWNLOAD ${DOWNLOAD_URL_PRIMARY} ${ARCHIVE_FILE} SHOW_PROGRESS STATUS DOWNLOAD_RESULT)
                if (NOT DOWNLOAD_RESULT EQUAL 0)
                   file(DOWNLOAD ${DOWNLOAD_URL_FALLBACK} ${ARCHIVE_FILE} SHOW_PROGRESS STATUS DOWNLOAD_RESULT)
                endif()
                if (NOT DOWNLOAD_RESULT EQUAL 0)
                    message("[ERROR] Could not download the Filament libraries for WebAssembly from:")
                    message("[ERROR]   ${DOWNLOAD_URL_PRIMARY}")
                    message("[ERROR]   ${DOWNLOAD_URL_SECONDARY}")
                    message("[ERROR] You will need to compile Filament yourself:")
                    message("[ERROR]   <enable Emscripten>")
                    message("[ERROR]   git clone https://github.com/google/filament.git")
                    message("[ERROR]   cd filament")
                    message("[ERROR]   git checkout v1.4.5")
                    message("[ERROR]   edit web/filament-js/CMakeLists.txt:25 to be 'MODULARIZE=1' instead of 'MODULARIZE_INSTANCE=1'")
                    message("[ERROR]   ./build.sh -p webgl release")
                    message("[ERROR]   cd out")
                    message("[ERROR]   mkdir -p filament/lib/wasm")
                    message("[ERROR]   find cmake-webgl-release -name \\*.a -exec cp \\{\\} filament/lib/wasm \\;")
                    message("[ERROR]   tar -czf filament-wasm.tgz filament/")
                    message("[ERROR]   cp filament-wasm.tgz some/permanent/path")
                    message("[ERROR]   (cd some/permanent/path; python -m SimpleHTTPServer)")
                    message("[ERROR] Now rerun CMake.")
                    message(FATAL_ERROR "")
                endif()
            endif()
        execute_process(COMMAND ${CMAKE_COMMAND} -E tar -xf ${ARCHIVE_FILE} WORKING_DIRECTORY ${TAR_PWD})
       endif()
    endif()
endif()

message(STATUS "Filament is located at ${FILAMENT_ROOT}")

if(NOT EMSCRIPTEN)
    set(filament_LIBRARIES filameshio filament filamat_lite filaflat filabridge geometry backend bluegl ibl image meshoptimizer smol-v utils)
else()
    set(filament_LIBRARIES filameshio filament filaflat filabridge geometry backend ibl image meshoptimizer camutils smol-v utils)
endif()
if (UNIX AND NOT EMSCRIPTEN)
    set(filament_LIBRARIES ${filament_LIBRARIES} bluevk)
endif()
