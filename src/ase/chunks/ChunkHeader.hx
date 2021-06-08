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
    var bi:BytesInput = new BytesInput(bytes);

    chunkHeader.size = bi.readInt32();
    chunkHeader.type = bi.readUInt16();

    return chunkHeader;
  }

  public function toBytes(?out:BytesOutput):Bytes {
    var bo = out != null ? out : new BytesOutput();

    bo.writeInt32(size);
    bo.writeUInt16(cast type);

    return bo.getBytes();
  }

  public function new(?type:ChunkType) {
    if (type != null) {
      this.type = type;
    }
  }
}
