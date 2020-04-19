package ase;

import haxe.io.BytesInput;
import haxe.Int32;
import haxe.io.Bytes;

class AseHeader {
  public static inline var ASEPRITE_MAGIC:Int = 0xA5E0;

  public var fileSize:Int32;
  public var magic:Int;
  public var frames:Int;
  public var width:Int;
  public var height:Int;
  public var colorDepth:Int;
  public var flags:Int32;
  public var speed:Int;
  public var paletteEntry:Int;
  public var colorsNumber:Int;
  public var pixelWidth:Int;
  public var pixelHeight:Int;
  public var gridX:Int;
  public var gridY:Int;
  public var gridWidth:Int;
  public var gridHeight:Int;
  public var reserved:Bytes;

  public function new(headerData:Bytes) {
    var bytesInput = new BytesInput(headerData);
    fileSize = bytesInput.readInt32();
    magic = bytesInput.readUInt16();
    if (magic != 0xA5E0) {
      throw 'Invalid magic number (should be 0xA5E0)';
    }
    frames = bytesInput.readUInt16();
    width = bytesInput.readUInt16();
    height = bytesInput.readUInt16();
    colorDepth = bytesInput.readUInt16();
    flags = bytesInput.readInt32();
    speed = bytesInput.readUInt16();

    if (bytesInput.readInt32() != 0 || bytesInput.readInt32() != 0) {
      throw 'DWORDs at 20 and 24 should be zero';
    }

    paletteEntry = bytesInput.readByte();
    bytesInput.read(3); // ignore
    colorsNumber = bytesInput.readUInt16();
    pixelWidth = bytesInput.readByte();
    pixelHeight = bytesInput.readByte();
    gridX = bytesInput.readByte();
    gridY = bytesInput.readByte();
    gridWidth = bytesInput.readUInt16();
    gridHeight = bytesInput.readUInt16();
    reserved = bytesInput.read(84);
  }
}
