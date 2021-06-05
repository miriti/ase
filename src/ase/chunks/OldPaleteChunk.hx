package ase.chunks;

import haxe.io.Bytes;
import haxe.io.BytesInput;

typedef Packet = {
  skipEntries:Int,
  numColors:Int,
  colors:Array<{red:Int, green:Int, blue:Int}>
}

class OldPaleteChunk extends Chunk {
  public var numPackets:Int;
  public var packets:Array<Packet> = [];

  public static function fromBytes(bytes:Bytes):OldPaleteChunk {
    var chunk = new OldPaleteChunk();
    var bi = new BytesInput(bytes);

    chunk.numPackets = bi.readUInt16();

    for (_ in 0...chunk.numPackets) {
      var newPacket:Packet = {
        skipEntries: bi.readByte(),
        numColors: bi.readByte(),
        colors: []
      };

      for (_ in 0...newPacket.numColors) {
        newPacket.colors.push({
          red: bi.readByte(),
          green: bi.readByte(),
          blue: bi.readByte()
        });
      }

      chunk.packets.push(newPacket);
    }

    return chunk;
  }

  private function new(?createHeader:Bool = false) {
    super(createHeader, OLD_PALETTE_04);
  }
}
