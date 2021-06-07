package ase;

import ase.chunks.LayerChunk;

class Layer {
  public var chunk:LayerChunk;

  public var editable(get, set):Bool;

  function get_editable():Bool {
    return chunk.flags & Editable == Editable;
  }

  function set_editable(val:Bool) {
    chunk.flags = (visible ? Visible : 0) | (val ? Editable : 0);
    return editable;
  }

  public var name(get, set):String;

  function get_name():String
    return chunk.name;

  function set_name(val:String)
    return chunk.name = val;

  public var visible(get, set):Bool;

  function get_visible():Bool {
    return chunk.flags & Visible == Visible;
  }

  function set_visible(val:Bool):Bool {
    chunk.flags = (val ? Visible : 0) | (editable ? Editable : 0);
    return visible;
  }

  public function new(?chunk:LayerChunk) {
    if (chunk != null)
      this.chunk = chunk;
    else
      this.chunk = new LayerChunk(true);
  }
}
