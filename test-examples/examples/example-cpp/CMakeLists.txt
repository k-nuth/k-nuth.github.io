cmake_minimum_required(VERSION 3.23)
project(knuth_cpp_example CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find Knuth package
find_package(kth REQUIRED)

# C++ API example
add_executable(example-cpp example-cpp.cpp)

# Link against Knuth node library
target_link_libraries(example-cpp PRIVATE kth::node)
