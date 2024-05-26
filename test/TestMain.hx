package;

import ase.Ase;
import ase.AseHeader;
import ase.chunks.OldPaleteChunk;
import ase.types.ChunkType;
import haxe.io.Bytes;
import sys.FileSystem;
import sys.io.File;

using Type;

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

  function report(name:String, success:Bool, ?errorMessage:String) {
    print('   ${success ? 'SUCCESS' : 'FAIL   '}: $name',
      success ? GREEN : RED);
    if (!success && errorMessage != null)
      print('            ERROR: $errorMessage', RED);
  }

  function assert(name:String, assertion:Void->Bool) {
    var result:Bool = false;
    var errorMsg:String = 'Assertion is FALSE';
    try {
      result = assertion();
    } catch (error) {
      result = false;
      errorMsg = '${error.message} \n ${error.details()}';
    }

    report(name, result, errorMsg);
  }

  function assertEqual<T>(name:String, expect:T, got:T) {
    if (expect == got) {
      report(name, true);
    } else {
      report(name, false, 'Expecting $expect, got: $got');
    }
  }

  function run(name:String, test:Void->Void) {
    print('$name:');
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

      assert('Save data to another file without errors', () -> {
        File.saveBytes('test_files/tmp/128x128_rgba.aseprite', ase.toBytes());
        return true;
      });
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

    run('Parsing and writing', () -> {
      for (testFile in ['128x128_rgba.aseprite', 'slices.aseprite']) {
        var bytes = File.getBytes('test_files/$testFile');
        var ase:Ase;

        assert('File $testFile read', () -> {
          ase = Ase.fromBytes(bytes);

          return true;
        });

        for (frame in ase.frames) {
          for (chunk in frame.chunks) {
            assertEqual(chunk.getClass().getClassName().split('.').pop()
              + ' read header size equals to calculated',
              chunk.header.size, chunk.size);
          }

          assertEqual('Frame header size equals to calculated',
            frame.header.size, frame.size);
        }

        assertEqual('Calculated file length is equal to amount of read bytes',
          bytes.length, ase.fileSize);

        for (n in 0...ase.frames.length) {
          var frame = ase.frames[n];

          for (chunk in frame.chunks) {
            var chunkBytes = chunk.toBytes();

            assertEqual(chunk.getClass().getClassName().split('.').pop()
              + ' written bytes size is equal to calculated',
              chunk.size, chunkBytes.length);
          }

          var frameBytes = frame.toBytes();

          assertEqual('Frame $n written bytes size is equal to frame header size',
            frame.size, frameBytes.length);
        }

        var aseBytes = ase.toBytes();

        assertEqual('Written bytes length is the same as the read one',
          bytes.length, aseBytes.length);

        assert('Written length is the same as the read one', () -> {
          return aseBytes.length == bytes.length;
        });
      }
    });

    run('Create a blank file', () -> {
      FileSystem.createDirectory('test_files/tmp');
      var ase:Ase;
      assert('Create a new blank sprite', () -> {
        ase = Ase.create(128, 128, [
          0xff0000ff,
          0xff8800ff,
          0xffff00ff,
          0x00ff00ff,
          0x0000ffff,
          0x000088ff,
          0xff00ffff
        ]);
        ase.addLayer();
        return true;
      });

      var bytes:Bytes;
      assert('Convert to bytes', () -> {
        bytes = ase.toBytes();
        return true;
      });

      assert('Save to file test_files/tmp/blank128x128.aseprite', () -> {
        File.saveBytes('test_files/tmp/blank128x128.aseprite', bytes);
        return true;
      });

      assert('Saved files have correct palette chunks', () -> {
        final bytes = File.getBytes('test_files/tmp/blank128x128.aseprite');
        final ase = Ase.fromBytes(bytes);

        final oldPaletteChunks:Array<OldPaleteChunk> = cast ase.firstFrame.chunkTypes[ChunkType.OLD_PALETTE_04];
        final paletteChunks = ase.firstFrame.chunkTypes[ChunkType.PALETTE];

        return oldPaletteChunks.length == 1
          && oldPaletteChunks[0].numPackets == 1
          && oldPaletteChunks[0].packets[0].numColors == 7
          && paletteChunks == null;
      });
    });

    run('Create pong animation programmatically', () -> {
      FileSystem.createDirectory('test_files/tmp');
      var ase:Ase;

      assert('Create a new blank sprite', () -> {
        FileSystem.createDirectory('test_files/tmp');
        ase = Ase.create(200, 200, INDEXED,
          [0x000000ff, 0x000000ff, 0xffffffff]);

        ase.addLayer('Background');
        ase.addLayer('Ball');

        // Fill Background
        ase.frames[0].createCel(0, 200, 200).fillIndex(1);

        var firstFrameBall = ase.frames[0].createCel(1, 20, 20);
        firstFrameBall.fillIndex(2);
        firstFrameBall.yPosition = 90;

        for (n in 1...20) {
          var frame = ase.addFrame(50);
          frame.linkCel(0, 0);

          var ball = frame.createCel(1, 20, 20);
          ball.fillIndex(2);
          ball.yPosition = 90;

          if (n < 10)
            ball.xPosition = Std.int(200 * (n / 10));
          else
            ball.xPosition = Std.int(180 - 200 * ((n - 10) / 10));
        }

        return true;
      });

      assert('Save to file test_files/tmp/pong.aseprite', () -> {
        File.saveBytes('test_files/tmp/pong.aseprite', ase.toBytes());
        return true;
      });
    });

    run('Read/write tilesets/tilemaps', () -> {
      final bytes = File.getBytes('test_files/tilemaps.aseprite');
      final ase = Ase.fromBytes(bytes);
      // TODO: More tests
    });

    run('Create 2x2px file with 2 colors in palette and compare it to one created in Aseprite',
      () -> {
        final fileBytes = File.getBytes('test_files/1x1_old_pal.aseprite');

        final ase = Ase.create(2, 2, INDEXED, [0x000000ff, 0xffffffff]);

        ase.addLayer('Layer 1');

        ase.firstFrame.createCel(0, 2, 2, 0, 0);

        ase.firstFrame.cel(0).setPixel(0, 0, 1);
        ase.firstFrame.cel(0).setPixel(0, 1, 0);
        ase.firstFrame.cel(0).setPixel(1, 0, 0);
        ase.firstFrame.cel(0).setPixel(1, 1, 1);

        final bytes = ase.toBytes();

        assert('Files have equal size', () -> {
          return bytes.length == fileBytes.length;
        });
      });
  }

  static function main() {
    new TestMain();
  }
}
