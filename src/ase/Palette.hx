package ase;

import ase.chunks.Chunk;
import ase.chunks.OldPaleteChunk;
import ase.chunks.PaletteChunk;

using Lambda;

typedef PaletteEntry = {
  red:Int,
  green:Int,
  blue:Int,
  alpha:Int
};

class Palette {
  /**
    Default palette used by Aseprite when a new file is created
   */
  public static final DB32 = [
    0x000000ff, 0x222034ff, 0x45283cff, 0x663931ff, 0x8f563bff, 0xdf7126ff,
    0xd9a066ff, 0xeec39aff, 0xfbf236ff, 0x99e550ff, 0x6abe30ff, 0x37946eff,
    0x4b692fff, 0x524b24ff, 0x323c39ff, 0x3f3f74ff, 0x306082ff, 0x5b6ee1ff,
    0x639bffff, 0x5fcde4ff, 0xcbdbfcff, 0xffffffff, 0x9badb7ff, 0x847e87ff,
    0x696a6aff, 0x595652ff, 0x76428aff, 0xac3232ff, 0xd95763ff, 0xd77bbaff,
    0x8f974aff, 0x8a6f30ff
  ];

  public final entries:Array<PaletteEntry>;

  public var numColors(get, never):Int;

  function get_numColors() {
    return entries.length;
  }

  /** @deprecated No reason to use this. First index will always be `0` **/
  public var firstIndex(get, never):Int;

  function get_firstIndex():Int {
    return 0;
  }

  /** @deprecated No reason to use this. Last index will alway equal to `entries.length - 1` **/
  public var lastIndex(get, never):Int;

  function get_lastIndex():Int {
    return entries.length - 1;
  }

  /** @deprecated One can just use `palette.entries[index]` instead **/
  inline public function getEntry(index:Int):PaletteEntry {
    return entries[index];
  }

  public function getRGBA(index:Int) {
    var entry = entries[index];
    return
      ((entry.red & 0xFF) << 24) | ((entry.green & 0xFF) << 16) | ((entry.blue & 0xFF) << 8) | (entry.alpha & 0xFF);
  }

  public function getARGB(index:Int) {
    var entry = entries[index];
    return
      ((entry.alpha & 0xFF) << 24) | ((entry.red & 0xFF) << 16) | ((entry.green & 0xFF) << 8) | (entry.blue & 0xFF);
  }

  public static function createDefault() {
    return fromRGBA(DB32);
  }

  /**
    Create a palette from an array of RGBA values
  **/
  public static function fromRGBA(rgba:Array<Int>) {
    return new Palette(rgba.map((value) -> ({
      red: (value >> 24) & 0xff,
      green: (value >> 16) & 0xff,
      blue: (value >> 8) & 0xff,
      alpha: value & 0xff
    })));
  }

  /**
    Create palette from Palette Chunk (0x2019)
  **/
  public static function fromChunk(chunk:PaletteChunk) {
    return new Palette(chunk.entries.map((item) -> {
      return {
        red: item.red,
        green: item.green,
        blue: item.blue,
        alpha: item.alpha
      }
    }));
  }

  /**
    Create palette from Old Plaette Chunk (0x0004)
  **/
  public static function fromOldChunk(chunk:OldPaleteChunk) {
    final entries:Array<PaletteEntry> = [];

    for (packet in chunk.packets) {
      for (color in packet.colors) {
        entries.push({
          red: color.red,
          green: color.green,
          blue: color.blue,
          alpha: 0xff
        });
      }
    }

    return new Palette(entries);
  }

  /**
    Creates the Old Palette Chunk (0x0004) if there are fewer than 256 colors
    in the palette and no alpha channel (all alpha values are 0xff). Otherwise,
    creates the Palette Chunk (0x2019).
   */
  public function toChunk():Chunk {
    final useOld = entries.length <= 256
      && entries.filter(e -> e.alpha != 0xff).length == 0;

    if (useOld) {
      return OldPaleteChunk.fromPaletteEntries(entries);
    } else {
      return PaletteChunk.fromPaletteEntries(entries);
    }
  }

  private function new(entries:Array<PaletteEntry>) {
    this.entries = entries;
  }
}
