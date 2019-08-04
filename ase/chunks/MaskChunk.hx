package ase.chunks;

import haxe.io.Bytes;

class MaskChunk extends Chunk {
  public var xPosition:Int;
  public var yPosition:Int;
  public var width:Int;
  public var height:Int;
  public var reserved:Bytes;

  public function new(header:ChunkHeader, chunkData:Bytes) {
    super(header, chunkData);

    xPosition = bytesInput.readInt16();
    yPosition = bytesInput.readInt16();

    width = bytesInput.readUInt16();
    height = bytesInput.readUInt16();

    reserved = bytesInput.read(8);

    // TODO: Read mask name and data. Or not as this chunk is deprecated
  }
}
