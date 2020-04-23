import ase.AseHeader;
import ase.Aseprite;
import ase.chunks.ChunkType;
import haxe.Resource;
import haxe.io.Bytes;
import massive.munit.Assert;

class AsepriteTest {
  @Test
  public function case128x128_rgba() {
    // TODO: More/better tests
    var aseprite = Aseprite.fromBytes(Resource.getBytes('128x128_rgba'));
    Assert.areEqual(AseHeader.ASEPRITE_MAGIC, aseprite.header.magic);
    Assert.areEqual(128, aseprite.header.width);
    Assert.areEqual(128, aseprite.header.height);
    Assert.areEqual(1, aseprite.header.frames);
    Assert.areEqual(32, aseprite.header.colorDepth);
  }

  @Test
  public function caseSlices() {
    // TODO: More/better tests
    var aseprite = Aseprite.fromBytes(Resource.getBytes('slices.aseprite'));
    Assert.areEqual(aseprite.frames[
      0
    ].chunkTypes[
        ChunkType.SLICE
      ].length, 4);
    Assert.areEqual(aseprite.frames[
      0
    ].chunkTypes[
        ChunkType.SLICE
      ][
          0
        ].userData.text, 'User Data + Blue color');
  }
}
