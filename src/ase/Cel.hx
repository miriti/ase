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
  public var pixelData(get, never):Bytes;

  function get_pixelData():Bytes {
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

  /**
    Cel width
   */
  public var width(get, never):Int;

  function get_width():Int
    return chunk.width;

  /**
    Cel height
   */
  public var height(get, never):Int;

  function get_height():Int
    return chunk.height;

  /**
    Layer index
   */
  public var layerIndex(get, set):Int;

  function get_layerIndex():Int
    return chunk.layerIndex;

  function set_layerIndex(val:Int)
    return chunk.layerIndex = val;

  /**
    Cel x position
   */
  public var xPosition(get, set):Int;

  function get_xPosition():Int
    return chunk.xPosition;

  function set_xPosition(val:Int)
    return chunk.xPosition = val;

  /**
    Cel y position
   */
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

      setPixelData(Bytes.alloc(pixelDataLength));
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

  /**
    Get pixel color or color index at given position
   */
  public function getPixel(px:Int, py:Int):Null<Int> {
    if (px >= 0 && px < width && py >= 0 && py < height) {
      var p = (width * py + px) * (frame.ase.colorDepth / 8).int();
      return switch (frame.ase.colorDepth) {
        case BPP32: pixelData.getInt32(p);
        case BPP16: pixelData.getUInt16(p);
        case INDEXED: pixelData.get(p);
      };
    } else
      return null;
  }

  /**
    Set pixel color or color index at given position

    @param px x 
    @param py y
    @param color ARGB color for 32bpp mode, GGGG color for 16bpp mode and index or GG color for Indexed or 8bpp mode
   */
  public function setPixel(px:Int, py:Int, color:Int) {
    if (px >= 0 && px < width && py >= 0 && py < height) {
      var p = (width * py + px) * (frame.ase.colorDepth / 8).int();
      switch (frame.ase.colorDepth) {
        case BPP32:
          pixelData.setInt32(p, color);
        case BPP16:
          pixelData.setUInt16(p, color);
        case INDEXED:
          pixelData.set(p, color);
      };
      setPixelData(pixelData);
    }
  }

  /**
    Set new pixel data
   */
  public function setPixelData(newData:Bytes, ?newWidth:Int, ?newHeight:Int) {
    if (newWidth == null || newHeight == null) {
      newWidth = width;
      newHeight = height;
    }

    if (newData.length != (newWidth * newHeight * (frame.ase.colorDepth / 8)
      .int()))
      throw 'Invalid data size';

    chunk.rawData = newData;
    chunk.width = newWidth;
    chunk.height = newHeight;
    if (chunk.celType == CompressedImage)
      chunk.compressData();
  }

  /**
    Make this cel linked to the one located at frameIndex on the same layer

    @param frameIndex Index of the frame with the cel to link to
   */
  public function link(frameIndex:Int) {
    chunk.celType = Linked;
    chunk.linkedFrame = frameIndex;
  }

  /**
    Create a new identical cel
   */
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
