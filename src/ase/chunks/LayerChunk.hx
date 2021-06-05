package ase.chunks;

import haxe.io.Bytes;
import haxe.io.BytesInput;

@:enum abstract LayerFlags(Int) from Int to Int {
  var Visible = 1;
  var Editable = 2;
  var LockMovement = 4;
  var Background = 8;
  var PreferLinkedCels = 16;
  var Collapsed = 32;
  var Reference = 64;
}

@:enum abstract LayerType(Int) from Int to Int {
  var Normal = 0;
  var Group = 1;
}

@:enum abstract LayerBlendMode(Int) from Int to Int {
  var Normal = 0;
  var Multiply = 1;
  var Screen = 2;
  var Overlay = 3;
  var Darken = 4;
  var Lighten = 5;
  var ColorDodge = 6;
  var ColorBurn = 7;
  var HardLight = 8;
  var SoftLight = 9;
  var Difference = 10;
  var Exclusion = 11;
  var Hue = 12;
  var Saturation = 13;
  var Color = 14;
  var Luminosity = 15;
  var Addition = 16;
  var Subtract = 17;
  var Divide = 18;
}

class LayerChunk extends Chunk {
  public var flags:LayerFlags = Visible | Editable;
  public var layerType:LayerType = Normal;
  public var childLevel:Int = 0;
  public var defaultWidth:Int = 0;
  public var defaultHeight:Int = 0;
  public var blendMode:LayerBlendMode = Normal;
  public var opacity:Int = 255;
  public var reserved:Bytes;
  public var name:String = 'New Layer';

  public static function fromBytes(bytes:Bytes):LayerChunk {
    var chunk = new LayerChunk();
    var bi = new BytesInput(bytes);

    chunk.flags = bi.readUInt16();
    chunk.layerType = bi.readInt16();
    chunk.childLevel = bi.readInt16();
    chunk.defaultWidth = bi.readInt16();
    chunk.defaultHeight = bi.readInt16();
    chunk.blendMode = bi.readInt16();
    chunk.opacity = bi.readByte();
    chunk.reserved = bi.read(3);
    chunk.name = bi.readString(bi.readUInt16());

    return chunk;
  }

  public function new(?createHeader:Bool = false) {
    super(createHeader, LAYER);
  }
}
