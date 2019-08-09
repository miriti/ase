package ase.chunks;

import haxe.io.BytesInput;
import haxe.io.Bytes;

class Chunk {
  public var header:ChunkHeader;
  public var userData:UserDataChunk;

  private var bytesInput:BytesInput;

  public function new(header:ChunkHeader, chunkData:Bytes) {
    bytesInput = new BytesInput(chunkData);
    this.header = header;
  }

  public static function factory(header:ChunkHeader, chunkData:Bytes):Chunk {
    var chunkClass:Class<Chunk> = ChunkType.CLASSES[
      header.type
    ];

    if (chunkClass != null) {
      return Type.createInstance(chunkClass, [
        header,
        chunkData
      ]);
    }

    trace('Unsupported chunk: 0x${StringTools.hex(header.type, 4)}');
    return new Chunk(header, chunkData);
  }
}
