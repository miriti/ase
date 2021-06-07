package ase;

import ase.chunks.CelChunk;
import ase.types.CelType;
import haxe.io.Bytes;

using Std;

class Cel {
  var frame:Frame;

  public var chunk:CelChunk;

  /**
    Uncompressed Bytes representing pixels of the Cel.

    - 32 bit ARGB value per pixel for 32 bit color depth
    - 16 bit greyscale value 0x0000 = black, 0xffff = white
    - 8 bit index value per pixel for Indexed
   */
  public var pixelsData(get, never):Bytes;

  function get_pixelsData():Bytes {
    return chunk.rawData;
  }

  /**
    Required length of the data in bytes.
    Always equals to width x height x (bpp / 8)
   */
  public var pixelDataLength(get, never):Int;

  function get_pixelDataLength():Int {
    return width * height * (frame.ase.colorDepth / 8).int();
  }

  public var width(get, never):Int;

  function get_width():Int
    return chunk.width;

  public var height(get, never):Int;

  function get_height():Int
    return chunk.height;

  public var layerIndex(get, set):Int;

  function get_layerIndex():Int
    return chunk.layerIndex;

  function set_layerIndex(val:Int)
    return chunk.layerIndex = val;

  public var xPosition(get, set):Int;

  function get_xPosition():Int
    return chunk.xPosition;

  function set_xPosition(val:Int)
    return chunk.xPosition = val;

  public var yPosition(get, set):Int;

  function get_yPosition():Int
    return chunk.yPosition;

  function set_yPosition(val:Int)
    return chunk.yPosition = val;

  /**
    Initalize Cel pixel data

    @param width
    @param height
   */
  public function init(width:Int, height:Int) {
    if (chunk.celType != Linked) {
      chunk.width = width;
      chunk.height = height;

      chunk.rawData = Bytes.alloc(pixelDataLength);
      if (chunk.celType == CompressedImage)
        chunk.compressData();
    } else
      throw "Can't initalize pixel data for a linked cel";
  }

  public function fillColor(argb:Int) {
    for (n in 0...(width * height)) {
      chunk.rawData.setInt32(n * 4, argb);
    }

    if (chunk.celType == CompressedImage)
      chunk.compressData();
  }

  public function fillIndex(index:Int) {
    chunk.rawData.fill(0, chunk.rawData.length, index);
    if (chunk.celType == CompressedImage)
      chunk.compressData();
  }

  public function link(frameIndex:Int) {
    chunk.celType = Linked;
    chunk.linkedFrame = frameIndex;
  }

  public function clone():Cel {
    return new Cel(chunk.clone(), frame, layerIndex);
  }

  public function new(?chunk:CelChunk, ?celType:CelType, frame:Frame,
      layerIndex:Int, ?width:Int, ?height:Int) {
    if (chunk == null)
      this.chunk = new CelChunk(true);
    else
      this.chunk = chunk;

    if (celType != null)
      chunk.celType = celType;

    this.frame = frame;
    this.layerIndex = layerIndex;

    if ((celType != Linked) && (width != null && height != null))
      init(width, height);
  }
}
