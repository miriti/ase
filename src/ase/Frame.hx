package ase;

import ase.chunks.CelChunk;
import ase.chunks.Chunk;
import ase.chunks.ColorProfileChunk;
import ase.chunks.LayerChunk;
import ase.types.ChunkType;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

using Lambda;

class Frame {
  public var header:FrameHeader;
  public var chunks:Array<Chunk> = [];
  public var chunkTypes:Map<Int, Array<Chunk>> = [];

  public var duration(get, set):Int;

  function get_duration():Int
    return header.duration;

  function set_duration(val:Int)
    return header.duration = val;

  /**
    Frame size in bytes
   */
  public var size(get, never):Int;

  function get_size():Int {
    return FrameHeader.BYTE_SIZE
      + chunks.fold((chunk, result) -> result + chunk.size, 0);
  }

  public static function fromBytes(bytes:Bytes):Frame {
    var bi:BytesInput = new BytesInput(bytes);
    var frame = new Frame();

    frame.header = FrameHeader.fromBytes(bi.read(FrameHeader.BYTE_SIZE));

    var lastChunk:Chunk = null;

    for (_ in 0...frame.header.numChunks) {
      var chunkSize:Int = bytes.getInt32(bi.position);
      var chunkBytes:Bytes = bi.read(chunkSize);
      var chunk:Chunk = Chunk.fromBytes(chunkBytes);

      if (lastChunk != null) {
        if (chunk.header.type == ChunkType.USER_DATA) {
          lastChunk.userData = cast chunk;
        }

        if (chunk.header.type == ChunkType.CEL_EXTRA
          && lastChunk.header.type == ChunkType.CEL) {
          cast(lastChunk, CelChunk).extra = cast chunk;
        }
      }

      frame.addChunk(chunk);

      lastChunk = chunk;
    }
    return frame;
  }

  public static function createFirstFrame():Frame {
    var frame = new Frame();
    frame.createHeader();
    frame.addChunk(new ColorProfileChunk(true));
    frame.addChunk(new LayerChunk(true));

    return frame;
  }

  public function addChunk(chunk:Chunk) {
    chunks.push(chunk);
    if (!chunkTypes.exists(chunk.header.type))
      chunkTypes[chunk.header.type] = [chunk];
    else
      chunkTypes[chunk.header.type].push(chunk);
  }

  public function createHeader() {
    header = new FrameHeader();
  }

  public function toBytes():Bytes {
    var bo = new BytesOutput();
    header.size = size;
    header.numChunks = header.oldNumChunks = chunks.length;
    var headerBytes = header.toBytes();
    bo.writeBytes(headerBytes, 0, headerBytes.length);
    return bo.getBytes();
  }

  public function new(?header:FrameHeader) {
    if (header != null)
      this.header = header;
  }
}
