package ase.chunks;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

using Lambda;

class PaletteEntry {
  public static inline var SIZE:Int = 6;

  public var flags:Int;
  public var red:Int;
  public var green:Int;
  public var blue:Int;
  public var alpha:Int;
  public var name:String;

  public var hasName(get, set):Bool;

  function get_hasName():Bool {
    return (flags & (1 << 0) != 0);
  }

  function set_hasName(val:Bool):Bool {
    flags = flags | (val ? 1 : 0);
    return val;
  }

  public static function fromBytes(bytes:Bytes):PaletteEntry {
    var entry = new PaletteEntry();
    var bi:BytesInput = new BytesInput(bytes);

    entry.flags = bi.readUInt16();

    entry.red = bi.readByte();
    entry.green = bi.readByte();
    entry.blue = bi.readByte();
    entry.alpha = bi.readByte();

    if (entry.hasName) {
      entry.name = bi.readString(bi.readUInt16());
    }

    return entry;
  }

  public function toBytes():Bytes {
    var bo = new BytesOutput();

    bo.writeUInt16(flags);
    bo.writeByte(red);
    bo.writeByte(green);
    bo.writeByte(blue);
    bo.writeByte(alpha);

    if (hasName) {
      bo.writeUInt16(name.length);
      bo.writeString(name);
    }

    return bo.getBytes();
  }

  public function toString() {
    return 'R: $red G: $green B: $blue A: $alpha';
  }

  public function new(?name:String, ?color:Int) {
    if (name != null) {
      this.name = name;
      hasName = true;
    }

    if (color != null) {
      red = (color >> 24) & 0xff;
      green = (color >> 16) & 0xff;
      blue = (color >> 8) & 0xff;
      alpha = color & 0xff;
    }
  }
}

class PaletteChunk extends Chunk {
  public var paletteSize:Int = 0;
  public var firstColorIndex:Int = 0;
  public var lastColorIndex:Int = -1;
  public var reserved:Bytes;
  public var entries:Map<Int, PaletteEntry> = [];

  override function getSizeWithoutHeader():Int {
    return 4 // palette size
      + 4 // firstColorIndex
      + 4 // lastColorIndex
      + 8 // reserved
      + PaletteEntry.SIZE * (lastColorIndex - firstColorIndex + 1);
  }

  public function addEntry(entry:PaletteEntry) {
    lastColorIndex++;
    entries[lastColorIndex] = entry;
    paletteSize++;
  }

  public static function fromBytes(bytes:Bytes):PaletteChunk {
    var chunk = new PaletteChunk();
    var bi = new BytesInput(bytes);

    chunk.paletteSize = bi.readInt32();
    chunk.firstColorIndex = bi.readInt32();
    chunk.lastColorIndex = bi.readInt32();
    chunk.reserved = bi.read(8);

    var entryStart:Int = bi.position;

    for (entryNum in chunk.firstColorIndex...chunk.lastColorIndex + 1) {
      var entry = PaletteEntry.fromBytes(bi.read(PaletteEntry.SIZE));
      chunk.entries[entryNum] = entry;
      entryStart += PaletteEntry.SIZE;
    }

    return chunk;
  }

  override function toBytes():Bytes {
    var bo = new BytesOutput();

    getHeaderBytes(bo);

    bo.writeInt32(paletteSize);
    bo.writeInt32(firstColorIndex);
    bo.writeInt32(lastColorIndex);
    for (_ in 0...8)
      bo.writeByte(0);

    for (entryNum in firstColorIndex...lastColorIndex + 1) {
      var entryBytes = entries[entryNum].toBytes();
      bo.writeBytes(entryBytes, 0, entryBytes.length);
    }

    return bo.getBytes();
  }

  public function new(?createHeader:Bool = false) {
    super(createHeader, PALETTE);
  }
}
