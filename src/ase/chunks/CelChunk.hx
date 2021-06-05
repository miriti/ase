package ase.chunks;

import ase.types.CelType;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.InflateImpl;

class CelChunk extends Chunk {
  public var layerIndex:Int;
  public var xPosition:Int;
  public var yPosition:Int;
  public var opacity:Int;
  public var celType:CelType;
  public var reserved:Bytes;
  public var width:Int;
  public var height:Int;
  public var linkedFrame:Int;
  public var extra:CelExtraChunk;
  public var rawData:Bytes;
  public var compressedData:Bytes;

  public static function fromBytes(bytes:Bytes):CelChunk {
    var chunk = new CelChunk();
    var bi = new BytesInput(bytes);

    chunk.layerIndex = bi.readUInt16();
    chunk.xPosition = bi.readInt16();
    chunk.yPosition = bi.readInt16();
    chunk.opacity = bi.readByte();
    chunk.celType = bi.readUInt16();
    chunk.reserved = bi.read(7);

    if (chunk.celType == CelType.Raw
      || chunk.celType == CelType.CompressedImage) {
      chunk.width = bi.readUInt16();
      chunk.height = bi.readUInt16();

      var data:Bytes = bi.read(bi.length - bi.position);

      if (chunk.celType == CelType.CompressedImage) {
        chunk.compressedData = data;
        chunk.rawData = InflateImpl.run(new BytesInput(data));
      } else {
        chunk.rawData = data;
      }
    } else if (chunk.celType == CelType.Linked) {
      chunk.linkedFrame = bi.readUInt16();
    } else {
      throw 'Invalid cel type: ${chunk.celType}';
    }

    return chunk;
  }

  private function new(?createHeader:Bool = false) {
    super(createHeader, CEL);
  }
}
