# ASE

.ase/.aseprite file format loader written in Haxe without external dependencies.

Implemented following the official [Aseprite File Format (.ase/.aseprite) Specifications](https://github.com/aseprite/aseprite/blob/master/docs/ase-file-specs.md)

Note that this library only provides parsing of the Aseprite file format. If you need rendering you will have to implement it yourself or use some premade rendering library based on this one (in fact there's only one such library):

- [OpenFL Aseprite](https://github.com/miriti/openfl-aseprite)

## Getting Started

### Prerequisites

- Haxe compiler
- Haxelib

### Installation

```
haxelib install ase
```

### Usage

```haxe
import sys.io.File;
import ase.Aseprite;

var data:Bytes = File.getBytes("path/to/file.aseprite");
var aseprite:Aseprite = new Aseprite(data);
```

Now you can access the Aseprite file header:

```haxe
trace(aseprite.header.width);
trace(aseprite.header.height);
```

and frames data:

```haxe
trace(aseprite.frames);
```

## TODO

- [ ] Creating/changing and saving files in Aseprite format

## Authors

- Michael Miriti @miriti <m.s.miriti@gmail.com>

## License

This project is licensed under the MIT License - see the LICENSE.md file for details
