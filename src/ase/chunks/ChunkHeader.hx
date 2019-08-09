package ase.chunks;

import haxe.io.BytesInput;
import haxe.io.Bytes;

class ChunkHeader {
  public static inline var BYTE_SIZE:Int = 6;

  public var size:Int;
  public var type:Int;
  public var typeName:String;

  public function new(headerData:Bytes) {
    var bytesInput:BytesInput = new BytesInput(headerData);
    size = bytesInput.readInt32();
    type = bytesInput.readUInt16();
    typeName = ChunkType.NAMES[
      type
    ];
  }
}
