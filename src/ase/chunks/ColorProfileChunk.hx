package ase.chunks;

import ase.types.ColorProfileType;
import haxe.io.Bytes;
import haxe.io.BytesInput;

class ColorProfileChunk extends Chunk {
  public var colorProfileType:ColorProfileType = NoColorProfile;
  public var flags:Int = 1;
  public var gamma:Float = 1.0;
  public var reserved:Bytes;

  public static function fromBytes(bytes:Bytes):ColorProfileChunk {
    var chunk = new ColorProfileChunk();
    var bi = new BytesInput(bytes);

    chunk.colorProfileType = bi.readUInt16();
    chunk.flags = bi.readUInt16();
    chunk.gamma = bi.readFloat();
    chunk.reserved = bi.read(0);

    return chunk;
  }

  public function new(?createHeader:Bool = false) {
    super(createHeader, COLOR_PROFILE);
  }
}
