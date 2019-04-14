#!/bin/bash

echo "*********************************************************************"
echo "Welcome to NUC linux installer (Unified Compilers for Neo Blockchain)"
echo "*********************************************************************"
echo "This script is currently focused on debian-based/ubuntu systems, so feel free to test if this works on other systems"
echo "It is recommended to install this locally on user home (non root/sudo)"

# when root access is granted, global install
NUC_PATH=/opt/nuc

if [ "$EUID" -ne 0 ]; then
  #echo "This installer requires root access. Please run as root/sudo"
  #exit
  NUC_PATH=$HOME/.nuc
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


echo "Compilers will be installed on $NUC_PATH. Do you agree (type 'yes')?"
read answer

if [[ x$answer != xyes ]]
   then echo "Aborting installer"
   exit
fi

#echo "TODO: ask user about interest of installing support for every language"

echo "==================================="
echo "Installing Neo .NET compiler (neon)"
echo "==================================="
mkdir -p $NUC_PATH/neon/
echo "------------------------------------------"
echo "Getting latest version of neon from github"
echo "------------------------------------------"
(cd $NUC_PATH/neon && git clone https://github.com/neo-project/neo-compiler.git)
echo "--------------------"
echo "Building latest neon"
echo "--------------------"
(cd $NUC_PATH/neon/neo-compiler && git checkout master && git checkout -- . && git pull)
(cd $NUC_PATH/neon/neo-compiler/neon && dotnet restore && \
        dotnet build -c Release && dotnet publish -f netcoreapp2.0 -c Release && \
        mkdir -p $NUC_PATH/neon/bin-neon-master && \
        mv $NUC_PATH/neon/neo-compiler/neon/bin/Release/netcoreapp2.0/publish/* $NUC_PATH/neon/bin-neon-master)
echo "-------------------------"
echo "Building neon version 2.x"
echo "-------------------------"
echo "TODO: download specific commits"

echo "-----------------------------------------"
echo "Getting latest csharp devpack from github"
echo "-----------------------------------------"
(cd $NUC_PATH/neon && git clone https://github.com/neo-project/neo-devpack-dotnet.git)

#TODO: libraries should be put on user directory

echo "------------------------------"
echo "Building latest csharp devpack"
echo "------------------------------"
(cd $NUC_PATH/neon/neo-devpack-dotnet && git checkout master && git checkout -- . && git pull)
echo "Will replace Framework support for netcoreapp2.0"
sed -i -e 's/netstandard1.6;net40/netstandard2.0;netcoreapp2.0/g' $NUC_PATH/neon/neo-devpack-dotnet/Neo.SmartContract.Framework/Neo.SmartContract.Framework.csproj
#(cd $NUC_PATH/neon/neo-devpack-dotnet/Neo.SmartContract.Framework && dotnet restore && \
#        dotnet build -c Release && dotnet publish -f netcoreapp2.0 -c Release && \
#        mkdir -p $NUC_PATH/neon/lib-csharp-devpack-master && \
#        mv $NUC_PATH/neon/neo-devpack-dotnet/Neo.SmartContract.Framework/bin/Release/netcoreapp2.0/publish/* $NUC_PATH/neon/lib-csharp-devpack-master)
(cd $NUC_PATH/neon/neo-devpack-dotnet/Neo.SmartContract.Framework && dotnet restore && \
        dotnet build -c Release && dotnet publish -f netcoreapp2.0 -c Release && \
        dotnet build -c Release && dotnet publish -f netstandard2.0 -c Release && \
        mkdir -p $NUC_PATH/neon/lib-csharp-devpack-master && \
        cp -r $NUC_PATH/neon/neo-devpack-dotnet/Neo.SmartContract.Framework/* $NUC_PATH/neon/lib-csharp-devpack-master)

#TODO: libraries should be put on user directory
# read permissions on smart contract C# framework
#chmod $USER:$USER -R $NUC_PATH/neon/lib-csharp-devpack-master
#chmod 777 -R $NUC_PATH/neon/lib-csharp-devpack-master


echo "==============================="
echo "Installing NUC to $NUC_PATH/bin"
echo "==============================="

mkdir -p $NUC_PATH/bin
cp nuc.sh _nuc
sed -i -e "s,\\/opt\\/nuc,$NUC_PATH,g" _nuc
mv _nuc $NUC_PATH/bin/nuc
chmod +x $NUC_PATH/bin/nuc

echo "=========================================="
echo "Please add NUC to path: $NUC_PATH/bin      "
echo "edit: ~/.profile                          "
echo "add line: export PATH=\$PATH:$NUC_PATH/bin "
echo "close editor and run: source ~/.profile   "
echo "=========================================="

echo "Finished!"
