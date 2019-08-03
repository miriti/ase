package ase.chunks;

class ChunkType {
  public static inline var OLD_PALETTE_04:Int = 0x0004;
  public static inline var OLD_PALETTE_11:Int = 0x0011;
  public static inline var LAYER:Int = 0x2004;
  public static inline var CEL:Int = 0x2005;
  public static inline var CEL_EXTRA:Int = 0x2006;
  public static inline var COLOR_PROFILE:Int = 0x2007;
  public static inline var MASK:Int = 0x2016;
  public static inline var PATH:Int = 0x2017;
  public static inline var FRAME_TAGS:Int = 0x2018;
  public static inline var PALETTE:Int = 0x2019;
  public static inline var USER_DATA:Int = 0x2020;
  public static inline var SLICE:Int = 0x2022;

  public static var NAMES:Map<Int, String> = [
    OLD_PALETTE_04 => "OLD_PALETTE_04",
    OLD_PALETTE_11 => "OLD_PALETTE_11",
    LAYER => "LAYER",
    CEL => "CEL",
    CEL_EXTRA => "CEL_EXTRA",
    COLOR_PROFILE => "COLOR_PROFILE",
    MASK => "MASK",
    PATH => "PATH",
    FRAME_TAGS => "FRAME_TAGS",
    PALETTE => "PALETTE",
    USER_DATA => "USER_DATA",
    SLICE => "SLICE",
  ];
  public static var CLASSES:Map<Int, Class<Chunk>> = [
    LAYER => LayerChunk,
    CEL => CelChunk,
    CEL_EXTRA => CelExtraChunk,
    COLOR_PROFILE => ColorProfileChunk,
    PALETTE => PaletteChunk,
    USER_DATA => UserDataChunk
  ];
}
