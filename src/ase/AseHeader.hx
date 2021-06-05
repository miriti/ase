package ase;

import ase.types.ColorDepth;
import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

class AseHeader {
  public static final ASEPRITE_MAGIC:Int = 0xA5E0;
  public static final SIZE:Int = 128;

  public var fileSize:Int32;
  public var magic:Int = ASEPRITE_MAGIC;
  public var frames:Int;
  public var width:Int;
  public var height:Int;
  public var colorDepth:ColorDepth = BPP32;
  public var flags:Int32;
  public var speed:Int = 100;
  public var paletteEntry:Int;
  public var colorsNumber:Int;
  public var pixelWidth:Int;
  public var pixelHeight:Int;
  public var gridX:Int = 0;
  public var gridY:Int = 0;
  public var gridWidth:Int = 16;
  public var gridHeight:Int = 16;
  public var reserved:Bytes;

  public var size(get, never):Int;

  function get_size():Int {
    return SIZE;
  }

  public static function fromBytes(headerData:Bytes):AseHeader {
    var header = new AseHeader();

    var bi = new BytesInput(headerData);

    header.fileSize = bi.readInt32();
    header.magic = bi.readUInt16();
    if (header.magic != ASEPRITE_MAGIC) {
      throw 'Invalid magic number (should be 0xA5E0)';
    }
    header.frames = bi.readUInt16();
    header.width = bi.readUInt16();
    header.height = bi.readUInt16();
    header.colorDepth = bi.readUInt16();
    header.flags = bi.readInt32();
    header.speed = bi.readUInt16();

    if (bi.readInt32() != 0 || bi.readInt32() != 0) {
      throw 'DWORDs at 20 and 24 should be zero';
    }

    header.paletteEntry = bi.readByte();
    bi.read(3); // ignore
    header.colorsNumber = bi.readUInt16();
    header.pixelWidth = bi.readByte();
    header.pixelHeight = bi.readByte();
    header.gridX = bi.readByte();
    header.gridY = bi.readByte();
    header.gridWidth = bi.readUInt16();
    header.gridHeight = bi.readUInt16();
    header.reserved = bi.read(84);

    return header;
  }

  public function toBytes():Bytes {
    var bo = new BytesOutput();

    bo.writeInt32(fileSize);
    bo.writeUInt16(ASEPRITE_MAGIC);
    bo.writeUInt16(frames);
    bo.writeUInt16(width);
    bo.writeUInt16(height);
    bo.writeUInt16(colorDepth);
    bo.writeInt32(flags);
    bo.writeUInt16(speed);
    bo.writeInt32(0);
    bo.writeInt32(0);
    bo.writeByte(paletteEntry);
    for (_ in 0...3)
      bo.writeByte(0); // ignored bytes
    bo.writeUInt16(colorsNumber);
    bo.writeByte(pixelWidth);
    bo.writeByte(pixelHeight);
    bo.writeByte(gridX);
    bo.writeByte(gridY);
    bo.writeUInt16(gridWidth);
    bo.writeUInt16(gridHeight);

    final RESERVED:Int = 84;
    var empty = Bytes.alloc(RESERVED);
    empty.fill(0, RESERVED, 0);
    bo.writeBytes(empty, 0, RESERVED); // reserved

    return bo.getBytes();
  }

  public function new() {}
}
