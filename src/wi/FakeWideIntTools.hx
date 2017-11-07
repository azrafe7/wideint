package wi;

#if macro
import haxe.macro.Expr;
#end

using StringTools;

/**
 * This fakes WideIntTools by replacing all Int64 occurrences with Int ones.
 */
class FakeWideIntTools {
  
  static public inline var MIN_INT64_STR:String = "-2147483648"; // 0x80000000
  static public inline var MAX_INT64_STR:String = "2147483647";  // 0x7FFFFFFF
  
  static public inline var MIN_INT64_FLOAT:Float = -2147483648.; // -2^31
  static public inline var MAX_INT64_FLOAT:Float = 2147483647.;  //  2^31 - 1
  
  static public inline var MIN_FLOAT_INT64_STR:String = "-2147483648"; // -2^31
  static public inline var MAX_FLOAT_INT64_STR:String = "2147483647";  //  2^31 - 1
  
  static public var MIN_INT64(default, never):Int = parseInt64String(MIN_INT64_STR);
  static public var MAX_INT64(default, never):Int = parseInt64String(MAX_INT64_STR);
  
  static public var MIN_FLOAT_INT64(default, never):Int = parseInt64String(MIN_FLOAT_INT64_STR);
  static public var MAX_FLOAT_INT64(default, never):Int = parseInt64String(MAX_FLOAT_INT64_STR);
  
  static public var hexRegex(default, never):EReg = ~/^\s*0x((?:[0-9a-f]{1,8}))(.*)/gi;
  static public var decRegex(default, never):EReg = ~/^\s*([-]?[0-9]{1,})(.*)/gi;
  
  static public inline var TWO_32:Float = 4294967296.; // Math.pow(2., 32);
  
  
  @:noUsing
  inline public static function parseInt64String( sParam : String ) : Int {
    return Std.parseInt(sParam);
  }
  
  
  // LONG VERSIONS
  
  @:noUsing
  static public function int64ToStringToFloat(value:Int):Float {
    if (value < MIN_FLOAT_INT64 || value > MAX_FLOAT_INT64) {
      throw "Error: loss of precision \n  (Int64: " + value + " not in range [" + MIN_FLOAT_INT64_STR + ", " + MAX_FLOAT_INT64_STR + "]";
    }
    return Std.parseFloat(Std.string(value));
  }
  
  @:noUsing
  inline static public function int64ToFloat(value:Int):Float {
    return cast value;
  }
  
  @:noUsing
  inline static public function int64ToInt(value:Int):Int {
    return value;
  }

  @:noUsing
  inline static public function int64ToString(value:Int):String {
    return Std.string(value);
  }

  @:noUsing
  inline static public function floatToInt64(value:Float):Int {
    return Std.int(value);
  }
  
  @:noUsing
  inline static public function roundedFloatToInt64(value:Float):Int {
    return Std.int(Math.fround(value));
  }
  
  @:noUsing
  inline static public function intToInt64(value:Int):Int {
    return value;
  }
  
  @:noUsing
  static public function stringToInt64(value:String):Int {
    if (hexRegex.match(value)) {
      var tail = hexRegex.matched(2);
      if (tail != "" || hexRegex.matched(1) == "") throw "NumberFormatError: Invalid Int64 hex string (" + value + ")";
      
      var hex = hexRegex.matched(1);
      
      return Std.parseInt(hex);
    }
    
    if (decRegex.match(value)) {
      var tail = decRegex.matched(2);
      if (tail != "" || decRegex.matched(1) == "") throw "NumberFormatError: Invalid Int64 dec string (" + value + ")";
      return parseInt64String(decRegex.matched(1));
    }
    
    throw "NumberFormatError: Invalid Int64 string (" + value + ")";
  }
  
  @:noUsing
  #if !macro macro #end
  inline static public function exprToInt64(value:Expr) {
    //trace("exprToInt64 `" + value + "` ");// + Context.currentPos());

    var i64:Int = switch (value.expr) {
      case EConst(CInt(f) | CFloat(f)): 
        floatToInt64(Std.parseFloat(f));
      case EConst(CString(s)): 
        stringToInt64(s);
      case _:
        throw 'Error: literal Int|Float|String expected, received ${value.expr}';
    }
    
    return macro ($v{i64}:Int);
  }
  
  
  // SHORT VERSIONS
  
  // from Int64
  
  inline static public function wi2f(value:Int):Float {
    return int64ToFloat(value);
  }
  
  inline static public function wi2i(value:Int):Int {
    return int64ToInt(value);
  }
  
  inline static public function wi2s(value:Int):String {
    return int64ToString(value);
  }

  inline static public function toString(value:Int):String {
    return int64ToString(value);
  }
  
  inline static public function toHex(value:Int):String {
    return StringTools.hex(value, 8);
  }
  
  // to Int64
  
  inline static public function f2wi(value:Float):Int {
    return floatToInt64(value);
  }
  
  inline static public function rf2wi(value:Float):Int {
    return roundedFloatToInt64(value);
  }
  
  inline static public function i2wi(value:Int):Int {
    return intToInt64(value);
  }
  
  inline static public function s2wi(value:String):Int {
    return stringToInt64(value);
  }
  
  #if !macro macro #end
  inline static public function x2wi(value:Expr) {
    return exprToInt64(value);
  } 
  
  
  // as aliases
  
  inline static public function asFloat(value:Int):Float {
    return int64ToFloat(value);
  }
  
  inline static public function asInt(value:Int):Int {
    return int64ToInt(value);
  }
  
  inline static public function asString(value:Int):String {
    return int64ToString(value);
  }
  
  inline static public function asHex(value:Int):String {
    return toHex(value);
  }
}