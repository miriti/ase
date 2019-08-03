package test;

import ase.chunks.PaletteChunk;
import ase.chunks.ColorProfileChunk;
import ase.chunks.CelChunk;
import ase.chunks.LayerChunk;
import ase.chunks.ChunkType;
import sys.io.File;
import haxe.io.Bytes;
import ase.Aseprite;

class Main {
  static public function main():Void {
    var fileData:Bytes = File.getBytes('test/006_walkman.aseprite');
    var aseprite:Aseprite = new Aseprite(fileData);
    trace('FileSize: ${aseprite.header.fileSize}');
    trace('Magic: 0x${StringTools.hex(aseprite.header.magic, 4)}');
    trace('Frames: ${aseprite.header.frames}');
    trace('Width: ${aseprite.header.width}');
    trace('Height: ${aseprite.header.height}');
    trace('Color Depth: ${aseprite.header.colorDepth}');
    trace('Flags: ${aseprite.header.flags}');
    trace('Speed: ${aseprite.header.speed}');
    trace('Palette Entry: ${aseprite.header.paletteEntry}');
    trace('Colors number: ${aseprite.header.colorsNumber}');
    trace('Pixel Width: ${aseprite.header.pixelWidth}');
    trace('Pixel Height: ${aseprite.header.pixelHeight}');

    trace('');

    var frameNum = 1;
    for (frame in aseprite.frames) {
      trace('Frame: ${frameNum++}');
      trace('  Duration: ${frame.header.duration}');

      for (chunk in frame.chunks) {
        trace('  Chunk: ${chunk.header.typeName} (0x${StringTools.hex(chunk.header.type, 4)})');
        if (chunk.userData != null) {
          trace('  HAS USER DATA: ');
          trace('   Flags: ${chunk.userData.flags}');
          trace('   Has Text: ${chunk.userData.hasText}');
          trace('   Has Color: ${chunk.userData.hasColor}');
          trace('   Text: ${chunk.userData.text}');
          trace('   Red: ${chunk.userData.red}');
          trace('   Green: ${chunk.userData.green}');
          trace('   Blue: ${chunk.userData.blue}');
          trace('   Alpha: ${chunk.userData.alpha}');
        }
        if (chunk.header.type == ChunkType.LAYER) {
          var layerChunk:LayerChunk = cast chunk;
          trace('    Name: ${layerChunk.name}');
          trace('    Flags: ${layerChunk.flags}');
          trace('    Layer Type: ${layerChunk.header.type}');
          trace('    Child Level: ${layerChunk.childLevel}');
          trace('    Default Width: ${layerChunk.defaultWidth}');
          trace('    Default Height: ${layerChunk.defaultHeight}');
          trace('    Blend Mode: ${layerChunk.blendMode}');
          trace('    Opacity: ${layerChunk.opacity}');
        }

        /*

          if (chunk.header.type == ChunkType.CEL) {
            var celChunk:CelChunk = cast chunk;
            trace('    Layer Index: ${celChunk.layerIndex}');
            trace('    X Position: ${celChunk.xPosition}');
            trace('    Y Position: ${celChunk.yPosition}');
            trace('    Opacity: ${celChunk.opacity}');
            trace('    Cel type: ${celChunk.celType}');
            if (celChunk.celType == CelType.RAW || celChunk.celType == CelType.COMPRESSED) {
              trace('    Width: ${celChunk.width}');
              trace('    Height: ${celChunk.height}');
            } else {
              trace('    Linked frame ${celChunk.linkedFrame}');
            }
          }

          if (chunk.header.type == ChunkType.COLOR_PROFILE) {
            var colorProfileChunk:ColorProfileChunk = cast chunk;
            trace('    Color Profile Type: ${colorProfileChunk.colorProfileType}');
            trace('    Flags: ${colorProfileChunk.flags}');
            trace('    Gamma: ${colorProfileChunk.gamma}');
          }

          if (chunk.header.type == ChunkType.PALETTE) {
            var paletteChunk:PaletteChunk = cast chunk;
            trace('    Palette Size: ${paletteChunk.paletteSize}');
            trace('    First Color Index: ${paletteChunk.firstColorIndex}');
            trace('    Last Color Index: ${paletteChunk.lastColorIndex}');
            trace('    Palette Entries: ');
            for (num in paletteChunk.entries.keys()) {
              trace('        [$num] ${paletteChunk.entries[num]}');
            }
          }
         */
      }
    }
  }
}
