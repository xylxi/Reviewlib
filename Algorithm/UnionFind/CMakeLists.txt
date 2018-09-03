cmake_minimum_required(VERSION 3.7)
project(UnionFind)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES main.cpp UnionF1.h UnionF2.h UnionF3.h UnionF4.h)
add_executable(UnionFind ${SOURCE_FILES})