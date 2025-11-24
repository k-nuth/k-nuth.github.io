cmake_minimum_required(VERSION 3.23)
project(pizza C CXX)
 
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
 
find_package(kth REQUIRED)
 
add_executable(${PROJECT_NAME} pizza.c)
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)
target_link_libraries(${PROJECT_NAME} PRIVATE kth::c-api)
