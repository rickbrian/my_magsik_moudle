# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html.
# For more examples on how to use CMake, see https://github.com/android/ndk-samples.


cmake_minimum_required(VERSION 3.22.1)



project("my_module")


add_library(${CMAKE_PROJECT_NAME} SHARED

        zygisk_main.cpp
        zygisk.hpp
        remapper.cpp
        remapper.h
        log.h
)

include_directories(

)

target_link_libraries(${CMAKE_PROJECT_NAME}

        android
        log)