package ase.chunks;

import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

using Lambda;

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
  public var name:String;
  public var sliceKeys:Array<SliceKey> = [];
  public var has9Slices:Bool;
  public var hasPivot:Bool;

  override function getSizeWithoutHeader():Int {
    return 4 // numSliceKeys
      + 4 // flags
      + 4 // reserved
      + 2 // name string length
      + name.length
      + sliceKeys.map(key -> {
        var keySize:Int = 4 // frameNumber
          + 4 // xOrigin
          + 4 // yOrigin
          + 4 // width
          + 4; // height

        if (has9Slices) {
          keySize += 4 // xCenter
            + 4 // yCenter
            + 4 // centerWidth
            + 4; // centerHeight
        }

        if (hasPivot) {
          keySize += 4 // xPivot
            + 4; // yPivot
        }

        return keySize;
      }).fold((keySize:Int, result:Int) -> result + keySize, 0);
  }

  public static function fromBytes(bytes:Bytes):SliceChunk {
    var chunk = new SliceChunk();
    var bi = new BytesInput(bytes);

    chunk.numSliceKeys = bi.readInt32();
    chunk.flags = bi.readInt32();
    bi.readInt32(); // reserved
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

  override function toBytes(?out:BytesOutput):Bytes {
    var bo = out != null ? out : new BytesOutput();
    writeHeaderBytes(bo);

    bo.writeInt32(numSliceKeys);
    bo.writeInt32(flags);
    bo.writeInt32(0);
    bo.writeUInt16(name.length);
    bo.writeString(name);

    for (key in sliceKeys) {
      bo.writeInt32(key.frameNumber);
      bo.writeInt32(key.xOrigin);
      bo.writeInt32(key.yOrigin);
      bo.writeInt32(key.width);
      bo.writeInt32(key.height);

      if (flags & (1 << 0) != 0) {
        bo.writeInt32(key.xCenter);
        bo.writeInt32(key.yCenter);
        bo.writeInt32(key.centerWidth);
        bo.writeInt32(key.centerHeight);
      }

      if (flags & (1 << 1) != 0) {
        bo.writeInt32(key.xPivot);
        bo.writeInt32(key.yPivot);
      }
    }

    return bo.getBytes();
  }

  private function new(?createHeader:Bool = false) {
    super(createHeader, SLICE);
  }
}
