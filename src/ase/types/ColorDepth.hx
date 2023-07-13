package ase.types;

enum abstract ColorDepth(Int) from Int to Int {
  var BPP32 = 32;
  var BPP16 = 16;
  var BPP8 = 8;
  var INDEXED = 8;
}
