#!/bin/bash

set -exo pipefail

mkdir -p build
cd build

declare -a _CMAKE_EXTRA_CONFIG
if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
    _CMAKE_EXTRA_CONFIG+=(-DHAS_PRE_1970_EXITCODE=0)
    _CMAKE_EXTRA_CONFIG+=(-DHAS_PRE_1970_EXITCODE__TRYRUN_OUTPUT=)
    _CMAKE_EXTRA_CONFIG+=(-DHAS_POST_2038_EXITCODE=0)
    _CMAKE_EXTRA_CONFIG+=(-DHAS_POST_2038_EXITCODE__TRYRUN_OUTPUT=)
fi
if [[ ${HOST} =~ .*darwin.* ]]; then
    _CMAKE_EXTRA_CONFIG+=(-DCMAKE_AR=${AR})
    _CMAKE_EXTRA_CONFIG+=(-DCMAKE_RANLIB=${RANLIB})
    _CMAKE_EXTRA_CONFIG+=(-DCMAKE_LINKER=${LD})
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi
if [[ ${HOST} =~ .*linux.* ]]; then
    # I hate you so much CMake.
    LIBPTHREAD=$(find ${PREFIX} -name "libpthread.so")
    _CMAKE_EXTRA_CONFIG+=(-DPTHREAD_LIBRARY=${LIBPTHREAD})
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,$PREFIX/lib"
fi

cmake ${CMAKE_ARGS} \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_STANDARD=17 \
    -DBUILD_SHARED_LIBS=ON \
    -DORC_PREFER_STATIC_PROTOBUF=OFF \
    -DORC_PREFER_STATIC_SNAPPY=OFF \
    -DORC_PREFER_STATIC_LZ4=OFF \
    -DORC_PREFER_STATIC_ZSTD=OFF \
    -DORC_PREFER_STATIC_ZLIB=OFF \
    -DORC_PREFER_STATIC_GMOCK=OFF \
    -DBUILD_JAVA=False \
    -DLZ4_HOME=$PREFIX \
    -DZLIB_HOME=$PREFIX \
    -DZSTD_HOME=$PREFIX \
    -DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
    -DProtobuf_ROOT=$PREFIX \
    -DPROTOBUF_HOME=$PREFIX \
    -DPROTOBUF_EXECUTABLE=$BUILD_PREFIX/bin/protoc \
    -DSNAPPY_HOME=$PREFIX \
    -DBUILD_LIBHDFSPP=NO \
    -DBUILD_CPP_TESTS=OFF \
    -DINSTALL_VENDORED_LIBS=OFF \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_C_COMPILER=$(type -p ${CC})     \
    -DCMAKE_CXX_COMPILER=$(type -p ${CXX})  \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    "${_CMAKE_EXTRA_CONFIG[@]}" \
    -GNinja ..

ninja -v
ninja install
