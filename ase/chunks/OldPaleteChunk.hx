package ase.chunks;

import haxe.io.Bytes;

typedef Packet = {
  skipEntries:Int,
  numColors:Int,
  colors:Array<{red:Int, green:Int, blue:Int}>
}

class OldPaleteChunk extends Chunk {
  public var numPackets:Int;
  public var packets:Array<Packet> = [];

  public function new(header:ChunkHeader, chunkData:Bytes) {
    super(header, chunkData);

    numPackets = bytesInput.readUInt16();

    for (packetIndex in 0...numPackets) {
      var newPacket:Packet = {
        skipEntries: bytesInput.readByte(),
        numColors: bytesInput.readByte(),
        colors: []
      };

      for (colorIndex in 0...newPacket.numColors) {
        newPacket.colors.push({
          red: bytesInput.readByte(),
          green: bytesInput.readByte(),
          blue: bytesInput.readByte()
        });
      }

      packets.push(newPacket);
    }
  }
}
