cmake_minimum_required(VERSION 3.23)
project(knuth_c_example C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Find Knuth package
find_package(kth REQUIRED)

# C API example
add_executable(example example.c)

# Set linker language to CXX because Knuth libraries are C++
set_target_properties(example PROPERTIES LINKER_LANGUAGE CXX)

# Link against Knuth C API
target_link_libraries(example PRIVATE kth::c-api)
