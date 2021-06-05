package ase;

import ase.types.ColorDepth;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

using Lambda;

@:expose('Ase')
class Ase {
  public var header:AseHeader;
  public var frames:Array<Frame> = [];

  /**
    Get files size in bytes
   */
  public var fileSize(get, never):Int;

  function get_fileSize():Int {
    return header.size
      + frames.fold((frame:Frame, result:Int) -> result + frame.size, 0);
  }

  public var width(get, set):Int;

  function get_width():Int
    return header.width;

  function set_width(val:Int) {
    return header.width = val;
  }

  public var height(get, set):Int;

  function get_height():Int
    return header.height;

  function set_height(val:Int) {
    return header.height = val;
  }

  /**
    Create a new Ase instance

    @param width
    @param height
    @param colorDepth
   */
  public static function create(width:Int, height:Int,
      colorDepth:ColorDepth = BPP32):Ase {
    var ase = new Ase();
    ase.createHeader();
    ase.header.colorDepth = colorDepth;
    ase.width = width;
    ase.height = height;
    ase.frames.push(Frame.createFirstFrame());
    return ase;
  }

  public static function fromBytes(bytes:Bytes):Ase {
    var bi = new BytesInput(bytes);
    var ase:Ase = new Ase();

    ase.header = AseHeader.fromBytes(bi.read(AseHeader.SIZE));
    for (_ in 0...ase.header.frames) {
      var frameSize:Int = bytes.getInt32(bi.position);
      var frame = Frame.fromBytes(bi.read(frameSize));
      ase.frames.push(frame);
    }

    return ase;
  }

  public function createHeader() {
    header = new AseHeader();
  }

  public function toBytes():Bytes {
    trace('File Size: $fileSize');

    header.fileSize = fileSize;
    header.frames = frames.length;

    var bo = new BytesOutput();
    var headerBytes = header.toBytes();
    bo.writeBytes(headerBytes, 0, headerBytes.length);

    for (frame in frames) {}

    return bo.getBytes();
  }

  public static function main() {}

  private function new() {}
}
