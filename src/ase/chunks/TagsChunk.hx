package ase.chunks;

import haxe.io.Bytes;
import haxe.io.BytesInput;

typedef Tag = {
  fromFrame:Int,
  toFrame:Int,
  animDirection:Int,
  reserved:Bytes,
  tagColor:Int,
  extraByte:Int,
  tagName:String
};

class TagsChunk extends Chunk {
  public var numTags:Int;
  public var reserved:Bytes;
  public var tags:Array<Tag> = [];

  public static function fromBytes(bytes:Bytes):TagsChunk {
    var chunk = new TagsChunk();

    var bi = new BytesInput(bytes);

    chunk.numTags = bi.readUInt16();
    chunk.reserved = bi.read(8);

    for (_ in 0...chunk.numTags) {
      var newFrameTag:Tag = {
        fromFrame: bi.readUInt16(),
        toFrame: bi.readUInt16(),
        animDirection: bi.readByte(),
        reserved: bi.read(8),
        tagColor: bi.readInt24(),
        extraByte: bi.readByte(),
        tagName: bi.readString(bi.readUInt16())
      };

      chunk.tags.push(newFrameTag);
    }

    return chunk;
  }

  private function new(?createHeader:Bool = false) {
    super(createHeader, TAGS);
  }
}
