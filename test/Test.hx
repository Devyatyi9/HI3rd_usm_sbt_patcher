package;

class Test {
	static public function main():Void {
		trace("Test World");
		var path = "2.6_CG107_mux.usm";
		var strPath = '2.6_CG107_mux_en.srt';
		// usmTestReadWrite(path);
		strTest(strPath);
	}

	static function usmTestReadWrite(location:String) {
		// USM Read
		var input = sys.io.File.read(location);
		trace('Start of usm file reading: "$location"');
		var thisUSM = new UsmReader(input).read(1);
		trace(thisUSM[0]);
		input.close();
		// USM Patch
	}

	static function strTest(location:String) {
		var input = sys.io.File.read(location);
		trace('start test srt.');
		// \r\n // CRLF
		new SrtReader(input).read();
	}
}
