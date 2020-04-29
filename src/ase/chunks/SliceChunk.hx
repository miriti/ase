package ase.chunks;

import haxe.Int32;
import haxe.io.Bytes;

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

  public function new(header:ChunkHeader, chunkData:Bytes) {
    super(header, chunkData);

    numSliceKeys = bytesInput.readInt32();
    flags = bytesInput.readInt32();
    reserved = bytesInput.readInt32();
    name = bytesInput.readString(bytesInput.readUInt16());

    for (n in 0...numSliceKeys) {
      var sliceKey:SliceKey = new SliceKey();
      sliceKey.frameNumber = bytesInput.readInt32();
      sliceKey.xOrigin = bytesInput.readInt32();
      sliceKey.yOrigin = bytesInput.readInt32();
      sliceKey.width = bytesInput.readInt32();
      sliceKey.height = bytesInput.readInt32();

      if (flags & (1 << 0) != 0) {
        has9Slices = true;
        sliceKey.xCenter = bytesInput.readInt32();
        sliceKey.yCenter = bytesInput.readInt32();
        sliceKey.centerWidth = bytesInput.readInt32();
        sliceKey.centerHeight = bytesInput.readInt32();
      }

      if (flags & (1 << 1) != 0) {
        hasPivot = true;
        sliceKey.xPivot = bytesInput.readInt32();
        sliceKey.yPivot = bytesInput.readInt32();
      }

      sliceKeys.push(sliceKey);
    }
  }
}
