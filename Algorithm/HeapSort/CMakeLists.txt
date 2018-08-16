cmake_minimum_required(VERSION 3.7)
project(HeapSort)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES main.cpp HeapDemo.h)
add_executable(HeapSort ${SOURCE_FILES})