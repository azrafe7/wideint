#if macro
import haxe.macro.Expr;
#end

import haxe.Int64;
import haxe.Int64Helper;

using StringTools;

/**
 * Conventions:
 * 
 *  - `WideInt` and `wi` are _visual_ shortcuts for `Int64`
 *  - same applies for one-letter parts in conversion methods (`s`:String, `f`:Float, `i`:Int, `x`:Expr)
 *  - conversion methods also have more properly named aliases (e.g. wi2s() == int64ToString()), hinted with @:noUsing
 *  - many of the conversion methods will trow an exception in case of (under|over)flow
 * 
 * Notes:
 * 
 *  - floatToInt64() doesn't round the value before conversion, it truncates it (i.e. `floatToInt64(.5) == floatToInt64(-.5) == 0`)
 *    - use roundedFloatToInt64() for that (or the related rf2wi())
 *  - Int64 itself wraps around in case of (under|over)flow (i.e. `MAX_INT64 + 1 == MIN_INT64`)
 *  - dafault behaviour about NaN/NEGATIVE_INFINITY/POSITIVE_INFINITY apply
 */
class WideIntTools {
  
  static public inline var MIN_INT64_STR:String = "-9223372036854775808"; // 0x80000000_00000000
  static public inline var MAX_INT64_STR:String = "9223372036854775807";  // 0x7FFFFFFF_FFFFFFFF
  
  static public inline var MIN_INT64_FLOAT:Float = -9007199254740991; // -2^53 + 1
  static public inline var MAX_INT64_FLOAT:Float = 9007199254740991;  //  2^53 - 1
  
  static public inline var MIN_FLOAT_INT64_STR:String = "-9007199254740991"; // -2^53 + 1
  static public inline var MAX_FLOAT_INT64_STR:String = "9007199254740991";  //  2^53 - 1
  
  static public var MIN_INT64(default, never):Int64 = Int64.parseString(MIN_INT64_STR);
  static public var MAX_INT64(default, never):Int64 = Int64.parseString(MAX_INT64_STR);
  
  static public var MIN_FLOAT_INT64(default, never):Int64 = Int64.parseString(MIN_FLOAT_INT64_STR);
  static public var MAX_FLOAT_INT64(default, never):Int64 = Int64.parseString(MAX_FLOAT_INT64_STR);
  
  static public var hexRegex(default, never):EReg = ~/\s*0x((?:[0-9a-f]{1,8}){1,2})(.*)/gi;
  
  
  // LONG VERSIONS
  
  /* NOTE: naive conversion Int64 -> String -> Float) */
  @:noUsing
  static public function int64ToFloat(value:Int64):Float {
    if (value < MIN_FLOAT_INT64 || value > MAX_FLOAT_INT64) {
      throw "Error: loss of precision \n  (Int64: " + value + " not in range [" + MIN_FLOAT_INT64_STR + ", " + MAX_FLOAT_INT64_STR + "]";
    }
    return Std.parseFloat(Std.string(value));
  }
  
  @:noUsing
  inline static public function int64ToInt(value:Int64):Int {
    return Int64.toInt(value);
  }

  @:noUsing
  inline static public function int64ToString(value:Int64):String {
    return Int64.toStr(value);
  }

  @:noUsing
  inline static public function floatToInt64(value:Float):Int64 {
    return Int64Helper.fromFloat(value);
  }
  
  @:noUsing
  inline static public function roundedFloatToInt64(value:Float):Int64 {
    return Int64Helper.fromFloat(Math.fround(value));
  }
  
  @:noUsing
  inline static public function intToInt64(value:Int):Int64 {
    return Int64.ofInt(value);
  }
  
  @:noUsing
  static public function stringToInt64(value:String):Int64 {
    if (hexRegex.match(value)) {
      var tail = hexRegex.matched(2);
      if (tail != "") throw "NumberFormatError: Invalid Int64 hex string (" + value + ")";
      
      // extract high and low
      var hex = hexRegex.matched(1);
      var low = hex.substr(-8);
      var high = hex.substr(0, hex.length - low.length);
      if (high == "") high = "0";
      
      var i64 = Int64.make(Std.parseInt("0x" + high), Std.parseInt("0x" + low));
      return i64;
    }
    return Int64.parseString(value);
  }
  
  @:noUsing
  #if !macro macro #end
  inline static public function exprToInt64(value:Expr) {
    //trace("exprToInt64 `" + value + "` ");// + Context.currentPos());

    var i64:Int64 = switch (value.expr) {
      case EConst(CInt(f) | CFloat(f)): 
        floatToInt64(Std.parseFloat(f));
      case EConst(CString(s)): 
        stringToInt64(s);
      case _:
        throw 'Error: literal Int|Float|String expected, received ${value.expr}';
    }
    
    return macro (haxe.Int64.make($v{i64.high}, $v{i64.low}):Int64);
  }
  
  
  // SHORT VERSIONS
  
  // from Int64
  
  inline static public function wi2f(value:Int64):Float {
    return int64ToFloat(value);
  }
  
  inline static public function wi2i(value:Int64):Int {
    return int64ToInt(value);
  }
  
  inline static public function wi2s(value:Int64):String {
    return int64ToString(value);
  }

  inline static public function toString(value:Int64):String {
    return int64ToString(value);
  }
  
  inline static public function toHex(value:Int64):String {
    return StringTools.hex(value.high, 8) + StringTools.hex(value.low, 8);
  }
  
  // to Int64
  
  inline static public function f2wi(value:Float):Int64 {
    return floatToInt64(value);
  }
  
  inline static public function rf2wi(value:Float):Int64 {
    return roundedFloatToInt64(value);
  }
  
  inline static public function i2wi(value:Int):Int64 {
    return intToInt64(value);
  }
  
  inline static public function s2wi(value:String):Int64 {
    return stringToInt64(value);
  }
  
  #if !macro macro #end
  inline static public function x2wi(value:Expr) {
    return exprToInt64(value);
  } 
  
  
  // as aliases
  
  inline static public function asFloat(value:Int64):Float {
    return int64ToFloat(value);
  }
  
  inline static public function asInt(value:Int64):Int {
    return int64ToInt(value);
  }
  
  inline static public function asString(value:Int64):String {
    return int64ToString(value);
  }
  
  inline static public function asHex(value:Int64):String {
    return toHex(value);
  }
}