#!/bin/bash
echo -e "Installing kcov"
curl -L "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/shunit2/shunit2-2.1.6.tgz" | tar zx
wget https://github.com/SimonKagstrom/kcov/archive/master.tar.gz
tar xzf master.tar.gz
cd kcov-master || exit
mkdir build
cd build || exit
cmake ..
make
sudo make install
cd ../..
rm -rf kcov-master
mkdir -p coverage
