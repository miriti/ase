import ase.AseHeader;
import haxe.io.Bytes;
import haxe.Resource;
import ase.Aseprite;
import massive.munit.Assert;

class AsepriteTest {
  @Test
  public function case128x128_rgba() {
    var aseprite = Aseprite.fromBytes(Resource.getBytes('128x128_rgba'));
    Assert.areEqual(AseHeader.ASEPRITE_MAGIC, aseprite.header.magic);
    Assert.areEqual(128, aseprite.header.width);
    Assert.areEqual(128, aseprite.header.height);
    Assert.areEqual(1, aseprite.header.frames);
    Assert.areEqual(32, aseprite.header.colorDepth);
  }
}
