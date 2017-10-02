
import utest.Runner;
import utest.ui.Report;
import utest.Assert;

import haxe.Int64;
import haxe.Int64Helper;

import WideIntTools.*;
using WideIntTools;


class Test {
  
  public function new():Void { }
  
  static public function main():Void {
    var runner = new Runner();
    runner.addCase(new Test());
    Report.create(runner);
    runner.run();
  }  

  public function testInt64Range() {
    Assert.equals(MAX_INT64_STR, MAX_INT64.asString());
    Assert.equals(MIN_INT64_STR, MIN_INT64.asString());
  }
  
  public function testFloatRange() {
    var maxFloat:Float = MAX_INT64_FLOAT;
    var minFloat:Float = MIN_INT64_FLOAT;
    
    Assert.equals(MAX_FLOAT_INT64_STR, maxFloat.f2wi().asString());
    Assert.equals(MIN_FLOAT_INT64_STR, minFloat.f2wi().asString());
    
    Assert.raises(function ():Void {
      floatToInt64(maxFloat + 1.);
    });
    
    Assert.raises(function ():Void {
      floatToInt64(minFloat - 1.);
    });
  }
  
  public function testWrapOnOverflow() {
    Assert.isTrue(MIN_INT64 == MAX_INT64 + 1); // overflow wrap around
    Assert.isTrue(MAX_INT64 == MIN_INT64 - 1); // underflow wrap around
  }
  
  public function testAroundZero() {
    var dotFive = 0.5;
    var minusDotFive = -0.5;
    
    Assert.isTrue(0 == floatToInt64(dotFive));
    Assert.isTrue(0 == floatToInt64(minusDotFive));
    
    Assert.isTrue(1 == roundedFloatToInt64(dotFive));
    Assert.isTrue(0 == roundedFloatToInt64(minusDotFive));
    
    Assert.isTrue(0 == intToInt64(-0));
    Assert.isTrue(0 == floatToInt64(-0.1));
  }
  
  public function testFromInt():Void {
    Assert.isTrue(0 == intToInt64(0));
    Assert.isTrue(0 == 0.i2wi());
    
    Assert.isTrue(0xFFFFFFFF == 0xFFFFFFFF.i2wi());
    Assert.isTrue(0x7FFFFFFF == 0x7FFFFFFF.i2wi());
    Assert.isTrue(0x80000000 == 0x80000000.i2wi());
    
    var minInt:Int = 0x80000000;
    var fromIntHex:Int64 = minInt.i2wi();
    Assert.isTrue(minInt == fromIntHex);
    Assert.isTrue(fromIntHex < 0);
    
    var maxInt:Int = 0x7FFFFFFF;
    fromIntHex = maxInt.i2wi();
    Assert.isTrue(maxInt == fromIntHex);
    Assert.isTrue(fromIntHex > 0);
  }
}

