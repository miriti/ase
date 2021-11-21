package ase.chunks;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

class ExternalFilesChunk extends Chunk {
  public var numEntries:Int;
  public var entries:Array<{id:Int, fileName:String}> = [];

  override function getSizeWithoutHeader():Int {
    final size = 4 // numEntries
      + 8; // reserved

    for (entry in entries) {
      size += 4 // id
        + 8 // reserved
        + 1 // fileName length
        + entry.fileName.length;
    }

    return size;
  }

  public static function fromBytes(bytes:Bytes):ExternalFilesChunk {
    final chunk = new ExternalFilesChunk();
    final bi = new BytesInput(bytes);

    chunk.numEntries = bi.readInt32();
    bi.read(8); // reserved

    for (_ in 0...chunk.numEntries) {
      final id = bi.readInt32();
      bi.read(8); // reserved
      final fileName = bi.readString(bi.readByte());

      chunk.entries.push({id: id, fileName: fileName});
    }

    return chunk;
  }

  override function toBytes(?out:BytesOutput):Bytes {
    var bo = out != null ? out : new BytesOutput();

    bo.writeInt32(numEntries);
    for (_ in 0...8)
      bo.writeByte(0);

    for (entry in entries) {
      bo.writeInt32(entry.id);
      for (_ in 0...8)
        bo.writeByte(0);
      bo.writeByte(entry.fileName.length);
      bo.writeString(entry.fileName);
    }

    return bo.getBytes();
  }

  public function new(?createHeader:Bool = false) {
    super(createHeader, EXTERNAL_FILES);
  }
}
