package ase;

import ase.types.ColorDepth;
import ase.types.Serializable;
import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

class AseHeader implements Serializable {
  public static final ASEPRITE_MAGIC:Int = 0xA5E0;
  public static final SIZE:Int = 128;

  public var fileSize:Int32;
  public var magic:Int = ASEPRITE_MAGIC;
  public var frames:Int;
  public var width:Int;
  public var height:Int;
  public var colorDepth:ColorDepth = BPP32;
  public var flags:Int32 = 1;
  public var speed:Int = 100;
  public var paletteEntry:Int = 0;
  public var colorsNumber:Int = 0;
  public var pixelWidth:Int = 0;
  public var pixelHeight:Int = 0;
  public var gridX:Int = 0;
  public var gridY:Int = 0;
  public var gridWidth:Int = 16;
  public var gridHeight:Int = 16;

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
    header.gridX = bi.readInt16();
    header.gridY = bi.readInt16();
    header.gridWidth = bi.readUInt16();
    header.gridHeight = bi.readUInt16();
    bi.read(84);

    return header;
  }

  public function toBytes(?out:BytesOutput):Bytes {
    var bo = out != null ? out : new BytesOutput();

    bo.writeInt32(fileSize);
    bo.writeUInt16(magic);
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
    bo.writeInt16(gridX);
    bo.writeInt16(gridY);
    bo.writeUInt16(gridWidth);
    bo.writeUInt16(gridHeight);

    for (_ in 0...84)
      bo.writeByte(0);

    return bo.getBytes();
  }

  public function toString():String {
    // @formatter:off
    return [
      'AseHeader:',
      '  fileSize: $fileSize',
      '  magic: $magic',
      '  frames: $frames',
      '  width: $width',
      '  height: $height',
      '  colorDepth: $colorDepth',
      '  flags: $flags',
      '  speed: $speed',
      '  paletteEntry: $paletteEntry',
      '  colorsNumber: $colorsNumber',
      '  pixelWidth: $pixelWidth',
      '  pixelHeight: $pixelHeight',
      '  gridX: $gridX',
      '  gridY: $gridY',
      '  gridWidth: $gridWidth',
      '  gridHeight: $gridHeight',
    ].join('\n');
    // @formatter:on
  }

  public function new() {}
}
