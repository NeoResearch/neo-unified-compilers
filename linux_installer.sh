#!/bin/bash

echo "*********************************************************************"
echo "Welcome to NUC linux installer (Unified Compilers for Neo Blockchain)"
echo "*********************************************************************"
echo "This script is currently focused on debian-based/ubuntu systems, so feel free to test if this works on other systems"

if [ "$EUID" -ne 0 ]
  then echo "This installer requires root access. Please run as root/sudo"
  exit
fi

git --version 2>&1 >/dev/null
GIT_IS_AVAILABLE=$?
if [ $GIT_IS_AVAILABLE -ne 0 ]
  then echo "This installer requires git. Aborting"
  exit
fi

if [ $GIT_IS_AVAILABLE -eq 0 ]
  then echo "git is installed: " `git --version`
fi

dotnet --version 2>&1 >/dev/null
DOTNET_IS_AVAILABLE=$?
if [ $DOTNET_IS_AVAILABLE -ne 0 ]
  then echo "This installer requires dotnet. Aborting"
  exit
fi

if [ $DOTNET_IS_AVAILABLE -eq 0 ]
  then echo "dotnet is installed: " `dotnet --version`
fi


echo "Compilers will be installed on /opt/nuc. Do you agree (type 'yes')?"
read answer

if [[ x$answer != xyes ]]
   then echo "Aborting installer"
   exit
fi

#echo "TODO: ask user about interest of installing support for every language"

echo "==================================="
echo "Installing Neo .NET compiler (neon)"
echo "==================================="
mkdir -p /opt/nuc/neon/
echo "------------------------------------------"
echo "Getting latest version of neon from github"
echo "------------------------------------------"
(cd /opt/nuc/neon && git clone https://github.com/neo-project/neo-compiler.git)
echo "--------------------"
echo "Building latest neon"
echo "--------------------"
(cd /opt/nuc/neon/neo-compiler && git checkout master && git checkout -- . && git pull)
(cd /opt/nuc/neon/neo-compiler/neon && dotnet restore && \
        dotnet build -c Release && dotnet publish -f netcoreapp2.0 -c Release && \
        mkdir -p /opt/nuc/neon/bin-neon-master && \
        mv /opt/nuc/neon/neo-compiler/neon/bin/Release/netcoreapp2.0/publish/* /opt/nuc/neon/bin-neon-master)
echo "-------------------------"
echo "Building neon version 2.x"
echo "-------------------------"
echo "TODO: download specific commits"

echo "-----------------------------------------"
echo "Getting latest csharp devpack from github"
echo "-----------------------------------------"
(cd /opt/nuc/neon && git clone https://github.com/neo-project/neo-devpack-dotnet.git)

#TODO: libraries should be put on user directory

echo "------------------------------"
echo "Building latest csharp devpack"
echo "------------------------------"
(cd /opt/nuc/neon/neo-devpack-dotnet && git checkout master && git checkout -- . && git pull)
echo "Will replace Framework support for netcoreapp2.0"
sed -i -e 's/netstandard1.6;net40/netstandard2.0;netcoreapp2.0/g' /opt/nuc/neon/neo-devpack-dotnet/Neo.SmartContract.Framework/Neo.SmartContract.Framework.csproj
#(cd /opt/nuc/neon/neo-devpack-dotnet/Neo.SmartContract.Framework && dotnet restore && \
#        dotnet build -c Release && dotnet publish -f netcoreapp2.0 -c Release && \
#        mkdir -p /opt/nuc/neon/lib-csharp-devpack-master && \
#        mv /opt/nuc/neon/neo-devpack-dotnet/Neo.SmartContract.Framework/bin/Release/netcoreapp2.0/publish/* /opt/nuc/neon/lib-csharp-devpack-master)
(cd /opt/nuc/neon/neo-devpack-dotnet/Neo.SmartContract.Framework && dotnet restore && \
        dotnet build -c Release && dotnet publish -f netcoreapp2.0 -c Release && \
        dotnet build -c Release && dotnet publish -f netstandard2.0 -c Release && \
        mkdir -p /opt/nuc/neon/lib-csharp-devpack-master && \
        cp -r /opt/nuc/neon/neo-devpack-dotnet/Neo.SmartContract.Framework/* /opt/nuc/neon/lib-csharp-devpack-master)

#TODO: libraries should be put on user directory
# read permissions on smart contract C# framework
chmod 777 -R /opt/nuc/neon/lib-csharp-devpack-master


echo "=============================="
echo "Installing NUC to /opt/nuc/bin"
echo "=============================="

mkdir -p /opt/nuc/bin
cp nuc.sh /opt/nuc/bin/nuc
chmod +x /opt/nuc/bin/nuc

echo "=========================================="
echo "Please add NUC to path: /opt/nuc/bin      "
echo "edit: ~/.profile                          "
echo "add line: export PATH=\$PATH:/opt/nuc/bin "
echo "close editor and run: source ~/.profile   "
echo "=========================================="

echo "Finished!"
