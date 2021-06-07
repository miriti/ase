package ase;

import ase.chunks.ColorProfileChunk;
import ase.types.ColorDepth;
import ase.types.LayerPosition;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

using Lambda;

@:expose('Ase')
class Ase {
  public var header:AseHeader;
  public var frames:Array<Frame> = [];

  public var colorDepth(get, never):ColorDepth;

  function get_colorDepth():ColorDepth {
    return header.colorDepth;
  }

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

  public var palette:Palette;

  public final layers:Array<Layer> = [];

  /**
    Create a new Ase instance

    @param width File width
    @param height File height
    @param colorDepth (optional, default BPP32) color depth. BPP32, BPP16, BPP8 or INDEXED 
    @param initialPalette (optional) Array of RGBA values for initial palette
   */
  public static function create(width:Int, height:Int,
      ?colorDepth:ColorDepth = BPP32, ?initialPalette:Array<Int>):Ase {
    var ase = new Ase();
    ase.createHeader();
    ase.header.colorDepth = colorDepth;
    ase.width = width;
    ase.height = height;
    ase.createFirstFrame();

    if (colorDepth == INDEXED || initialPalette != null) {
      ase.initPalette(initialPalette != null ? initialPalette : Palette.DB32);
    }

    return ase;
  }

  public static function fromBytes(bytes:Bytes):Ase {
    var bi = new BytesInput(bytes);
    var ase:Ase = new Ase();

    ase.header = AseHeader.fromBytes(bi.read(AseHeader.SIZE));
    for (_ in 0...ase.header.frames) {
      var frameSize:Int = bytes.getInt32(bi.position);
      var frame = Frame.fromBytes(bi.read(frameSize), ase);
      ase.frames.push(frame);
    }

    return ase;
  }

  function createHeader() {
    header = new AseHeader();
  }

  function createFirstFrame() {
    var firstFrame = new Frame(this);
    firstFrame.createHeader();
    firstFrame.addChunk(new ColorProfileChunk(true));
    frames = [firstFrame];
  }

  public function initPalette(colors:Array<Int>) {
    palette = new Palette(colors);
    frames[0].addChunk(palette.chunk);
  }

  /**
    Add a frame to the sprite

    @param copyPrev if true will copy all the cel from the previous frame
   */
  public function addFrame(?copyPrev:Bool = false, ?duration:Int = 100) {
    var newFrame = new Frame(this);
    newFrame.duration = duration;

    if (copyPrev) {
      var prevFrame = frames[frames.length - 1];
      for (index in 0...layers.length) {
        var cel = prevFrame.cel(index);
        if (cel != null)
          newFrame.cel(index, cel);
      }
    }

    frames.push(newFrame);

    return newFrame;
  }

  /**
    Create a new layer
   */
  public function addLayer(?name:String, ?position:LayerPosition = TOP,
      ?visible:Bool = true, ?editable:Bool = true) {
    if (name == null)
      name = 'Layer ${layers.length + 1}';

    var layer = new Layer();
    layer.editable = editable;
    layer.visible = visible;
    layer.name = name;

    var desiredIndex:Int = switch (position) {
      case TOP: 0;
      case BOTTOM: layers.length;
      case INDEX(index):
        index;
    }

    frames[0].addChunk(layer.chunk);
    return this;
  }

  public function toBytes():Bytes {
    header.fileSize = fileSize;
    header.frames = frames.length;

    var bo = new BytesOutput();
    var headerBytes = header.toBytes();

    bo.writeBytes(headerBytes, 0, headerBytes.length);

    for (frame in frames) {
      var frameBytes = frame.toBytes();
      bo.writeBytes(frameBytes, 0, frameBytes.length);
    }

    return bo.getBytes();
  }

  public static function main() {}

  private function new() {}
}
