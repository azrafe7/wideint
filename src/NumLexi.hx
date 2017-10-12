
import WideIntTools.*;

using haxe.Int64Helper;
using haxe.Int64;


private typedef Repr = {
  var value:String;
  var stripped:String;
  var complement:String;
}


/** 
 * Utility class to compare arbitrary-long numeric strings.
 * 
 * NOTES:
 * 
 *  - it's wise to trim the num-strings before using these functions
 *  - works for negative num-strings too (but `-` is only accepted if in 0 position)
 *  - num-strings starting with anything but `-` or digits are invalid (i.e. `+123` is not supported)
 */
class NumLexi {
  
  static inline public function isNegativeStr(s:String):Bool {
    return s.charAt(0) == '-';
  }
  
  static inline public function leftPad(s:String, with:String, len:Int):String {
    return StringTools.lpad(s, with, len);
  }
  
  static inline public function isNullOrEmpty(s:String):Bool {
    return s == null || s == "";
  }
  
  static public function stripLeadingZeros(s:String):String {
    var regex:EReg = ~/^([-])?([0]+)(.*)/g;
    if (regex.match(s)) {
      var sign = isNullOrEmpty(regex.matched(1)) ? "" : regex.matched(1);
      var rest = isNullOrEmpty(regex.matched(3)) ? null : regex.matched(3);
      if (rest == null) return "0";
      return sign + rest;
    } else {
      return s;
    }
  }
  
  static public function createRepr(s:String, len:Int):Repr {
    inline function makeComplement(s:String) {
      var buf = new StringBuf();
      for (i in 0...s.length) {
        var c = s.charCodeAt(i);
        buf.addChar('0'.code + '9'.code - c);
      }
      return buf.toString();
    }
    
    var noZeros = stripLeadingZeros(s);
    var isNegative = isNegativeStr(noZeros);
    var repr:Repr = { value:s, stripped:noZeros, complement:noZeros };
    if (isNegative) {
      var abs = noZeros.substr(1);
      var padded = leftPad(abs, "0", len);
      repr.complement = "0" + makeComplement(padded);
    } else {
      var abs = noZeros;
      var padded = leftPad(abs, "0", len);
      repr.complement = "9" + padded;
    }
    
    return repr;
  }
  
  static inline public function reprCmp(a:Repr, b:Repr):Int {
    return (a.complement < b.complement) ? -1 : (a.complement > b.complement) ? 1 : 0;
  }
  
  static public function compare(a:String, b:String):Int {
    var len = a.length >= b.length ? a.length : b.length;
    
    var first = createRepr(a, len);
    var second = createRepr(b, len);
    
    var compare = reprCmp(first, second);
    //trace(compare, first, second);
    
    return compare;
  }
  
  static inline public function isInInt64Range(a:String):Bool {
    return (compare(a, MIN_INT64_STR) >= 0 && compare(a, MAX_INT64_STR) <= 0);
  }
}