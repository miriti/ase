package ase;

import ase.chunks.PaletteChunk;

class Palette {
  public static final DB32 = [
    0x000000ff, 0x222034ff, 0x45283cff, 0x663931ff, 0x8f563bff, 0xdf7126ff,
    0xd9a066ff, 0xeec39aff, 0xfbf236ff, 0x99e550ff, 0x6abe30ff, 0x37946eff,
    0x4b692fff, 0x524b24ff, 0x323c39ff, 0x3f3f74ff, 0x306082ff, 0x5b6ee1ff,
    0x639bffff, 0x5fcde4ff, 0xcbdbfcff, 0xffffffff, 0x9badb7ff, 0x847e87ff,
    0x696a6aff, 0x595652ff, 0x76428aff, 0xac3232ff, 0xd95763ff, 0xd77bbaff,
    0x8f974aff, 0x8a6f30ff
  ];

  public var chunk:PaletteChunk;

  public var firstIndex(get, never):Int;

  function get_firstIndex():Int {
    return chunk.firstColorIndex;
  }

  public var lastIndex(get, never):Int;

  function get_lastIndex():Int {
    return chunk.lastColorIndex;
  }

  public function getEntry(index:Int):PaletteEntry {
    return chunk.entries[index];
  }

  public function getRGBA(index:Int) {
    var entry = getEntry(index);
    return
      ((entry.red & 0xFF) << 24) | ((entry.green & 0xFF) << 16) | ((entry.blue & 0xFF) << 8) | (entry.alpha & 0xFF);
  }

  public function getARGB(index:Int) {
    var entry = getEntry(index);
    return
      ((entry.alpha & 0xFF) << 24) | ((entry.red & 0xFF) << 16) | ((entry.green & 0xFF) << 8) | (entry.blue & 0xFF);
  }

  public function new(?chunk:PaletteChunk, ?colors:Array<Int>) {
    if (chunk != null)
      this.chunk = chunk;
    else {
      this.chunk = new PaletteChunk(true);

      if (colors != null) {
        for (color in colors) {
          this.chunk.addEntry(new PaletteEntry(color));
        }
      }
    }
  }
}
