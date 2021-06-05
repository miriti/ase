package ase;

import haxe.io.BytesOutput;
import haxe.io.Bytes;
import haxe.io.BytesInput;

class FrameHeader {
  public static final BYTE_SIZE:Int = 16;
  public static final MAGIC:Int = 0xF1FA;

  public var size:Int = 0;
  public var magic:Int = MAGIC;
  public var oldNumChunks:Int = 0;
  public var duration:Int = 100;
  public var reserved:Bytes;
  public var numChunks:Int = 0;

  public static function fromBytes(bytes:Bytes):FrameHeader {
    var header = new FrameHeader();
    var bi:BytesInput = new BytesInput(bytes);

    header.size = bi.readInt32();
    header.magic = bi.readUInt16();

    if (header.magic != MAGIC) {
      throw 'Invalid frame header magic number (should be 0xF1FA)';
    }

    header.oldNumChunks = bi.readUInt16();
    header.duration = bi.readUInt16();
    header.reserved = bi.read(2);
    header.numChunks = bi.readInt32();

    return header;
  }

  public function toBytes():Bytes {
    var bo = new BytesOutput();

    bo.writeInt32(size);
    bo.writeUInt16(magic);
    bo.writeUInt16(oldNumChunks);
    bo.writeUInt16(duration);
    for (_ in 0...2)
      bo.writeByte(0);
    bo.writeInt32(numChunks);

    return bo.getBytes();
  }

  public function new() {}
}
