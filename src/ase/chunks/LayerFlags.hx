package ase.chunks;

class LayerFlags {
  public static inline var VISIBLE:Int = 1; // Visible
  public static inline var EDITABLE:Int = 2; //  Editable
  public static inline var LOCK:Int = 4; //  Lock movement
  public static inline var BACKGROUND:Int = 8; // Background
  public static inline var PREFER_LINKED_CELS:Int = 16; // Prefer linked cels
  public static inline var GROUP_COLLAPSED:Int = 32; // The layer group should be displayed collapsed
  public static inline var REFERENCE:Int = 64; // The layer is a reference layer
}
