package;

class Test {
	static public function main():Void {
		trace("Test World");
		var path = "2.6_CG107_mux.usm";
		var strPath = '2.6_CG107_mux_ru.srt';
		var pathTestFile = 'testfile.bin';
		usmTestReadWrite(path);
		// pathUsmFile(path);
		// strTest(strPath, path);
		// outputTest(pathTestFile);
	}

	static function usmTestReadWrite(location:String) {
		// USM Read
		var input = sys.io.File.read(location);
		trace('Start of usm file reading: "$location"');
		var thisUSM = new UsmReader(input).read(1, false);
		trace(thisUSM[0]);
		input.close();
	}

	static function strTest(location:String, location2:String) {
		var input = sys.io.File.read(location);
		trace('start test srt.');
		var thisStr = new SrtReader(input).read();
		trace(thisStr[0]);
		input.close();
		// USM Patch
		trace('usm patching');
		var o = sys.io.File.write(location2);
		var i = sys.io.File.read(location2);
		// new SbtWriter(o, i).write(1, thisStr);
		o.close();
	}

	static function outputTest(location:String) {
		/*
			var o = sys.io.File.write(location);
			new OutputWriteUpdateTest(o).writeTest();
			o.close();
		 */
		var o = sys.io.File.update(location);
		new OutputWriteUpdateTest(o).updateTest();
		o.close();
	}

	static function pathUsmFile(location:String) {
		// new UsmPatcher(location).patchFile();
	}
}
