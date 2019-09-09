package ase;

import haxe.io.BytesInput;
import haxe.io.Bytes;

@:expose('Aseprite')
class Aseprite {
  public var header:AseHeader;
  public var frames:Array<Frame> = [];

  public static function fromBytes(bytes:Bytes):Aseprite {
    return fromBytesInput(new BytesInput(bytes));
  }

  public static function fromBytesInput(bytesInput:BytesInput):Aseprite {
    var aseprite:Aseprite = new Aseprite();

    aseprite.header = new AseHeader(bytesInput.read(128));
    for (frameNum in 0...aseprite.header.frames) {
      var frameHeader:FrameHeader = new FrameHeader(bytesInput.read(FrameHeader.BYTE_SIZE));
      var frame:Frame = new Frame(frameHeader, bytesInput.read(frameHeader.size - FrameHeader.BYTE_SIZE));
      aseprite.frames.push(frame);
    }

    return aseprite;
  }

  public static function main() {}

  public function new() {}
}
