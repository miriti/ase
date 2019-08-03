package ase.chunks;

import haxe.io.Bytes;

class LayerChunk extends Chunk {
  public var flags:Int;
  public var layerType:Int;
  public var childLevel:Int;
  public var defaultWidth:Int;
  public var defaultHeight:Int;
  public var blendMode:Int;
  public var opacity:Int;
  public var reserved:Bytes;
  public var name:String;

  public function new(header:ChunkHeader, chunkData:Bytes) {
    super(header, chunkData);

    flags = bytesInput.readUInt16();
    layerType = bytesInput.readInt16();
    childLevel = bytesInput.readInt16();
    defaultWidth = bytesInput.readInt16();
    defaultWidth = bytesInput.readInt16();
    blendMode = bytesInput.readInt16();
    opacity = bytesInput.readByte();
    reserved = bytesInput.read(3);
    // name = bytesInput.readUntil(0);
  }
}
