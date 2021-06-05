package ase.chunks;

import haxe.io.Bytes;
import haxe.io.BytesInput;

class UserDataChunk extends Chunk {
  public var flags:Int;
  public var text:String;
  public var hasText:Bool;
  public var hasColor:Bool;
  public var red:Int;
  public var green:Int;
  public var blue:Int;
  public var alpha:Int;

  public static function fromBytes(bytes:Bytes):UserDataChunk {
    var chunk = new UserDataChunk();
    var bytesInput = new BytesInput(bytes);

    chunk.flags = bytesInput.readInt32();

    chunk.hasText = chunk.flags & (1 << 0) != 0;
    chunk.hasColor = chunk.flags & (1 << 1) != 0;

    if (chunk.hasText) {
      chunk.text = bytesInput.readString(bytesInput.readUInt16());
    }

    if (chunk.hasColor) {
      chunk.red = bytesInput.readByte();
      chunk.green = bytesInput.readByte();
      chunk.blue = bytesInput.readByte();
      chunk.alpha = bytesInput.readByte();
    }

    return chunk;
  }

  public function new(?createHeader:Bool = false) {
    super(createHeader, USER_DATA);
  }
}
