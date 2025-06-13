{ lib
, pkgs
,
}:
let
  grabLibPathFromRPM = packages:
    let
      pkgstr = lib.concatStringsSep " " packages;
    in
    pkgs.runCommand "gl-lib-path-from-fedora-rpm"
      { __noChroot = true; }
      ''
        ${pkgs.rpm}/bin/rpm -ql ${pkgstr} | ${pkgs.pcre}/bin/pcregrep "^/usr/lib(64)?/.*\.so.*" > $out || touch "$out"
      '';

in
{
  fixGLFedora = import ./make-fixGL.nix {
    os = "Fedora";
    libpathsfile = (grabLibPathFromRPM [
      # all we need are the nvidia libraries
      "xorg-x11-drv-nvidia-cuda-libs"
      "xorg-x11-drv-nvidia-libs"
    ]);
    makeNoVersioningSymLink = true;
  };
}
