package ase;

import ase.chunks.ColorProfileChunk;
import ase.types.ColorDepth;
import ase.types.Serializable;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

using Lambda;

/**
  Aseprite file format reader/writer
 */
@:expose('Ase') class Ase implements Serializable {
  public var header:AseHeader;
  public var frames:Array<Frame> = [];

  /**
    Read-only color depth of the file
   */
  public var colorDepth(get, never):ColorDepth;

  function get_colorDepth():ColorDepth {
    return header.colorDepth;
  }

  /**
    Files size in bytes
   */
  public var fileSize(get, never):Int;

  function get_fileSize():Int {
    return header.size
      + frames.fold((frame:Frame, result:Int) -> result + frame.size, 0);
  }

  /**
    Sprite width
   */
  public var width(get, set):Int;

  function get_width():Int
    return header.width;

  function set_width(val:Int) {
    return header.width = val;
  }

  /**
    Sprite height
   */
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

  /**
    Create a new Ase instance by parsing bytes loaded from a file or network

    @param bytes bytes to parse
   */
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

  /**
    Initialize the pallet

    @param colors Array of RGBA color values for the new pallet
   */
  public function initPalette(colors:Array<Int>) {
    palette = new Palette(colors);
    frames[0].addChunk(palette.chunk);
  }

  /**
    Add a frame to the sprite

    @param copyPrev if true will copy all the cel from the previous frame
    @param duration Duration of the frame in milliseconds
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

    @param name (optional) Name for the new layer. If not specified `Layer N`
                will be used where `N` is the amount of currently existing layers + 1
    @param visible (optional, default `true`)
    @param editable (optional, default `true`)
   */
  public function addLayer(?name:String, ?visible:Bool = true,
      ?editable:Bool = true) {
    if (name == null)
      name = 'Layer ${layers.length + 1}';

    var layer = new Layer();
    layer.editable = editable;
    layer.visible = visible;
    layer.name = name;

    frames[0].addChunk(layer.chunk);
    return this;
  }

  public function toBytes(?out:BytesOutput):Bytes {
    header.fileSize = fileSize;
    header.frames = frames.length;

    var bo = out != null ? out : new BytesOutput();

    header.toBytes(bo);

    for (frame in frames) {
      frame.toBytes(bo);
    }

    return bo.getBytes();
  }

  public static function main() {}

  private function new() {}
}
