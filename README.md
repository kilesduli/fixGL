# fixGL

fixGL is a warpper to solve the "OpenGL" problem with nix. Unlike nixGL, we just use libraries provided by the host system, instead of re-downloading them within nix. In other words, it's just another nixGL.

# How to use
Now, it only supports fedora and nvidia.
``` bash
nix --option sandbox relaxed run github:kilesduli/fixGL#fixGLFedora
```

# TODO
- support mesa.
- support arch, or other system.

