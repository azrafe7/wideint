
import WideIntTools.*;

using haxe.Int64Helper;
using haxe.Int64;


private typedef Repr = {
  var value:String;
  var complement:String;
}

class NumLexi {
  
  static public inline function isNegativeStr(s:String):Bool {
    return s.charAt(0) == '-';
  }
  
  static public inline function leftZeroPad(s:String, len:Int):String {
    return StringTools.lpad(s, "0", len);
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
    
    var isNegative = isNegativeStr(s);
    var abs = isNegative ? s.substr(1) : s;
    var zeroPadded = leftZeroPad(abs, len);
    var complement = isNegative ? makeComplement(zeroPadded) : zeroPadded;
    return { value:s, complement:complement };
  }
  
  static public inline function cmp(a:Repr, b:Repr):Int {
    return (a.complement < b.complement) ? 1 : (a.complement > b.complement) ? -1 : 0;
  }
  
  static public function numLexiCompare(a:String, b:String):Int {
    var len = a.length > b.length ? a.length : b.length;
    
    var first = createRepr(a, len);
    var second = createRepr(b, len);
    
    var compare = cmp(first, second);
    //trace(compare, first, second);
    
    return compare;
  }
  
  static public inline function isInInt64Range(a:String):Bool {
    return (numLexiCompare(a, MIN_INT64_STR) >= 0 && numLexiCompare(a, MAX_INT64_STR) <= 0); 
  }
}
