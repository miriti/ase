package ase.chunks;

import haxe.io.Bytes;

typedef FrameTag = {
  fromFrame:Int,
  toFrame:Int,
  animDirection:Int,
  reserved:Bytes,
  tagColor:Int,
  extraByte:Int,
  tagName:String
};

class FrameTagsChunk extends Chunk {
  public var numTags:Int;
  public var reserved:Bytes;
  public var tags:Array<FrameTag> = [];

  public function new(header:ChunkHeader, chunkData:Bytes) {
    super(header, chunkData);

    numTags = bytesInput.readUInt16();
    reserved = bytesInput.read(8);

    for (tagIndex in 0...numTags) {
      var newFrameTag:FrameTag = {
        fromFrame: bytesInput.readUInt16(),
        toFrame: bytesInput.readUInt16(),
        animDirection: bytesInput.readByte(),
        reserved: bytesInput.read(8),
        tagColor: bytesInput.readInt24(),
        extraByte: bytesInput.readByte(),
        tagName: bytesInput.readString(bytesInput.readUInt16())
      };

      tags.push(newFrameTag);
    }
  }
}
