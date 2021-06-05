package ase.chunks;

import haxe.io.Bytes;
import haxe.io.BytesInput;

class CelExtraChunk extends Chunk {
  public var flags:Int;
  public var preciseXPosition:Float;
  public var preciseYPosition:Float;
  public var widthInSprite:Float;
  public var heightInSprite:Float;
  public var reserved:Bytes;

  public static function fromBytes(bytes:Bytes):CelExtraChunk {
    var chunk = new CelExtraChunk();
    var bi = new BytesInput(bytes);

    chunk.flags = bi.readUInt16();
    chunk.preciseXPosition = bi.readFloat();
    chunk.preciseYPosition = bi.readFloat();
    chunk.widthInSprite = bi.readFloat();
    chunk.heightInSprite = bi.readFloat();
    chunk.reserved = bi.read(16);

    return chunk;
  }

  private function new(?createHeader:Bool = false) {
    super(createHeader, CEL_EXTRA);
  }
}
