
import utest.Runner;
import utest.ui.Report;
import utest.Assert as A;

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
    
  }
  
}

