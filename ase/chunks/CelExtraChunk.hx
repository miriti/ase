package ase.chunks;

import haxe.io.Bytes;

class CelExtraChunk extends Chunk {
  public var flags:Int;
  public var preciseXPosition:Float;
  public var preciseYPosition:Float;
  public var widthInSprite:Float;
  public var heightInSprite:Float;
  public var reserved:Bytes;

  public function new(header:ChunkHeader, chunkData:Bytes) {
    super(header, chunkData);

    flags = bytesInput.readUInt16();
    preciseXPosition = bytesInput.readFloat();
    preciseYPosition = bytesInput.readFloat();
    widthInSprite = bytesInput.readFloat();
    heightInSprite = bytesInput.readFloat();
    reserved = bytesInput.read(16);
  }
}
