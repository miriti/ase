package ase.chunks;

import haxe.Int32;
import haxe.io.Bytes;

class ColorProfileChunk extends Chunk {
  public var colorProfileType:Int;
  public var flags:Int;
  public var gamma:Float;
  public var reserved:Bytes;

  public function new(header:ChunkHeader, chunkData:Bytes) {
    super(header, chunkData);

    colorProfileType = bytesInput.readUInt16();
    flags = bytesInput.readUInt16();
    gamma = bytesInput.readFloat();
    reserved = bytesInput.read(0);
  }
}
