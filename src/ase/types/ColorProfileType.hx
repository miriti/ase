package ase.types;

@:enum abstract ColorProfileType(Int) from Int to Int {
  var NoColorProfile = 0;
  var sRgb = 1;
  var embeddedICC = 2;
}
