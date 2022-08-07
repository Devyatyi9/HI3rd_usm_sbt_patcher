package;

import sys.FileSystem;
import haxe.io.Path;
import usm.*;
import srt.*;

class Test {
	static public function main():Void {
		trace("Test launch");
		var game_path = "D:/Games/Honkai Impact 3rd glb/Games";
		var convertedPath = new haxe.io.Path(game_path);
		trace(convertedPath.toString);
		var path = "2.6_CG107_mux.usm";
		var strPath = '2.6_CG107_mux_ru.srt';
		// usmTestReadWrite(path);
		new UsmPatcher(path).patchFile(strPath);
	}

	static function multipleFilesProcessing(game_path:String, strPath:String) {
		// "C:\Program Files\Honkai Impact 3rd glb"
		// Games/BH3_Data/StreamingAssets/Video
		game_path = Path.removeTrailingSlashes(game_path);
		var usm_path = '/Games/BH3_Data/StreamingAssets/Video';
		if (FileSystem.exists(game_path + usm_path)) {
			trace('Ok!');
			usm_path = game_path + usm_path;
		} else if (FileSystem.exists(game_path + '/BH3_Data/StreamingAssets/Video')) {
			trace('Ok!');
			usm_path = game_path + usm_path;
		} else {
			trace('Incorrect path!');
			usm_path = '';
		}
		var i = 0;
		// while
		var path = '';
		new UsmPatcher(path).patchFile(strPath);
	}

	static function configFile() {
		var config_path = "config.json";
	}

	static function usmTestReadWrite(location:String) {
		// USM Read
		var input = sys.io.File.read(location);
		trace('Start of usm file reading: "$location"');
		var thisUSM = new UsmReader(input).read(-1, false);
		// trace(thisUSM[25].text);
		input.close();
		var save_location = "test/2.6_CG107_mux.usm";

		var output = sys.io.File.write(save_location);
		trace('Start of usm file writing: "$save_location"');
		new SbtWriter(output).write(thisUSM);
		output.close();
		trace('end.');
	}
}
