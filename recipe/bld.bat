@echo ON

md build
pushd build

cmake %CMAKE_ARGS% ^
    -DCMAKE_POLICY_DEFAULT_CMP0074=NEW ^
    -DCMAKE_PREFIX_PATH=%PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=ON ^
    -DBUILD_TOOLS=OFF ^
    -DORC_PREFER_STATIC_PROTOBUF=OFF ^
    -DORC_PREFER_STATIC_SNAPPY=OFF ^
    -DORC_PREFER_STATIC_LZ4=OFF ^
    -DORC_PREFER_STATIC_ZSTD=OFF ^
    -DORC_PREFER_STATIC_ZLIB=OFF ^
    -DORC_PREFER_STATIC_GMOCK=OFF ^
    -DBUILD_JAVA=False ^
    -DLZ4_HOME=%PREFIX%\Library ^
    -DZLIB_HOME=%PREFIX%\Library ^
    -DZSTD_HOME=%PREFIX%\Library ^
    -DSNAPPY_HOME=%PREFIX%\Library ^
    -DBUILD_LIBHDFSPP=NO ^
    -DBUILD_CPP_TESTS=OFF ^
    -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
    -GNinja ..

if errorlevel 1 exit /b 1
ninja -v
if errorlevel 1 exit /b 1
ninja install
if errorlevel 1 exit /b 1
