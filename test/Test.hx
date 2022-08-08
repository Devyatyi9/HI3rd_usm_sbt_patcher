package;

import usm.UsmData.ConfigFile;
import sys.FileSystem;
import haxe.io.Path;
import usm.*;
import srt.*;

using StringTools;

class Test {
	static public function main():Void {
		trace("Test launch");
		var path = "start.usm";
		// var strPath = 'srt/CG04_batch_en.srt';
		usmTestReadWrite(path);
		// new UsmPatcher(path).patchFile(strPath);
		// readStr(strPath);
		//
		// var configData = configFile(); // test_config, true
		// var loadedConfig = checkConfig(configData.game_path, configData.srt_path, configData.postfix);
		// multipleFilesProcessing(loadedConfig);
	}

	static function checkConfig(game_path:String, strPath:String, postfix:String) {
		// "C:\\Program Files\\Honkai Impact 3rd glb"
		// Games/BH3_Data/StreamingAssets/Video/
		game_path = Path.normalize(game_path);
		game_path = Path.removeTrailingSlashes(game_path);
		var usm_path = '/Games/BH3_Data/StreamingAssets/Video/';
		if (FileSystem.exists(game_path + usm_path)) {
			trace('Game path is correct.');
			usm_path = game_path + usm_path;
			trace('Usm video path: ' + usm_path);
		} else if (FileSystem.exists(game_path + '/BH3_Data/StreamingAssets/Video/')) {
			trace('Game path is correct.');
			usm_path = game_path + usm_path;
			trace('Usm video path: ' + usm_path);
		} else {
			// usm_path = '';
			trace('Usm video path: ' + game_path + usm_path);
			throw "Incorrect game path!";
		}
		strPath = Path.normalize(strPath);
		strPath = Path.removeTrailingSlashes(strPath);
		strPath = strPath + '/';
		if (FileSystem.exists(strPath)) {
			trace('Str path is correct.');
		} else {
			FileSystem.createDirectory(strPath);
			trace('Str folder has been created: ' + strPath);
			trace('Please, place *.str files in: ' + FileSystem.absolutePath(strPath));
		}
		trace('Postfix for srt files is "$postfix".');
		return {
			usm_path: usm_path,
			strPath: strPath,
			postfix: postfix
		}
	}

	static function multipleFilesProcessing(config:{usm_path:String, strPath:String, postfix:String}) {
		// Srt files
		var strFiles = FileSystem.readDirectory(config.strPath);
		if (strFiles.length == 0) {
			throw('*.str files not found, please, place it in: ' + FileSystem.absolutePath(config.strPath));
		}
		// trace(strFiles);
		// Usm files
		var usmFiles = FileSystem.readDirectory(config.usm_path);
		if (usmFiles.length == 0) {
			throw('*.usm files not found in: ' + FileSystem.absolutePath(config.usm_path));
		}
		var iUsm = 0;
		var iStr = 0;
		while (iUsm < usmFiles.length) {
			while (iStr < strFiles.length) {
				var thisUsm = usmFiles[iUsm];
				var thisUsmPath = new haxe.io.Path(thisUsm);
				// trace(thisUsmPath);
				if (thisUsmPath.ext == 'usm') {
					// trace('next.');
					var thisStr = strFiles[iStr];
					var thisStrPath = new haxe.io.Path(thisStr);
					// trace(thisStrPath);
					if (thisStrPath.ext == 'srt') {
						// trace('go next.');
						var thisStrNotPostfix = thisStrPath.file.endsWith(config.postfix);
						if (thisUsmPath.file == thisStrPath.file) {
							new UsmPatcher(usmFiles[iUsm]).patchFile(strFiles[iStr]);
						} else if (thisStrNotPostfix == true) {
							// trace('test');
							var thisStrTrimmed = thisStrPath.file.substr(0, thisStrPath.file.length - config.postfix.length);
							if (thisUsmPath.file == thisStrTrimmed) {
								new UsmPatcher(config.usm_path + usmFiles[iUsm]).patchFile(config.strPath + strFiles[iStr]);
							}
						}
					}
				}
				iStr++;
			}
			iStr = 0;
			iUsm++;
		}
		trace('Finished.');
	}

	static function configFile(?config_data:ConfigFile, ?save:Bool) {
		config_data = {
			postfix: "_en",
			srt_path: "srt",
			game_path: "C:\\Program Files\\Honkai Impact 3rd glb"
		}
		var config_path = "config.json";
		if (save == true) {
			// Saving new config
			var config_file = haxe.Json.stringify(config_data, "\t");
			sys.io.File.saveContent('config.json', config_file);
			trace('Config saved!');
		} else if (FileSystem.exists(config_path)) {
			var config_file:ConfigFile = haxe.Json.parse(sys.io.File.getContent(config_path));
			config_data = config_file;
			trace('Config loaded.');
		} else {
			var config_file = haxe.Json.stringify(config_data, "\t");
			sys.io.File.saveContent("config.json", config_file);
			trace('New config saved.');
		}
		return config_data;
	}

	static function usmTestReadWrite(location:String) {
		// USM Read
		var input = sys.io.File.read(location);
		trace('Start of usm file reading: "$location"');
		var thisUSM = new UsmReader(input).read(-1, false);
		// trace(thisUSM[25].text);
		input.close();
		var save_location = "test/__2.6_CG107_mux.usm";

		var output = sys.io.File.write(save_location);
		trace('Start of usm file writing: "$save_location"');
		new SbtWriter(output).write(thisUSM);
		output.close();
		trace('end.');
	}

	static function readStr(location:String) {
		var input = sys.io.File.read(location);
		trace('Start of srt file reading: "$location"');
		var thisStr = new SrtReader(input).read();
		input.close();
		return thisStr;
	}
}
