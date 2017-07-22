if(CMAKE_COMPILER_IS_GNUCXX OR "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--no-undefined")

    # Enable warnings
    add_compile_options(-Wall -Wextra -pedantic)

    #add_compile_options(-Werror)

    # Except for "/*" within comment errors (present in doxygen blocks)
    add_compile_options(-Wno-error=comment)

    if(ANDROID)
        add_compile_options(-fno-exceptions -fno-rtti)

        # -Wunknown-attributes - malloc.h
        # -Wzero-length-array - asm-generic/siginfo.h
        add_compile_options(-Wno-unknown-attributes -Wno-zero-length-array)

        # Prevent libarchive's android_lf.h from being included. It #defines
        # a bunch of things like `#define open open64`, which breaks the build
        # process. The header is only needed for building libarchive anyway.
        add_definitions(-DARCHIVE_ANDROID_LF_H_INCLUDED)

        # Enable link time optimization
        add_compile_options(-flto)
        foreach(lang C CXX ASM)
            string(REPLACE "-Wa,--noexecstack" ""
                   CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS}")

            # ld.gold does not support -Os
            if(ANDROID_ABI MATCHES "^armeabi")
                string(REPLACE "-Os" "-O2"
                       CMAKE_${lang}_FLAGS_RELEASE
                       "${CMAKE_${lang}_FLAGS_RELEASE}")
            endif()
        endforeach()
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -flto -fuse-ld=gold")
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -flto -fuse-ld=gold")
    endif()

    if(NOT WIN32)
        # Visibility
        add_compile_options(-fvisibility=hidden)

        # Use DT_RPATH instead of DT_RUNPATH because the latter is not transitive
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--disable-new-dtags")

        # Does not work on Windows:
        # https://sourceware.org/bugzilla/show_bug.cgi?id=11539
        add_compile_options(-ffunction-sections -fdata-sections)
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--gc-sections")
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--gc-sections")
    endif()
endif()

# Remove some warnings caused by the BoringSSL headers on Android
if(ANDROID AND "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    add_compile_options(-Wno-gnu-anonymous-struct -Wno-nested-anon-types)
endif()
