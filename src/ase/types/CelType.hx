package ase.types;

@:enum abstract CelType(Int) from Int to Int {
  var Raw = 0;
  var Linked = 1;
  var CompressedImage = 2;
  var CompressedTilemap = 3;
}
