package ase.chunks;

import haxe.io.BytesInput;
import haxe.zip.InflateImpl;
import haxe.io.Bytes;

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
  public var rawData:Bytes;
  public var compressedData:Bytes;

  public function new(header:ChunkHeader, chunkData:Bytes) {
    super(header, chunkData);

    layerIndex = bytesInput.readUInt16();
    xPosition = bytesInput.readInt16();
    yPosition = bytesInput.readInt16();
    opacity = bytesInput.readByte();
    celType = bytesInput.readUInt16();
    reserved = bytesInput.read(7);

    if (celType == CelType.RAW || celType == CelType.COMPRESSED_IMAGE) {
      width = bytesInput.readUInt16();
      height = bytesInput.readUInt16();

      var data:Bytes = bytesInput.read(bytesInput.length - bytesInput.position);

      if (celType == CelType.COMPRESSED_IMAGE) {
        compressedData = data;
        rawData = InflateImpl.run(new BytesInput(data));
      } else {
        rawData = data;
      }
    } else if (celType == CelType.LINKED) {
      linkedFrame = bytesInput.readUInt16();
    } else {
      throw 'Invalid cel type: ${celType}';
    }
  }
}
