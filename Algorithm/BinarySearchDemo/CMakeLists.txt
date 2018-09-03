cmake_minimum_required(VERSION 3.7)
project(BinarySearchDemo)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES main.cpp BST.h)
add_executable(BinarySearchDemo ${SOURCE_FILES})