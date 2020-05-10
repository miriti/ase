package ase;

import haxe.io.BytesInput;
import haxe.io.Bytes;

@:expose('Ase')
class Ase {
  public var header:AseHeader;
  public var frames:Array<Frame> = [];

  public static function fromBytes(bytes:Bytes):Ase {
    return fromBytesInput(new BytesInput(bytes));
  }

  public static function fromBytesInput(bytesInput:BytesInput):Ase {
    var aseprite:Ase = new Ase();

    aseprite.header = new AseHeader(bytesInput.read(128));
    for (frameNum in 0...aseprite.header.frames) {
      var frameHeader:FrameHeader = new FrameHeader(bytesInput.read(FrameHeader.BYTE_SIZE));
      var frame:Frame = new Frame(frameHeader,
        bytesInput.read(frameHeader.size - FrameHeader.BYTE_SIZE));
      aseprite.frames.push(frame);
    }

    return aseprite;
  }

  public static function main() {}

  public function new() {}
}
