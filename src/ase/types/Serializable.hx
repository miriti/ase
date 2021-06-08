package ase.types;

import haxe.io.Bytes;
import haxe.io.BytesOutput;

interface Serializable {
  public function toBytes(?out:BytesOutput):Bytes;
}
