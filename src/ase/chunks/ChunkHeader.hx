package ase.chunks;

import ase.types.ChunkType;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

class ChunkHeader {
  public static inline var BYTE_SIZE:Int = 6;

  public var size:Int = 0;
  public var type:ChunkType;

  public static function fromBytes(bytes:Bytes):ChunkHeader {
    var chunkHeader = new ChunkHeader();
    var bytesInput:BytesInput = new BytesInput(bytes);

    chunkHeader.size = bytesInput.readInt32();
    chunkHeader.type = bytesInput.readUInt16();

    return chunkHeader;
  }

  public function toBytes():Bytes {
    var bytesOutput = new BytesOutput();

    bytesOutput.writeInt32(size);
    bytesOutput.writeUInt16(cast type);

    return bytesOutput.getBytes();
  }

  public function new(?type:ChunkType) {
    if (type != null) {
      this.type = type;
    }
  }
}
