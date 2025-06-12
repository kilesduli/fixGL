{ os
, libpathsfile
, makeNoVersioningSymLink ? false
}:

{ linkFarm
, writeScriptBin
, runtimeShell
, lib
, ...
}:
let
  inherit (lib) splitString forEach;
  inherit (builtins) readFile elemAt match filter partition removeAttrs;
in
let
  splitLibComponents = libpath:
    let
      name = baseNameOf libpath;
      result = match "^([^ ]+\\.so)\.?(([0-9+]).*)?$" name;
    in
    if match == null
    then null
    else
      { name = (elemAt result 0); path = libpath; majorVersion = (elemAt result 2); fullVersion = (elemAt result 1); };

  mkLibNoVersioningSymLink = libpaths:
    let
      removeVersion = libattr: removeAttrs libattr [ "majorVersion" "fullVersion" ];
      filterNotNull = ls: (filter (e: e != null) ls);
      filterMajorEqFullVersion = ls: (partition (x: x.majorVersion == x.fullVersion) ls);
      libdatas = (filterMajorEqFullVersion (filterNotNull (map splitLibComponents libpaths)));
    in
    (forEach libdatas.wrong (full:
      let
        filterMajorResult = (filter (x: x.name == full.name) libdatas.right);
        major = if filterMajorResult != [ ] then elemAt filterMajorResult 0 else null;
      in
      if major != null
      then removeVersion major
      else removeVersion full
    ));

  mkLinkFarmEntryFromFile = libraryPathFile:
    let
      libpaths = builtins.filter (s: s != "") (splitString "\n" (readFile libraryPathFile));
    in
    if libpaths != [ ]
    then (map (libpath: { name = baseNameOf libpath; path = libpath; }) libpaths) ++
      (if makeNoVersioningSymLink then (mkLibNoVersioningSymLink libpaths) else [ ])
    else throw "found 0 libpath, build failure.";

  writeGLScript = { name, ldpath }:
    writeScriptBin name
      ''
        #!${runtimeShell}

        export LD_LIBRARY_PATH=${ldpath}"''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
        exec "$@"
      '';
in
writeGLScript {
  name = "fixGL";
  ldpath = linkFarm "fixGL-lib-path-for-${os}"
    (mkLinkFarmEntryFromFile libpathsfile);
}
