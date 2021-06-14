package ase.chunks;

import ase.types.ColorProfileType;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

class ColorProfileChunk extends Chunk {
  public var colorProfileType:ColorProfileType = SRgb;
  public var flags:Int = 0;
  public var gamma:Float = 0;
  public var iccProfileData:Bytes;

  override function getSizeWithoutHeader():Int {
    var totalSize = 2 // colorProfileType
      + 2 // flags
      + 4 // gamma
      + 8; // reserved

    if (colorProfileType == EmbeddedICC) {
      totalSize += 4 // ICC Data length
        + iccProfileData.length;
    }

    return totalSize;
  }

  public static function fromBytes(bytes:Bytes):ColorProfileChunk {
    var chunk = new ColorProfileChunk();
    var bi = new BytesInput(bytes);

    chunk.colorProfileType = bi.readUInt16();
    chunk.flags = bi.readUInt16();
    chunk.gamma = bi.readFloat();
    bi.read(8);

    if (chunk.colorProfileType == EmbeddedICC) {
      var len:Int = bi.readInt32();
      chunk.iccProfileData = bi.read(len);
    }

    return chunk;
  }

  override function toBytes(?out:BytesOutput):Bytes {
    var bo = out != null ? out : new BytesOutput();

    writeHeaderBytes(bo);

    bo.writeUInt16(colorProfileType);
    bo.writeUInt16(flags);
    bo.writeFloat(gamma);
    for (_ in 0...8)
      bo.writeByte(0);

    if (colorProfileType == EmbeddedICC) {
      if (iccProfileData != null) {
        bo.writeInt32(iccProfileData.length);
        bo.writeBytes(iccProfileData, 0, iccProfileData.length);
      } else
        throw 'colorProfileType is set to EmbeddedICC but iccProfileData is not set';
    }

    return bo.getBytes();
  }

  public function new(?createHeader:Bool = false) {
    super(createHeader, COLOR_PROFILE);
  }
}
