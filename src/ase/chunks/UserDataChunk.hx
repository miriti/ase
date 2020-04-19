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

    hasText = flags == 1 || flags == 3;
    hasColor = flags == 2 || flags == 3;

    if (hasText) {
      text = bytesInput.readString((hasColor ? bytesInput.length
        - 4 : bytesInput.length)
        - 4);
    }

    if (hasColor) {
      red = bytesInput.readByte();
      green = bytesInput.readByte();
      blue = bytesInput.readByte();
      alpha = bytesInput.readByte();
    }
  }
}
