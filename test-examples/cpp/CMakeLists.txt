cmake_minimum_required(VERSION 3.23)
project(pizza CXX)
 
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
 
find_package(kth REQUIRED)
 
add_executable(${PROJECT_NAME} pizza.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE kth::kth)
