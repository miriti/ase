package ase.chunks;

import haxe.io.Bytes;
import haxe.io.BytesInput;

class PaletteEntry {
  public static inline var SIZE:Int = 6;

  public var flags:Int;
  public var red:Int;
  public var green:Int;
  public var blue:Int;
  public var alpha:Int;
  public var name:String;

  public function new(entryData:Bytes) {
    var bytesInput:BytesInput = new BytesInput(entryData);

    flags = bytesInput.readUInt16();

    red = bytesInput.readByte();
    green = bytesInput.readByte();
    blue = bytesInput.readByte();
    alpha = bytesInput.readByte();

    if (flags & (1 << 0) != 0) {
      name = bytesInput.readString(bytesInput.readUInt16());
    }
  }

  public function toString() {
    return 'R: $red G: $green B: $blue A: $alpha';
  }
}

class PaletteChunk extends Chunk {
  public var paletteSize:Int;
  public var firstColorIndex:Int;
  public var lastColorIndex:Int;
  public var reserved:Bytes;
  public var entries:Map<Int, PaletteEntry> = [];

  public static function fromBytes(bytes:Bytes):PaletteChunk {
    var chunk = new PaletteChunk();

    var bi = new BytesInput(bytes);
    chunk.paletteSize = bi.readInt32();
    chunk.firstColorIndex = bi.readInt32();
    chunk.lastColorIndex = bi.readInt32();
    chunk.reserved = bi.read(8);

    var entryStart:Int = 20;

    for (entryNum in chunk.firstColorIndex...chunk.lastColorIndex + 1) {
      var entry:PaletteEntry = new PaletteEntry(bi.read(PaletteEntry.SIZE));
      chunk.entries.set(entryNum, entry);
      entryStart += PaletteEntry.SIZE;
    }

    return chunk;
  }

  private function new(?createHeader:Bool = false) {
    super(createHeader, PALETTE);
  }
}
