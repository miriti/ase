package ase;

import haxe.Int32;
import haxe.io.Bytes;

class AseHeader {
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
  public var reserved:Bytes;

  public function new(headerData:Bytes) {
    fileSize = headerData.getInt32(0);
    magic = headerData.getUInt16(4);
    if (magic != 0xA5E0) {
      throw 'Invalid magic number (should be 0xA5E0)';
    }
    frames = headerData.getUInt16(6);
    width = headerData.getUInt16(8);
    height = headerData.getUInt16(10);
    colorDepth = headerData.getUInt16(12);
    flags = headerData.getInt32(14);
    speed = headerData.getUInt16(18);

    if (headerData.getInt32(20) != 0 || headerData.getInt32(24) != 0) {
      throw 'DWORDs at 20 and 24 should be zero';
    }

    paletteEntry = headerData.get(28);
    colorsNumber = headerData.getUInt16(31);
    pixelWidth = headerData.get(33);
    pixelHeight = headerData.get(34);
    reserved = headerData.sub(35, 92);
  }
}
