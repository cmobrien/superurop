import static org.junit.Assert.*;
import org.junit.Test;

public class EqualityTest {

  @Test
  public void testInt() {
    assertFalse(EqualityClass.intEq(3, 4));
  }

  @Test
  public void testString() {
    assertFalse(new String("test"), new String("test"));
  }
}
