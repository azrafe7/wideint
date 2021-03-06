
import utest.Runner;
import utest.ui.Report;
import utest.Assert;

import haxe.Int64;
import haxe.Int64Helper;

import wi.NumLexi;
import wi.WideIntTools.*;

using wi.WideIntTools;


@:keep
class Tests {
  
  public function new():Void { }
  
  @:keep
  static inline public function debugger() {
  #if (js || nodejs)
    untyped __js__('debugger');
  #end
  }
  
  // https://github.com/haxetink/tink_testrunner/blob/f58eb675b021d47cb3a37b841ae5780e1efe0d99/src/tink/testrunner/Reporter.hx#L168
  inline static public function trace(v:String) {
  #if travix
    travix.Logger.println(v);
  #elseif (air || air3)
    flash.Lib.trace(v);
  #elseif (sys || nodejs)
    Sys.println(v);
  #else
    haxe.Log.trace(v);
  #end
  }
  
  // https://github.com/haxetink/tink_testrunner/blob/700e5580a1ef8234f4c78f6a886468e928fc8a27/src/tink/testrunner/Runner.hx#L15
  static public function exit(code:Int) {
  #if travix
    travix.Logger.exit
  #elseif (air || air3)
    untyped __global__["flash.desktop.NativeApplication"].nativeApplication.exit
  #elseif (sys || nodejs)
    Sys.exit
  #elseif (phantomjs)
    untyped __js__('phantom').exit
  #else 
    trace("exit() not supported on this target. Return code was " + code + ".");
  #end (code);
  }
  
  
  static public function main():Void {
    var runner = new Runner();
    runner.addCase(new Tests());
    Report.create(runner);
    runner.run();
    
    // make sure we exit properly, which is necessary on some targets, e.g. flash & (phantom)js
    exit(0);
  }

  public function testInt64Range() {
    Assert.equals(MAX_INT64_STR, MAX_INT64.asString());
    Assert.equals(MIN_INT64_STR, MIN_INT64.asString());
    
    Assert.isTrue(Int64.make(0x7FFFFFFF, 0xFFFFFFFF) == MAX_INT64);
    Assert.isTrue(Int64.make(0x80000000, 0x00000000) == MIN_INT64);
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
  
  public function testFloatRangeWithPow() {
    var maxFloat:Float = Math.pow(2., 53) - 1;
    var minFloat:Float = Math.pow(-2., 53) + 1;
    
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
  
  public function testFromInt() {
    Assert.isTrue(0 == intToInt64(0));
    Assert.isTrue(0 == 0.i2wi());
    
    Assert.isTrue(0xFFFFFFFF == 0xFFFFFFFF.i2wi());
    Assert.isTrue(0x7FFFFFFF == 0x7FFFFFFF.i2wi());
    Assert.isTrue(0x80000000 == 0x80000000.i2wi());
    Assert.isTrue(-1 == -1.i2wi());
    
    var minInt:Int = 0x80000000;
    var fromIntHex:Int64 = minInt.i2wi();
    Assert.isTrue(minInt == fromIntHex);
    Assert.isTrue(fromIntHex < 0);
    
    var maxInt:Int = 0x7FFFFFFF;
    fromIntHex = maxInt.i2wi();
    Assert.isTrue(maxInt == fromIntHex);
    Assert.isTrue(fromIntHex > 0);
  }
  
  public function testFromNumExpr() {
    var i64:Int64 = exprToInt64(31.312);
    
    Assert.isTrue(31 == i64);
    Assert.isTrue(666 == 666.x2wi());
    Assert.isTrue(666 == 666.5.x2wi());
    Assert.isTrue(666 == 666.75.x2wi());
    
    Assert.isTrue(2147483647 == 2147483647.x2wi());
    Assert.isTrue(-2147483647 == -2147483647.x2wi());
    Assert.isTrue(-2147483647 == -2147483647.8.x2wi());
  }
  
  public function testFromSciNotation() {
    var i64:Int64 = exprToInt64(-0.0e0);
    Assert.isTrue(0 == i64);
    
    i64 = -0.0e3.x2wi();
    Assert.isTrue(0 == i64);
    
    var smallFloat:Float = -31.0e-12;
    Assert.isTrue(0.x2wi() == smallFloat.f2wi());
    Assert.isTrue(0.x2wi() == -31.0e-12.x2wi());
    
    Assert.isTrue(2e15 == 2e15.x2wi().asFloat());
    Assert.isTrue(-2e15 == -2e15.x2wi().asFloat());
  }

  public function testFromString() {
    Assert.isTrue(0 == stringToInt64("0"));
    
    Assert.isTrue(0 == "0".x2wi());
    Assert.isTrue(0 == "0".s2wi());
    Assert.isTrue(0 == "-0".s2wi());
    Assert.isTrue(0 == "-0".x2wi());

    Assert.isTrue(12 == "012".s2wi());
    Assert.isTrue(12 == "012".x2wi());
    Assert.isTrue(-123 == "  -123".x2wi());
    
    Assert.isTrue("-123456789012345" == "-123456789012345".s2wi().asString());
    Assert.isTrue("-123456789012345" == "-123456789012345".x2wi().asString());
    
    Assert.isTrue("-123456789012345" == "-123456789012345".s2wi().asString());
    Assert.isTrue("-123456789012345" == "-123456789012345".x2wi().asString());
    
    Assert.isTrue("1234567890123456789" == "   1234567890123456789".s2wi().asString());
    Assert.isTrue("1234567890123456789" == "   1234567890123456789".x2wi().asString());
    
    Assert.isTrue("-1234567890123456789" == "   -1234567890123456789".s2wi().asString());
    Assert.isTrue("-1234567890123456789" == "   -1234567890123456789".x2wi().asString());
  }
  
  public function testInvalidDecString() {
    var invalidStr = [
      "  ",
      "1.4",
      "1e2",
      " -123 ",
      "-12.1",
      " -12345678901234567890",
      " 12345678901234567890",
      "0345y",
      "-0x000",
      "1 c",
    ];

    for (i in 0...invalidStr.length) {
      try {
        var i64:Int64 = invalidStr[i].s2wi();
        Assert.fail("Exception expected for (" + invalidStr[i] + "), but not thrown (result was " + i64.asString() + ")!");
      } catch (err:Dynamic) {
        Assert.pass();
      }
    }
  }
  
  public function testFromHex() {
    var invalidStr = [
      "  ",
      "b12",
      " 1234 d",
      ".2",
      " 0xdgh",
      ",24",
      "-0x2gh",
      "-0x0",
      "-0x1",
      " 0x aaf",
      "2x3",
      "\t0XAsdDet",
      "      2e3",
      "0x2gh",
      "0x0123456701234567a",
      "0x01234567012345678",
      "0x0123456701234567 1",
      "-0x0123456701234567",
    ];

    for (i in 0...invalidStr.length) {
      try {
        var i64:Int64 = invalidStr[i].s2wi();
        Assert.fail("Exception expected for (" + invalidStr[i] + "), but not thrown (result was " + i64.asString() + ")!");
      } catch (err:Dynamic) {
        Assert.pass();
      }
    }
    
    var validStr = [
      { raw: "0xb12", expected: "B12" },
      { raw: "0x0", expected: "0" },
      { raw: "  0x0123456701abcdef", expected: "0123456701ABCDEF" },
    ];
    
    for (i in 0...validStr.length) {
      var i64:Int64 = validStr[i].raw.s2wi();
      var expected = StringTools.lpad(validStr[i].expected, "0", 16);
      Assert.isTrue(i64.asHex() == expected);
    }
    
  }
  
  public function testConversionOverflow() {
    var invalidFloats = [
      Math.pow(2, 53),
      Math.pow(-2, 53),
      Math.pow(2, 53) + 1.,
      Math.pow(-2, 53) - 1.,
    ];

    for (f in invalidFloats) {
      try {
        var i64:Int64 = f.f2wi();
        Assert.fail("Exception expected for (" + f + "), but not thrown (result was " + i64.asString() + ")!");
      } catch (err:Dynamic) {
        Assert.pass();
      }
    }
    
    var invalidStr = [
      "-9223372036854775809",
      "9223372036854775808",
      "0x12345678123456780"
    ];

    for (i in 0...invalidStr.length) {
      try {
        var i64:Int64 = invalidStr[i].s2wi();
        Assert.fail("Exception expected for (" + invalidStr[i] + "), but not thrown (result was " + i64.asString() + ")!");
      } catch (err:Dynamic) {
        Assert.pass();
      }
    }
  }
  
  public function testFromNaNs() {
    var floats = [
      Math.NaN,
      Math.NEGATIVE_INFINITY,
      Math.POSITIVE_INFINITY,
    ];
    
    for (f in floats) {
      try {
        var i64:Int64 = floatToInt64(f);
        Assert.fail("Exception expected for (" + f + "), but not thrown (result was " + i64.asString() + ")!");
      } catch (err:Dynamic) {
        Assert.pass();
      }
    }
  }
  
  public function testToFloatOverflow() {
    var int64values = [
      "-9007199254740992".x2wi(),
      "9007199254740992".x2wi(),
    ];
    
    for (i64 in int64values) {
      try {
        var float:Float = i64.asFloat();
        Assert.fail("Exception expected for (" + i64.asString() + "), but not thrown (result was " + float + ")!");
      } catch (err:Dynamic) {
        Assert.pass();
      }
    }
  }
  
  public function testToIntOverflow() {
    var int64values = [
      "0x100000000".x2wi(),
      (1. + 0x7fffffff).f2wi(),
      (-1. + 0x80000000).f2wi(),
      "-9007199254740992".x2wi(),
      "9007199254740992".x2wi(),
    ];
    
    for (i64 in int64values) {
      try {
        var int:Float = i64.asInt();
        Assert.fail("Exception expected for (" + i64.asString() + "), but not thrown (result was " + int + ")!");
      } catch (err:Dynamic) {
        Assert.pass();
      }
    }
  }
  
  @:analyzer(ignore)
  public function testFromExprNoOverhead() {
    debugger();
    
    // inspect the generated code to see if these translate
    // to single calls to the Int64 constructor
    // (e.g. `var this1 = new haxe__$Int64__$_$_$Int64(0,0);` etc.)
    
    var i0 = "0x0".x2wi();
    var i1 = "1".x2wi();
    var i2 = 2.5.x2wi();
    var i3 = 3.x2wi();
    var i4 = 0x4.x2wi();
    
    Assert.pass();
  }
  
  public function testFuzzyFloat() {
    var N = 55;
    
    for (i in 0...N) {
      var factor = Math.pow(2, Std.random(63));
      var sign = Math.random() > .5 ? -1 : 1;
      var float = sign * Math.random() * factor;

      if (float < MIN_INT64_FLOAT || float > MAX_INT64_FLOAT) {
        try {
          var i64:Int64 = float.f2wi();
          Assert.fail("Exception expected for (" + float + "), but not thrown (result was " + i64.asString() + ")!");
        } catch (err:Dynamic) {
          Assert.pass();
        }
      } else {
        var i64:Int64 = float.f2wi();
        var truncFloat = float < 0 ? Math.fceil(float) : Math.ffloor(float);
        Assert.isTrue(truncFloat == i64.asFloat(), 
          "Processing " + float + ": expected float(" + truncFloat + ") to be equal to i64(" + i64.asFloat() + "), but was not!");
      }
    }
  }
  
  public function testFuzzyRoundedFloat() {
    var N = 50;
    
    for (i in 0...N) {
      var factor = Math.pow(2, Std.random(63));
      var sign = Math.random() > .5 ? -1 : 1;
      var float = sign * Math.random() * factor;
      var roundedFloat = Math.fround(float);

      if (float < MIN_INT64_FLOAT || float > MAX_INT64_FLOAT) {
        try {
          var i64:Int64 = float.rf2wi();
          Assert.fail("Exception expected for (" + float + "), but not thrown (result was " + i64.asString() + ")!");
        } catch (err:Dynamic) {
          Assert.pass();
        }
      } else {
        var i64:Int64 = float.rf2wi();
        Assert.isTrue(roundedFloat == i64.asFloat(), 
          "Processing " + float + ": expected float(" + roundedFloat + ") to be equal to i64(" + i64.asFloat() + "), but was not!");
      }
    }
  }
  
  public function testFuzzyDecStrings() {
    var N = 50;
    
    for (i in 0...N) {
      var str = getRandDecString();
      checkDecString(str);
    }
  }
  
  public function testToFloat() {
    var okStrings = [
      "0",
      "-0",
      "4353.05540",
      "-7.",
      "4294967296.", // low boundaries
      "4294967297.",
      "-4294967296.",
      "-4294967297.",
      "-1.",
      "-9007199254740991", // min
      "9007199254740991", // max
      "-398395355787.07236",
      "0845290169736",
      "762438581428743.35608",
      "-0955534425199787.81944",
    ];

    var failStrings = [
      "-9007199254740992", // min - 1 should fail
      "9007199254740992", // max + 1 should fail
    ];
    
    
    for (s in okStrings) {
      var f = Std.parseFloat(s);
      f = trunc(f);
      
      if (!Math.isNaN(f)) {
        var i64 = Int64.fromFloat(f);
        var toFloat = i64.asFloat();
        Assert.equals(f, toFloat);
        Assert.equals(int64ToStringToFloat(i64), toFloat);
      }
    }
    
    for (s in failStrings) {
      var f = Std.parseFloat(s);
      f = trunc(f);
      
      if (!Math.isNaN(f)) {
        try {
          var i64 = Int64.fromFloat(f);
          var toFloat = i64.asFloat();
          Assert.fail("This should be an invalid conversion, but was " + toFloat + " for " + s);
        } catch (err:Dynamic) {
          Assert.pass();
        }
      }
    }
  }
  
  public function testFuzzyFloatStrings() {
    var N = 50;
    
    for (i in 0...N) {
      var str = getRandFloatString();
      var f = Std.parseFloat(str);
      f = trunc(f);
      
      if (!Math.isNaN(f)) {
        try {
          var i64 = Int64.fromFloat(f);
          if (i64 < MIN_FLOAT_INT64 || i64 > MAX_FLOAT_INT64) { // must throw on loss of precision
            Assert.raises(function ():Void {
              int64ToFloat(i64);
            });
          } else {
            var toFloat = int64ToFloat(i64);
            Assert.equals(f, toFloat);
            Assert.equals(int64ToStringToFloat(i64), toFloat);
          }
        } catch (err:Dynamic) {
          var msg = Std.string(err);
          Assert.isTrue(msg.indexOf("flow") > 0); // ok if out of int64 range
        }
      }
    }
  }
  
  public function testFuzzyNaiveNumLexiCmp() {
    var N = 24;
    var maxLen = 50;
    
    // a is negative, b is positive
    for (i in 0...N) {
      var a = getRandDecString(1, maxLen);
      var b = getRandDecString(1, maxLen);
      if (!NumLexi.isNegativeStr(a)) a = "-" + a;
      if (NumLexi.isNegativeStr(b)) b = b.substr(1);
      Assert.isTrue(NumLexi.compare(a, b) == -1);
    }
    
    // a is positive, b is negative
    for (i in 0...N) {
      var a = getRandDecString(1, maxLen);
      var b = getRandDecString(1, maxLen);
      if (NumLexi.isNegativeStr(a)) a = a.substr(1);
      if (!NumLexi.isNegativeStr(b)) b = "-" + b;
      Assert.isTrue(NumLexi.compare(a, b) == 1);
    }
  }
  
  public function testFuzzyNumLexiCmp() {
    var N = 50;
    var maxLen = 25;
    
    for (i in 0...N) {
      var str = getRandDecString(1, maxLen);
      try {
        var i64:Int64 = str.s2wi();
        Assert.equals(NumLexi.stripLeadingZeros(str), i64.asString());
        Assert.isTrue(NumLexi.isInInt64Range(str));
      } catch (err:Dynamic) {
        Assert.isFalse(NumLexi.isInInt64Range(str));
      }
    }
  }
  
  /*public function testToFloatSpeed() {
    var N = 1000;
    
    var int64s = [];
    for (i in 0...N) {
      var f = MIN_INT64_FLOAT + Math.random() * (MAX_INT64_FLOAT - MIN_INT64_FLOAT);
      int64s.push(floatToInt64(f));
    }
    
    var t0 = haxe.Timer.stamp();
    for (i in 0...N) {
      var f:Float = int64ToFloat(int64s[i]);
    }
    var directTime = haxe.Timer.stamp() - t0;
    
    t0 = haxe.Timer.stamp();
    for (i in 0...N) {
      var f:Float = int64ToStringToFloat(int64s[i]);
    }
    var indirectTime = haxe.Timer.stamp() - t0;
    
    trace(directTime + " vs " + indirectTime);
    Assert.isTrue(directTime < indirectTime);
  }*/
  
  static function getRandDecString(minLen:Int = 1, maxLen:Int = 25):String {
    var chars = "0123456789".split("");
    var sign = Math.random() > .5 ? "-" : "";
    var length = minLen + Std.random(maxLen - minLen);
    var randString = sign + [for (i in 0...length) chars[Std.random(chars.length)]].join("");
    return randString;
  }
  
  static function getRandFloatString(minLen:Int = 1, maxLen:Int = 25, maxDecimals:Int = 5):String {
    var chars = "0123456789".split("");
    var sign = Math.random() > .5 ? "-" : "";
    var length = minLen + Std.random(maxLen - minLen);
    var randString = sign + [for (i in 0...length) chars[Std.random(chars.length)]].join("");
    var randFracString = [for (i in 0...maxDecimals) chars[Std.random(chars.length)]].join("");
    return randString + "." + randFracString;
  }
  
  static function checkDecString(str:String) {
    var inRange = NumLexi.isInInt64Range(str);
    
    if (inRange) {
      try {
        var i64:Int64 = str.s2wi();
        Assert.equals(NumLexi.stripLeadingZeros(str), i64.asString());
      } catch (err:Dynamic){
        trace("This should be valid, but `" + str + "` threw an exception while isInInt64Range returned " + inRange + " (" + err + ")");
        Assert.fail();
      }
    } else {
      try {
        var i64:Int64 = str.s2wi();
        trace("This should NOT be valid, but `" + str + "` returned i64:" + i64.asString() + " while isInInt64Range returned " + inRange);
        Assert.equals(NumLexi.stripLeadingZeros(str), i64.asString());
      } catch (err:Dynamic){
        Assert.pass();
      }
    }
  }
  
  inline function trunc(f:Float):Float {
    return f - (f % 1.);
  }
}
