[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE.md) [![Haxelib Version](https://img.shields.io/github/tag/miriti/ase.svg?style=flat&label=haxelib)](http://lib.haxe.org/p/ase)

# ASE

A `.ase/.aseprite` file format reader/writer written in Haxe with no external dependencies.

Implemented following the official [Aseprite File Format (.ase/.aseprite) Specifications](https://github.com/aseprite/aseprite/blob/master/docs/ase-file-specs.md).

Note that this library only provides reading and writing of the Aseprite file format. If you need rendering, you will have to implement it yourself or use one of the existing rendering libraries:

- [OpenFL Aseprite](https://github.com/miriti/openfl-aseprite)
- [heaps-aseprite](https://github.com/AustinEast/heaps-aseprite) by [Austin East](https://github.com/AustinEast)

## Getting Started

### Prerequisites

- Haxe compiler
- Haxelib

### Installation

```shell
haxelib install ase
```

### Usage

#### Parsing Files

```haxe
import sys.io.File;
import ase.Ase;

var data:Bytes = File.getBytes("path/to/file.aseprite");
var ase:Ase = Ase.fromBytes(data);
```

Now you can access some Aseprite file properties:

```haxe
var spriteWidth:Int = ase.width;
var spriteHeight:Int = ase.height;
var spriteColorDepth:ColorDepth = ase.colorDepth;
```

Palette:

```haxe
for(index => entry in ase.palette.entries) {
    trace('Red: ${entry.red}, Green: ${entry.green}, Blue: ${entry.blue}, Alpha: ${entry.alpha}');

    // Alternatively, get the 32-bit integer RGBA or ARGB value
    var rgbaColor:Int = ase.palette.getRGBA(index);
    var argbColor:Int = ase.palette.getARGB(index);
    trace('RGBA: ${StringTools.hex(rgbaColor, 8)}, ARGB: ${StringTools.hex(argbColor, 8)}');
}
```

Layers:

```haxe
for(layer in ase.layers) {
    var layerName:String = layer.name;
    var layerEditable:Bool = layer.editable;
    var layerVisible:Bool = layer.visible;
}
```

Frames:

```haxe
for(frame in ase.frames) {
    var frameDuration = frame.duration;
}
```

Cels:

```haxe
var layerIndex:Int = 0;

var celWidth:Int = frame.cel(layerIndex).width;
var celHeight:Int = frame.cel(layerIndex).height;
var celPixelData:Bytes = frame.cel(layerIndex).pixelData;
```

#### Creating Files

```haxe
var spriteWidth:Int = 320;
var spriteHeight:Int = 320;
var colorDepth:ColorDepth = INDEXED;
var initialPalette:Array<Int> = [
    0x639bffff,
    0x5fcde4ff,
    0xcbdbfcff,
    0xffffffff,
    0x9badb7ff,
    0x847e87ff
];

var ase = Ase.create(spriteWidth, spriteHeight, colorDepth);
```

A newly created file always comes with one blank frame. To add some content, add at least one layer first:

```haxe
ase.addLayer('Background');
```

Now, to add some pixels to the sprite, create a Cel on the first frame and the newly created layer:

```haxe
var layerIndex:Int = 0;
var celWidth:Int = 200;
var celHeight:Int = 200;
var celXPosition:Int = 60;
var celYPosition:Int = 60;

var cel = ase.frames[0].createCel(
    layerIndex,
    celWidth,
    celHeight,
    celXPosition,
    celYPosition
);
```

There are a couple of methods to manipulate pixels of a cel:

```haxe
cel.fillIndex(0); // Fill the cel with color #0 from the palette
cel.fillColor(0xff00ff00); // Fill the cel with ARGB color (for 32bpp mode)
cel.setPixel(20, 20, 0xff0033aa); // Set ARGB color at x and y
cel.setPixel(20, 20, 4); // Set color index at x and y
cel.setPixelData(bytes, 300, 300); // Set bytes of the pixel data (the size must be equal to width x height x bpp)
```

At any time, you can get the file representation as bytes and, for example, store them to a file:

```haxe
var bytes = ase.getBytes();
File.saveBytes('my_aseprite_file.aseprite', bytes);
```

## Contributors

See [https://github.com/miriti/ase/graphs/contributors](https://github.com/miriti/ase/graphs/contributors).

## License

This project is licensed under the MIT License - see the [LICENSE.md](./LICENSE.md) file for details.
