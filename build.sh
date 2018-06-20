mkdir build
cd build

declare -a _CMAKE_EXTRA_CONFIG
if [[ ${HOST} =~ .*darwin.* ]]; then
    if [[ ${_XCODE_BUILD} == yes ]]; then
        _CMAKE_EXTRA_CONFIG+=(-G'Xcode')
        _CMAKE_EXTRA_CONFIG+=(-DCMAKE_OSX_ARCHITECTURES=x86_64)
        _CMAKE_EXTRA_CONFIG+=(-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT})
        _VERBOSE=""
    fi
    unset MACOSX_DEPLOYMENT_TARGET
    export MACOSX_DEPLOYMENT_TARGET
    _CMAKE_EXTRA_CONFIG+=(-DCMAKE_AR=${AR})
    _CMAKE_EXTRA_CONFIG+=(-DCMAKE_RANLIB=${RANLIB})
    _CMAKE_EXTRA_CONFIG+=(-DCMAKE_LINKER=${LD})
fi
if [[ ${HOST} =~ .*linux.* ]]; then
    CXXFLAGS="${CXXFLAGS//-std=c++17/-std=c++11}"
    # I hate you so much CMake.
    LIBPTHREAD=$(find ${PREFIX} -name "libpthread.so")
    _CMAKE_EXTRA_CONFIG+=(-DPTHREAD_LIBRARY=${LIBPTHREAD})
fi

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_JAVA=False \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib \
    -DCMAKE_C_COMPILER=$(type -p ${CC})     \
    -DCMAKE_CXX_COMPILER=$(type -p ${CXX})  \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    "${_CMAKE_EXTRA_CONFIG[@]}" \
    ..

make -j${CPU_COUNT}
make install

