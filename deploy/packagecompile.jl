using Pkg
Pkg.instantiate()

using PackageCompiler

create_sysimage(:MusicAlbums;
    sysimage_path="MusicAlbums.so",
    precompile_execution_file="deploy/precompile.jl")