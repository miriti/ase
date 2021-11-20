package ase.chunks;

import ase.types.CelType;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.zip.Compress;
import haxe.zip.InflateImpl;

class CelChunk extends Chunk {
  public var layerIndex:Int = 0;
  public var xPosition:Int = 0;
  public var yPosition:Int = 0;
  public var opacity:Int = 255;
  public var celType:CelType = CompressedImage;
  public var width:Int = 0;
  public var height:Int = 0;
  public var linkedFrame:Int;
  public var extra:CelExtraChunk;
  public var rawData:Bytes;
  public var compressedData:Bytes;

  override function getSizeWithoutHeader():Int {
    var totalSize:Int = 2 // layerIndex
      + 2 // xPosition
      + 2 // yPosition
      + 1 // opacity
      + 2 // celType
      + 7; // reserved

    if (celType == Raw || celType == CompressedImage) {
      totalSize += 2 // width
        + 2; // height

      if (celType == CompressedImage) {
        totalSize += compressedData.length;
      } else {
        totalSize += rawData.length;
      }
    } else if (celType == Linked) {
      totalSize += 2; // two bytes for linkedFrame
    }

    return totalSize;
  }

  public static function fromBytes(bytes:Bytes):CelChunk {
    var chunk = new CelChunk();
    var bi = new BytesInput(bytes);

    chunk.layerIndex = bi.readUInt16();
    chunk.xPosition = bi.readInt16();
    chunk.yPosition = bi.readInt16();
    chunk.opacity = bi.readByte();
    chunk.celType = bi.readUInt16();
    bi.read(7);

    if (chunk.celType == Raw || chunk.celType == CompressedImage) {
      chunk.width = bi.readUInt16();
      chunk.height = bi.readUInt16();

      var data:Bytes = bi.read(bi.length - bi.position);

      if (chunk.celType == CompressedImage) {
        chunk.compressedData = data;
        chunk.rawData = InflateImpl.run(new BytesInput(data));
      } else {
        chunk.rawData = data;
      }
    } else if (chunk.celType == Linked) {
      chunk.linkedFrame = bi.readUInt16();
    } else {
      trace('Unknown cel type: ${chunk.celType}');
      return null;
    }

    return chunk;
  }

  public function clone():CelChunk {
    var clonedChunk = new CelChunk(true);
    clonedChunk.layerIndex = layerIndex;
    clonedChunk.xPosition = xPosition;
    clonedChunk.yPosition = yPosition;
    clonedChunk.opacity = opacity;
    clonedChunk.celType = celType;
    clonedChunk.width = width;
    clonedChunk.height = height;
    clonedChunk.linkedFrame = linkedFrame;
    if (extra != null)
      clonedChunk.extra = extra.clone();
    if (celType != Linked) {
      if (rawData != null) {
        clonedChunk.rawData = Bytes.alloc(rawData.length);
        clonedChunk.rawData.blit(0, rawData, 0, rawData.length);
      }

      if (compressedData != null) {
        clonedChunk.compressedData = Bytes.alloc(compressedData.length);
        clonedChunk.compressedData.blit(0, compressedData, 0,
          compressedData.length);
      }
    }
    return clonedChunk;
  }

  override function toBytes(?out:BytesOutput):Bytes {
    var bo = out != null ? out : new BytesOutput();

    writeHeaderBytes(bo);

    bo.writeUInt16(layerIndex);
    bo.writeInt16(xPosition);
    bo.writeInt16(yPosition);
    bo.writeByte(opacity);
    bo.writeUInt16(celType);
    for (_ in 0...7)
      bo.writeByte(0);

    switch (celType) {
      case CompressedImage | Raw:
        bo.writeUInt16(width);
        bo.writeUInt16(height);
        if (celType == CompressedImage) {
          bo.writeBytes(compressedData, 0, compressedData.length);
        } else {
          bo.writeBytes(rawData, 0, rawData.length);
        }
      case Linked:
        bo.writeUInt16(linkedFrame);
      case _:
    }

    return bo.getBytes();
  }

  public function compressData() {
    compressedData = Compress.run(rawData, 9);
  }

  public function new(?createHeader:Bool = false) {
    super(createHeader, CEL);
  }
}
