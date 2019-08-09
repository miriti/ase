package ase;

import haxe.io.BytesInput;
import haxe.io.Bytes;

class FrameHeader {
  public static inline var BYTE_SIZE:Int = 16;

  public var size:Int;
  public var magic:Int;
  public var oldNumChunks:Int;
  public var duration:Int;
  public var reserved:Bytes;
  public var numChunks:Int;

  public function new(headerData:Bytes) {
    var bytesInput:BytesInput = new BytesInput(headerData);
    size = bytesInput.readInt32();
    magic = bytesInput.readUInt16();

    if (magic != 0xF1FA) {
      throw 'Invalid frame header magic number (should be 0xF1FA)';
    }

    oldNumChunks = bytesInput.readUInt16();
    duration = bytesInput.readUInt16();

    reserved = bytesInput.read(2);

    numChunks = bytesInput.readInt32();
  }
}
