package ase.chunks;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.zip.InflateImpl;

class TilesetChunk extends Chunk {
  public var id:Int;
  public var flags:Int;
  public var numTiles:Int;
  public var width:Int;
  public var height:Int;
  public var baseIndex:Int;
  public var reserved:Bytes;
  public var name:String;
  public var externalFileID:Int;
  public var externalTilesetID:Int;
  public var compressedDataLength:Int;
  public var compressedTilesetImage:Bytes;

  public var uncompressedTilesetImage:Bytes;

  override function getSizeWithoutHeader():Int {
    var size = 4 // id
      + 4 // flags
      + 4 // numTiles
      + 2 // width
      + 2 // height
      + 2 // baseIndex
      + 14 // reserved
      + 2 // name length
      + name.length;

    if (flags == 1) {
      size += 4 // External File ID
        + 4; // External Tileset ID
    }

    if (flags == 2) {
      size += 4 // compressed tileset image size
        + compressedTilesetImage.length;
    }

    return size;
  }

  public static function fromBytes(bytes:Bytes):TilesetChunk {
    final chunk = new TilesetChunk();
    final bi = new BytesInput(bytes);

    chunk.id = bi.readInt32();
    chunk.flags = bi.readInt32();
    chunk.numTiles = bi.readInt32();
    chunk.width = bi.readUInt16();
    chunk.height = bi.readUInt16();
    chunk.baseIndex = bi.readUInt16();
    bi.read(14); // Ignore 14 reserved bytes
    chunk.name = bi.readString(bi.readUInt16());

    if (chunk.flags & (1 << 0) != 0) {
      chunk.externalFileID = bi.readInt32();
      chunk.externalTilesetID = bi.readInt32();
    }

    if (chunk.flags & (1 << 2) != 0) {
      chunk.compressedDataLength = bi.readInt32();
      chunk.compressedTilesetImage = Bytes.alloc(chunk.compressedDataLength);
      bi.readBytes(chunk.compressedTilesetImage, 0, chunk.compressedDataLength);

      chunk.uncompressedTilesetImage = InflateImpl.run(new BytesInput(chunk.compressedTilesetImage));
    }

    return chunk;
  }

  override function toBytes(?out:BytesOutput):Bytes {
    final bo = out != null ? out : new BytesOutput();

    bo.writeInt32(id);
    bo.writeInt32(flags);
    bo.writeInt32(numTiles);
    bo.writeUInt16(width);
    bo.writeUInt16(height);
    bo.writeUInt16(baseIndex);
    for (_ in 0...14) // 14 reserved bytes set to 0
      bo.writeByte(0);
    bo.writeUInt16(name.length);
    bo.writeString(name);

    if (flags == 1) {
      bo.writeInt32(externalFileID);
      bo.writeInt32(externalTilesetID);
    }

    if (flags == 2) {
      bo.writeInt32(compressedDataLength);
      bo.writeBytes(compressedTilesetImage, 0, compressedDataLength);
    }

    return bo.getBytes();
  }

  public function new(?createHeader:Bool = false) {
    super(createHeader, TILESET);
  }
}
