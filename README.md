# ASE

.ase/.aseprite file format loader written in Haxe without external dependencies.

Implemented following the official [Aseprite File Format (.ase/.aseprite) Specifications](https://github.com/aseprite/aseprite/blob/master/docs/ase-file-specs.md)

Note that this library only provides parsing of the Aseprite file format. If you need rendering you will have to implement it yourself or use one of the existing rendering libraries:

- [OpenFL Aseprite](https://github.com/miriti/openfl-aseprite)
- [heaps-aseprite](https://github.com/AustinEast/heaps-aseprite) by [Austin East](https://github.com/AustinEast)

## Getting Started

### Prerequisites

- Haxe compiler
- Haxelib

### Installation

```
haxelib install ase
```

### Usage

#### Parsing a file

```haxe
import sys.io.File;
import ase.Ase;

var data:Bytes = File.getBytes("path/to/file.aseprite");
var ase:Ase = Ase.fromBytes(data);
```

Now you can access the Aseprite file header:

```haxe
trace(ase.header.width);
trace(ase.header.height);
```

and frames data:

```haxe
trace(ase.frames);
```

## License

This project is licensed under the MIT License - see the LICENSE.md file for details
