#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Welcome to NUC (Unified Compilers for Neo Blockchain)"
    echo $0: usage: nuc [options] or nuc [path-to-file]
    echo "options:"
    echo "nuc dapp [ Example.cs | Example.py | ... ] -> creates a new dapp project on the given language"
    echo "nuc version  -> displays versions of available compilers"
    echo "nuc help     -> displays help"
    echo "path-to-file:"
    echo "file will be compiled to .nvm according to its extension (.dll, .py, ...)"
    exit 1
fi

if [ $# -eq 2 ]; then
    if [ "$1" == "dapp" ]; then
      echo "Welcome to NUC (Unified Compilers for Neo Blockchain)"
      echo "Creating smart contract project based on your file extension"
      # try to get file extension
      filename=$(basename -- "$2")
      extension="${filename##*.}"
      if [ "$extension" == "cs" ]; then
        echo "creating C# application"
        filename="${filename%.*}"
        dotnet new classlib -o $filename
        echo "Configuring C# devpack dependency..."
        (cd $filename && dotnet add reference ${filename}.csproj && \
           #sed -i -e "s,$filename.csproj,\\/opt\\/nuc\\/neon\\/lib-csharp-devpack-master\\/bin\\/Release\\/netcoreapp2.0\\/Neo.SmartContract.Framework.dll,g" ${filename}.csproj && \
           #sed -i -e "s,<ProjectReference,<Reference,g" ${filename}.csproj )
           sed -i -e "s,netstandard2.0,netcoreapp2.0,g" ${filename}.csproj && \
           sed -i -e "s,$filename.csproj,\\/opt\\/nuc\\/neon\\/lib-csharp-devpack-master\\/Neo.SmartContract.Framework.csproj,g" ${filename}.csproj)
        (cd $filename && dotnet restore)
        echo "Configuring Hello World example on $filename folder..."
        echo "
using Neo.SmartContract.Framework;
using Neo.SmartContract.Framework.Services.Neo;

namespace Neo.SmartContract
{
  public class ExampleDapp : Framework.SmartContract
  {
    public static void Main()
    {
      Storage.Put(\"Hello\", \"World\");
    }
  }
}
" > $filename/Class1.cs
        mv $filename/Class1.cs $filename/$filename.cs
        echo "Compiling example on $filename folder..."
        (cd $filename && dotnet build -c Release)
        #dotnet add reference /opt/nuc/neon/lib-csharp-devpack-master/Neo.SmartContract.Framework.csproj
        #sed -i -e 's,</Project>,<ItemGroup><ProjectReference Include="/opt/nuc/neon/lib-csharp-devpack/Neo.SmartContract.Framework\Neo.SmartContract.Framework.csproj" /> </ItemGroup></Project>=gnetstandard1.6;net40/netstandard2.0;netcoreapp2.0/g' /opt/nuc/neon/neo-devpack-dotnet/Neo.SmartContract.Framework/Neo.SmartContract.Framework.csproj
        exit 0
      fi
      echo "Unknown file extension $extension"
      exit 1
    else
      echo "unknown option: $1"
      exit 1
    fi
fi

if [ $# -eq 1 ]; then
    if [ "$1" == "version" ]; then
      echo "Welcome to NUC (Unified Compilers for Neo Blockchain)"
      echo "===================="
      echo ".NET compiler (neon)"
      echo "===================="
      dotnet /opt/nuc/neon/bin-neon-master/neon.dll --version
      exit 0
    fi

    if [ "$1" == "help" ]; then
      echo "Welcome to NUC (Unified Compilers for Neo Blockchain)"
      echo "This project is intended to provide many compilers for Neo blockchain, in a unified command-line"
      echo "Currently, this project supports csharp, python, java and go languages (TODO)"
      echo "Feel free to visit documentation on NeoResearch github page, or docs.neo.org"
      echo "Copyleft 2019 - NeoResearch Community"
      exit 0
    fi

    if [ "$1" == "dapp" ]; then
      echo "Welcome to NUC (Unified Compilers for Neo Blockchain)"
      echo "Expects contract name with extension (example: Dapp.cs or Dapp.py)"
      exit 1
    fi

    # try to get file extension
    echo "not ready for files yet..."
    exit 1
fi
