package ase.chunks;

import haxe.io.Bytes;

class UserDataChunk extends Chunk {
  public var flags:Int;
  public var text:String;
  public var hasText:Bool;
  public var hasColor:Bool;
  public var red:Int;
  public var green:Int;
  public var blue:Int;
  public var alpha:Int;

  public function new(header:ChunkHeader, chunkData:Bytes) {
    super(header, chunkData);

    flags = bytesInput.readInt32();

    hasText = flags & (1 << 0) != 0;
    hasColor = flags & (1 << 1) != 0;

    if (hasText) {
      text = bytesInput.readString(bytesInput.readUInt16());
    }

    if (hasColor) {
      red = bytesInput.readByte();
      green = bytesInput.readByte();
      blue = bytesInput.readByte();
      alpha = bytesInput.readByte();
    }
  }
}
