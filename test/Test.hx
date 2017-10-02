import haxe.Int64;
import haxe.Int64Helper;

import WideIntTools.*;
using WideIntTools;


class Int64Range {
  
  static public function main():Void {
    
    var float:Float = MIN_INT64_FLOAT;
    var min:Int64 = float.f2wi();
    trace("min: " + min);
    eq(MIN_FLOAT_INT64_STR, Std.string(min));
    
    
    trace("12341234234224".x2wi());
    trace(4.7.x2wi());
    trace(4.x2wi());
    trace(8.e2.x2wi());
    trace(2e3.x2wi());
    
    var a:Int64 = Int64Helper.fromFloat( -.5);
    trace(a);
    trace(Math.fround(-.5));
    var b:Int64 = Int64Helper.fromFloat( .5);
    trace(b);
    trace(Math.fround(.5));
    
    trace(min.wi2f() == Math.pow( -2., 53) +1);
    
    var e64:Int64 = 1.1e10.x2wi();
    trace("mul: " + MAX_FLOAT_INT64 * e64);
    trace("add: " + MAX_INT64 + 1);
    trace(floatToInt64(1.1e15));
    //trace(floatToInt64(1.1e15).x2wi());
    trace(floatToInt64(1.1e15).toHex());
    trace(0.x2wi());
    trace(0..x2wi());
    trace(MAX_INT64 + 1 == MIN_INT64);
    trace(roundedFloatToInt64(.5));
    trace(.5.f2wi());
    trace(.5.rf2wi());
    
    trace("1234567890123455675".x2wi());
    trace("0X0000000012a".x2wi());
    trace("0X0000000012a".s2wi());
    trace(" 0X0000000012a".s2wi());
    trace("0X12a".s2wi());
    trace("0xFFFFFFFFABAB".s2wi());
    trace("0xFFFFFFFFABABABAB".s2wi());
    trace("0xFFFFFFFFABABABAB cc".s2wi());
    trace("0xFFFFFFFFABABABABcc".s2wi());
    trace("0xFFFFFFFFABABABghABcc".s2wi());
    trace(1234567890123455.75.x2wi());
    trace(floatToInt64(1234567890123455.75));
  }
  
  /* NOTE: naive conversion Int64 -> String -> Float) */
  static public function int64ToFloat(i64:Int64):Float {
    return Std.parseFloat(Std.string(i64));
  }
  
  static public function eq<T>(expected:T, actual:T):Bool {
    if (expected != actual) throw("Expected `" + expected + "`, was `" + actual + "`");
    return true;
  }
}

