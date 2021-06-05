package ase.chunks;

import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesInput;

class SliceKey {
  public var frameNumber:Int;
  public var xOrigin:Int32;
  public var yOrigin:Int32;
  public var width:Int32;
  public var height:Int32;
  public var xCenter:Int32;
  public var yCenter:Int32;
  public var centerWidth:Int32;
  public var centerHeight:Int32;
  public var xPivot:Int32;
  public var yPivot:Int32;

  public function new() {}
}

class SliceChunk extends Chunk {
  public var numSliceKeys:Int32;
  public var flags:Int32;
  public var reserved:Int32;
  public var name:String;
  public var sliceKeys:Array<SliceKey> = [];
  public var has9Slices:Bool;
  public var hasPivot:Bool;

  public static function fromBytes(bytes:Bytes):SliceChunk {
    var chunk = new SliceChunk();
    var bi = new BytesInput(bytes);

    chunk.numSliceKeys = bi.readInt32();
    chunk.flags = bi.readInt32();
    chunk.reserved = bi.readInt32();
    chunk.name = bi.readString(bi.readUInt16());

    for (_ in 0...chunk.numSliceKeys) {
      var sliceKey:SliceKey = new SliceKey();
      sliceKey.frameNumber = bi.readInt32();
      sliceKey.xOrigin = bi.readInt32();
      sliceKey.yOrigin = bi.readInt32();
      sliceKey.width = bi.readInt32();
      sliceKey.height = bi.readInt32();

      if (chunk.flags & (1 << 0) != 0) {
        chunk.has9Slices = true;
        sliceKey.xCenter = bi.readInt32();
        sliceKey.yCenter = bi.readInt32();
        sliceKey.centerWidth = bi.readInt32();
        sliceKey.centerHeight = bi.readInt32();
      }

      if (chunk.flags & (1 << 1) != 0) {
        chunk.hasPivot = true;
        sliceKey.xPivot = bi.readInt32();
        sliceKey.yPivot = bi.readInt32();
      }

      chunk.sliceKeys.push(sliceKey);
    }

    return chunk;
  }

  private function new(?createHeader:Bool = false) {
    super(createHeader, SLICE);
  }
}
