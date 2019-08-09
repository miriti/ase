package ase.chunks;

import haxe.io.BytesInput;
import haxe.io.Bytes;

class CelType {
  public static inline var RAW:Int = 0;
  public static inline var LINKED:Int = 1;
  public static inline var COMPRESSED:Int = 2;
}

class CelChunk extends Chunk {
  public var layerIndex:Int;
  public var xPosition:Int;
  public var yPosition:Int;
  public var opacity:Int;
  public var celType:Int;
  public var reserved:Bytes;
  public var width:Int;
  public var height:Int;
  public var linkedFrame:Int;
  public var extra:CelExtraChunk;

  public function new(header:ChunkHeader, chunkData:Bytes) {
    super(header, chunkData);

    layerIndex = bytesInput.readUInt16();
    xPosition = bytesInput.readInt16();
    yPosition = bytesInput.readInt16();
    opacity = bytesInput.readByte();
    celType = bytesInput.readUInt16();
    reserved = bytesInput.read(7);

    if (celType == CelType.RAW || celType == CelType.COMPRESSED) {
      width = bytesInput.readUInt16();
      height = bytesInput.readUInt16();
    } else if (celType == CelType.LINKED) {
      linkedFrame = bytesInput.readUInt16();
    } else {
      throw 'Invalid cel type: ${celType}';
    }
  }
}
