package ase.chunks;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

class CelExtraChunk extends Chunk {
  public var flags:Int;
  public var preciseXPosition:Float;
  public var preciseYPosition:Float;
  public var widthInSprite:Float;
  public var heightInSprite:Float;

  override function getSizeWithoutHeader():Int {
    return 2 // flags
      + 4 // preciseXPosition
      + 4 // preciseYPosition
      + 4 // widthInSprite
      + 4 // heightInSprite
      + 16; // reserved
  }

  public static function fromBytes(bytes:Bytes):CelExtraChunk {
    var chunk = new CelExtraChunk();
    var bi = new BytesInput(bytes);

    chunk.flags = bi.readUInt16();
    chunk.preciseXPosition = bi.readFloat();
    chunk.preciseYPosition = bi.readFloat();
    chunk.widthInSprite = bi.readFloat();
    chunk.heightInSprite = bi.readFloat();
    bi.read(16);

    return chunk;
  }

  override function toBytes(?out:BytesOutput):Bytes {
    var bo = out != null ? out : new BytesOutput();

    writeHeaderBytes(bo);

    bo.writeUInt16(flags);
    bo.writeFloat(preciseXPosition);
    bo.writeFloat(preciseYPosition);
    bo.writeFloat(widthInSprite);
    bo.writeFloat(heightInSprite);
    for (_ in 0...16)
      bo.writeByte(0);

    return bo.getBytes();
  }

  public function clone():CelExtraChunk {
    var clonedChunk = new CelExtraChunk(true);

    clonedChunk.flags = flags;
    clonedChunk.preciseXPosition = preciseXPosition;
    clonedChunk.preciseYPosition = preciseYPosition;
    clonedChunk.widthInSprite = widthInSprite;
    clonedChunk.heightInSprite = heightInSprite;

    return clonedChunk;
  }

  private function new(?createHeader:Bool = false) {
    super(createHeader, CEL_EXTRA);
  }
}
