package ase;

import haxe.io.BytesInput;
import haxe.io.Bytes;
import ase.chunks.Chunk;
import ase.chunks.UserDataChunk;
import ase.chunks.CelChunk;
import ase.chunks.CelExtraChunk;
import ase.chunks.ChunkHeader;

class Frame {
  public var header:FrameHeader;
  public var chunks:Array<Chunk> = [];

  public function new(header:FrameHeader, frameData:Bytes) {
    var bytesInput:BytesInput = new BytesInput(frameData);

    this.header = header;

    var lastChunk:Chunk = null;

    for (numChunk in 0...header.numChunks) {
      var chunkHeader:ChunkHeader = new ChunkHeader(bytesInput.read(ChunkHeader.BYTE_SIZE));

      try {
        var chunkBytes:Bytes = bytesInput.read(chunkHeader.size - ChunkHeader.BYTE_SIZE);
        var chunk:Chunk = Chunk.factory(chunkHeader, chunkBytes);

        if (lastChunk != null) {
          if (Std.is(chunk, UserDataChunk)) {
            lastChunk.userData = cast chunk;
          }

          if (Std.is(chunk, CelExtraChunk) && Std.is(lastChunk, CelChunk)) {
            cast(lastChunk, CelChunk).extra = cast chunk;
          }
        }

        chunks.push(chunk);
        lastChunk = chunk;
      } catch (error:String) {
        trace('Error: ${error}');
      }
    }
  }
}
