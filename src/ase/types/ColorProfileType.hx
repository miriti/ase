package ase.types;

@:enum abstract ColorProfileType(Int) from Int to Int {
  var NoColorProfile = 0;
  var SRgb = 1;
  var EmbeddedICC = 2;
}
