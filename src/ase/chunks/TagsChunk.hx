package ase.chunks;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

using Lambda;

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

  override function getSizeWithoutHeader():Int {
    return 2 // numTags
      + 8 // reserved
      + tags.map(tag -> (2 // fromFrame
        + 2 // toFrame
        + 1 // animDirection
        + 8 // reserved
        + 3 // tagColor
        + 1 // extraByte
        + 2 // tagName string size
        + tag.tagName.length)).fold((tagSize:Int, result:Int) -> tagSize
        + result, 0);
  }

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

  override function toBytes():Bytes {
    var bo = new BytesOutput();

    getHeaderBytes(bo);

    bo.writeUInt16(numTags);
    for (_ in 0...8)
      bo.writeByte(0);

    for (tag in tags) {
      bo.writeInt16(tag.fromFrame);
      bo.writeInt16(tag.toFrame);
      bo.writeByte(tag.animDirection);
      for (_ in 0...8)
        bo.writeByte(0);
      bo.writeInt24(tag.tagColor);
      bo.writeByte(tag.extraByte);
      bo.writeUInt16(tag.tagName.length);
      bo.writeString(tag.tagName);
    }

    return bo.getBytes();
  }

  private function new(?createHeader:Bool = false) {
    super(createHeader, TAGS);
  }
}
