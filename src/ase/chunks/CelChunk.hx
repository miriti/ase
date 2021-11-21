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
  public var bitsPerTile:Int;
  public var bitmaskTileId:Int;
  public var bitmaskXFlip:Int;
  public var bitmaskYFlip:Int;
  public var bitmask90CWRotation:Int;
  public var compressedTilemapData:Bytes;
  public var tilemapData:Bytes;

  override function getSizeWithoutHeader():Int {
    var totalSize:Int = 2 // layerIndex
      + 2 // xPosition
      + 2 // yPosition
      + 1 // opacity
      + 2 // celType
      + 7; // reserved

    if (celType == Raw || celType == CompressedImage
      || celType == CompressedTilemap) {
      totalSize += 2 // width
        + 2; // height

      if (celType == CompressedImage) {
        totalSize += compressedData.length;
      } else if (celType == Raw) {
        totalSize += rawData.length;
      } else if (celType == CompressedTilemap) {
        totalSize += 2 // Bits per tile
          + 4 // Bitmask for tile ID
          + 4 // Bitmask for X flip
          + 4 // Bitmask for Y flip
          + 4 // Bitmask for 90CW rotation
          + 10 // Reserved
          + compressedTilemapData.length;
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

    if (chunk.celType == Raw || chunk.celType == CompressedImage
      || chunk.celType == CompressedTilemap) {
      chunk.width = bi.readUInt16();
      chunk.height = bi.readUInt16();

      if (chunk.celType == CompressedImage) {
        chunk.compressedData = bi.read(bi.length - bi.position);
        chunk.rawData = InflateImpl.run(new BytesInput(chunk.compressedData));
      } else if (chunk.celType == Raw) {
        chunk.rawData = bi.read(bi.length - bi.position);
      } else if (chunk.celType == CompressedTilemap) {
        chunk.bitsPerTile = bi.readUInt16();
        chunk.bitmaskTileId = bi.readInt32();
        chunk.bitmaskXFlip = bi.readInt32();
        chunk.bitmaskYFlip = bi.readInt32();
        chunk.bitmask90CWRotation = bi.readInt32();
        bi.read(10); // reserved
        chunk.compressedTilemapData = bi.read(bi.length - bi.position);
        chunk.tilemapData = InflateImpl.run(new BytesInput(chunk.compressedTilemapData));
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
      case CompressedImage | Raw | CompressedTilemap:
        bo.writeUInt16(width);
        bo.writeUInt16(height);
        if (celType == CompressedImage) {
          bo.writeBytes(compressedData, 0, compressedData.length);
        } else if (celType == Raw) {
          bo.writeBytes(rawData, 0, rawData.length);
        } else if (celType == CompressedTilemap) {
          bo.writeUInt16(bitsPerTile);
          bo.writeInt32(bitmaskTileId);
          bo.writeInt32(bitmaskXFlip);
          bo.writeInt32(bitmaskYFlip);
          bo.writeInt32(bitmask90CWRotation);
          for (_ in 0...10)
            bo.writeByte(0);
          bo.writeBytes(compressedTilemapData, 0, compressedTilemapData.length);
        }
      case Linked:
        bo.writeUInt16(linkedFrame);
      case _:
    }

    return bo.getBytes();
  }

  public function compressData() {
    if (celType == CompressedImage)
      compressedData = Compress.run(rawData, 9);

    if (celType == CompressedTilemap)
      compressedTilemapData = Compress.run(tilemapData, 9);
  }

  public function new(?createHeader:Bool = false) {
    super(createHeader, CEL);
  }
}
