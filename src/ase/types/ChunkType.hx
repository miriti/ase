package ase.types;

@:enum abstract ChunkType(Int) from Int to Int {
  var OLD_PALETTE_04 = 0x0004;
  var OLD_PALETTE_11 = 0x0011;
  var LAYER = 0x2004;
  var CEL = 0x2005;
  var CEL_EXTRA = 0x2006;
  var COLOR_PROFILE = 0x2007;
  var EXTERNAL_FILES = 0x2008;
  var MASK = 0x2016;
  var PATH = 0x2017;
  var TAGS = 0x2018;
  var PALETTE = 0x2019;
  var USER_DATA = 0x2020;
  var SLICE = 0x2022;
  var TILESET = 0x2023;
}
