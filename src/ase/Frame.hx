package ase;

import ase.chunks.CelChunk;
import ase.chunks.Chunk;
import ase.types.ChunkType;
import ase.types.Serializable;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

using Lambda;

class Frame implements Serializable {
  public var ase:Ase;

  public var header:FrameHeader;

  public var chunks:Array<Chunk> = [];
  public var chunkTypes:Map<ChunkType, Array<Chunk>> = [];

  public var duration(get, set):Int;

  public final cels:Map<Int, Cel> = [];

  function get_duration():Int
    return header.duration;

  function set_duration(val:Int)
    return header.duration = val;

  /**
    Frame size in bytes
   */
  public var size(get, never):Int;

  function get_size():Int {
    return chunks.fold((chunk, result) -> result + chunk.size,
      FrameHeader.BYTE_SIZE);
  }

  /**
    Parse bytes to create a new frame

    @param bytes bytes to parse
    @param ase (optional) `ase.Ase` instance to attach the frame to
   */
  public static function fromBytes(bytes:Bytes, ?ase:Ase):Frame {
    var bi:BytesInput = new BytesInput(bytes);
    var frame = new Frame(ase);

    frame.header = FrameHeader.fromBytes(bi.read(FrameHeader.BYTE_SIZE));

    var lastChunk:Chunk = null;

    for (_ in 0...frame.header.numChunks) {
      var chunkSize:Int = bytes.getInt32(bi.position);
      var chunkBytes:Bytes = bi.read(chunkSize);
      var chunk:Chunk = Chunk.fromBytes(chunkBytes);

      if (lastChunk != null) {
        if (chunk.header.type == USER_DATA) {
          lastChunk.userData = cast chunk;
        }

        if (chunk.header.type == CEL_EXTRA && lastChunk.header.type == CEL) {
          cast(lastChunk, CelChunk).extra = cast chunk;
        }
      }

      if (chunk.header.type == CEL) {
        var celChunk:CelChunk = cast chunk;
        frame.cels[celChunk.layerIndex] = new Cel(celChunk, frame,
          celChunk.layerIndex);
      }

      frame.addChunk(chunk);

      lastChunk = chunk;
    }
    return frame;
  }

  public function addChunk(chunk:Chunk) {
    chunks.push(chunk);
    if (!chunkTypes.exists(chunk.header.type))
      chunkTypes[chunk.header.type] = [chunk];
    else
      chunkTypes[chunk.header.type].push(chunk);
  }

  /**
    Access a cel at specific layer

    @param layerIndex Index of the layer
    @param replace Place this cel at a specific layer
   */
  public function cel(layerIndex:Int, ?replace:Cel):Cel {
    if (replace != null) {
      var existingCel = cels[layerIndex];
      if (existingCel != null) {
        removeChunk(existingCel.chunk);
      }

      addChunk(replace.chunk);
      cels[layerIndex] = replace;
      replace.layerIndex = layerIndex;
    }

    return cels[layerIndex];
  }

  /**
    Create Cel

    @param layerIndex Index of the layer to create new cel on
    @param width Cel width
    @param height Cel height
    @param xPosition Cel x position
    @param yPosition Cel y position
   */
  public function createCel(layerIndex:Int, width:Int, height:Int,
      ?xPosition:Int, ?yPosition:Int):Cel {
    var newCel = new Cel(this, layerIndex, width, height);

    if (xPosition != null)
      newCel.xPosition = xPosition;
    if (yPosition != null)
      newCel.yPosition = yPosition;

    addChunk(newCel.chunk);
    cels[layerIndex] = newCel;
    return newCel;
  }

  /**
    Create a linked cel 

    @param layerIndex 
    @param frameIndex
   */
  public function linkCel(layerIndex:Int, frameIndex:Int) {
    var newCel = new Cel(this, layerIndex);
    newCel.link(frameIndex);
    addChunk(newCel.chunk);
    cels[layerIndex] = newCel;
    return newCel;
  }

  public function clearCel(layerIndex:Int) {}

  public function createHeader() {
    header = new FrameHeader();
  }

  public function removeChunk(chunk:Chunk) {
    chunks.remove(chunk);
    chunkTypes[chunk.header.type].remove(chunk);
  }

  public function toBytes(?out:BytesOutput):Bytes {
    var bo = out != null ? out : new BytesOutput();

    header.size = size;
    header.numChunks = header.oldNumChunks = chunks.length;

    header.toBytes(bo);

    for (chunk in chunks) {
      chunk.toBytes(bo);
    }

    return bo.getBytes();
  }

  public function new(?header:FrameHeader, ?ase:Ase) {
    if (header != null)
      this.header = header;
    else
      this.header = new FrameHeader();

    if (ase != null)
      this.ase = ase;
  }
}
