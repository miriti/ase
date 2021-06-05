package;

import haxe.io.Bytes;
import ase.Ase;
import ase.AseHeader;
import ase.types.ChunkType;
import sys.io.File;

enum TermColor {
  NEUTRAL;
  GREEN;
  RED;
}

class TestMain {
  function print(text:String, color:TermColor = NEUTRAL) {
    Sys.stdout().writeString('\u001b[0m');
    switch (color) {
      case GREEN:
        Sys.stdout().writeString('\u001b[32m');
      case RED:
        Sys.stdout().writeString('\u001b[31m');
      case _:
    }
    Sys.stdout().writeString('$text\n');
    Sys.stdout().writeString('\u001b[0m');
  }

  function assert(name:String, assertion:Void->Bool) {
    var result:Bool = false;
    var errorMsg:String = 'Returned FALSE';
    try {
      result = assertion();
    } catch (error) {
      result = false;
      errorMsg = '${error.message}\n${error.details()}';
    }

    print('  ${result ? 'SUCCESS' : '   FAIL'}: $name', result ? GREEN : RED);
    if (!result)
      print('      ERROR: $errorMsg', RED);
  }

  function run(name:String, test:Void->Void) {
    print('Running $name:');
    test();
  }

  function new() {
    run('Basic Parsing', () -> {
      var ase:Ase;

      assert('test_files/128x128_rgba.aseprite loaded without errors', () -> {
        ase = Ase.fromBytes(File.read('test_files/128x128_rgba.aseprite')
          .readAll());
        return true;
      });
      assert('Correct Magic Number',
        () -> ase.header.magic == AseHeader.ASEPRITE_MAGIC);

      assert('Width and Height are equal 128',
        () -> ((ase.width == 128) && (ase.height == 128)));

      assert('File contains only one frame', () -> ase.frames.length == 1);

      assert('Color depth is 32 bits', () -> ase.header.colorDepth == 32);
    });

    run('More Parsing', () -> {
      var ase:Ase;

      assert('Loading file test_files/slices.aseprite', () -> {
        ase = Ase.fromBytes(File.read('test_files/slices.aseprite').readAll());
        return true;
      });

      assert('There are exactly 4 slices',
        () -> ase.frames[0].chunkTypes[ChunkType.SLICE].length == 4);

      assert('User data contains the expected string',
        () ->
          ase.frames[0].chunkTypes[ChunkType.SLICE][0].userData.text == 'User Data + Blue color');
    });

    run('Writing Files', () -> {
      var ase:Ase;
      assert('Create a new Ase instance', () -> {
        ase = Ase.create(16, 16);
        return true;
      });

      var bytes:Bytes;
      assert('Convert to bytes', () -> {
        bytes = ase.toBytes();
        return true;
      });

      assert('Store bytes to file', () -> {
        File.saveBytes('test_files/tmp01.aseprite', bytes);
        return true;
      });
    });
  }

  static function main() {
    new TestMain();
  }
}
