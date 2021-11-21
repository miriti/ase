package ase.chunks;

import ase.types.Serializable;
import ase.types.ChunkType;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

using Type;

class Chunk implements Serializable {
  public var header:ChunkHeader;
  public var userData:UserDataChunk;

  public var size(get, never):Int;

  function get_size():Int {
    return ChunkHeader.BYTE_SIZE + getSizeWithoutHeader();
  }

  function getSizeWithoutHeader():Int {
    throw '${Type.getClassName(Type.getClass(this))}.getSizeWithoutHeader() is not implemented';
  }

  public static function fromBytes(bytes:Bytes):Chunk {
    var bi = new BytesInput(bytes);

    var header:ChunkHeader = ChunkHeader.fromBytes(bi.read(ChunkHeader.BYTE_SIZE));
    var chunkBytes:Bytes = bi.read(header.size - ChunkHeader.BYTE_SIZE);

    var chunk:Chunk = switch (cast(header.type, ChunkType)) {
      case CEL:
        CelChunk.fromBytes(chunkBytes);
      case CEL_EXTRA:
        CelExtraChunk.fromBytes(chunkBytes);
      case COLOR_PROFILE:
        ColorProfileChunk.fromBytes(chunkBytes);
      case EXTERNAL_FILES:
        ExternalFilesChunk.fromBytes(chunkBytes);
      case LAYER:
        LayerChunk.fromBytes(chunkBytes);
      case MASK:
        MaskChunk.fromBytes(chunkBytes);
      case OLD_PALETTE_04 | OLD_PALETTE_11:
        OldPaleteChunk.fromBytes(chunkBytes);
      case PALETTE:
        PaletteChunk.fromBytes(chunkBytes);
      case SLICE:
        SliceChunk.fromBytes(chunkBytes);
      case TAGS:
        TagsChunk.fromBytes(chunkBytes);
      case USER_DATA:
        UserDataChunk.fromBytes(chunkBytes);
      case TILESET:
        TilesetChunk.fromBytes(chunkBytes);
      case _:
        trace('Unknown chunk type: 0x${StringTools.hex(header.type, 4)}');
        return null;
    }

    if (chunk != null)
      chunk.header = header;

    return chunk;
  }

  function writeHeaderBytes(out:BytesOutput) {
    header.size = size;
    header.toBytes(out);
  }

  public function toBytes(?out:BytesOutput):Bytes {
    throw '${this.getClass().getClassName().split('.').pop()}.toBytes() is not implemented';
  }

  private function new(?createHeader:Bool = false, ?type:ChunkType) {
    if (createHeader) {
      header = new ChunkHeader(type);
    }
  }
}
