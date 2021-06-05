package ase.chunks;

import haxe.io.Bytes;
import haxe.io.BytesInput;

class MaskChunk extends Chunk {
  public var xPosition:Int;
  public var yPosition:Int;
  public var width:Int;
  public var height:Int;
  public var reserved:Bytes;

  public static function fromBytes(bytes:Bytes):MaskChunk {
    var chunk = new MaskChunk();

    var bi = new BytesInput(bytes);

    chunk.xPosition = bi.readInt16();
    chunk.yPosition = bi.readInt16();

    chunk.width = bi.readUInt16();
    chunk.height = bi.readUInt16();

    chunk.reserved = bi.read(8);

    // TODO: Read mask name and data. Or not as this chunk is deprecated

    return chunk;
  }

  private function new(?createHeader:Bool = false) {
    super(createHeader, MASK);
  }
}
