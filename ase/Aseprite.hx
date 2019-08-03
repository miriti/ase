package ase;

import haxe.io.BytesInput;
import haxe.io.Bytes;

class Aseprite {
  public var header:AseHeader;
  public var frames:Array<Frame> = [];

  public function new(data:Bytes) {
    var bytesInput:BytesInput = new BytesInput(data);

    header = new AseHeader(bytesInput.read(128));

    for (frameNum in 0...header.frames) {
      var frameHeader:FrameHeader = new FrameHeader(bytesInput.read(FrameHeader.BYTE_SIZE));
      var frame:Frame = new Frame(frameHeader, bytesInput.read(frameHeader.size - FrameHeader.BYTE_SIZE));
      frames.push(frame);
    }
  }
}
