package;

import usm.UsmData;
import usm.UsmData.ConfigFile;
import sys.FileSystem;
import haxe.io.Path;
import usm.*;
import srt.*;

using StringTools;

class Test {
	static public function main():Void {
		trace('author: Devyatyi9');
		trace("Test launch");
		// var path = "Story_06.usm";
		// var srtPath = 'srt/Story_06_en.srt';
		// var txtPath = 'Story_06_en.txt';
		// usmTestReadWrite(path);
		// new UsmPatcher(path).patchFile(srtPath);
		// readSrt(srtPath);
		//
		// var configData = configFile(); // test_config, true
		// var loadedConfig = checkConfig(configData.game_path, configData.srt_path, configData.postfix);
		// multipleFilesProcessing(loadedConfig);
		//
		// var srtData = readSrt(srtPath);
		// writeTxt(txtPath, srtData);
		//
		cmdRun();
	}

	static function cmdRun() {
		var args = Sys.args();
		trace(args);
		args = ['-srt-convert', '-multiple', 'srt', 'txt/more/and_moore/yesss'];
		trace('Use -h for help.');
		var i = 0;
		while (i < args.length) {
			// srt > txt
			// first
			if (args[i] == '-srt-convert') {
				// second
				if (args[i + 1] == '-single') {
					// third
					var srt_location = args[i + 2];
					var save_location = '';
					if (args.length > 3) {
						// fourth
						save_location = args[i + 3];
					} else {
						var new_save_location = new haxe.io.Path(srt_location);
						save_location = new_save_location.dir + '/' + new_save_location.file + '.txt';
					}
					var srtData = readSrt(srt_location);
					new UsmPatcher(save_location).writeTxt(srtData);
					// second
				} else if (args[i + 1] == '-multiple') {
					// third
					var srt_location = args[i + 2];
					var save_location = '';
					if (args.length > 3) {
						// fourth
						save_location = args[i + 3];
					}
					multipleWriteTxt(srt_location, save_location);
				}
			} else if (args[i] == '-help' || args[i] == '-h') {
				trace('author: Devyatyi9');
				trace("srt to Scaleform's txt conversion: ");
				trace('-srt-convert -single|-multiple "srt_location" ("save_location")\n');
				trace('Example: ');
				trace('-srt-convert -single "srt/Story_06_en.srt" "Story_06_en.txt"');
				trace('-srt-convert -multiple "srt" "output/txt"');
			}
			i++;
		}
	}

	static function checkConfig(game_path:String, srtPath:String, postfix:String) {
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
		srtPath = Path.normalize(srtPath);
		srtPath = Path.removeTrailingSlashes(srtPath);
		srtPath = srtPath + '/';
		if (FileSystem.exists(srtPath)) {
			trace('Srt path is correct.');
		} else {
			FileSystem.createDirectory(srtPath);
			trace('Srt folder has been created: ' + srtPath);
			trace('Please, place *.srt files in: ' + FileSystem.absolutePath(srtPath));
		}
		trace('Postfix for srt files is "$postfix".');
		return {
			usm_path: usm_path,
			srtPath: srtPath,
			postfix: postfix
		}
	}

	static function multipleFilesProcessing(config:{usm_path:String, srtPath:String, postfix:String}) {
		// Srt files
		var srtFiles = FileSystem.readDirectory(config.srtPath);
		if (srtFiles.length == 0) {
			throw('*.srt files not found, please, place it in: ' + FileSystem.absolutePath(config.srtPath));
		}
		// trace(srtFiles);
		// Usm files
		var usmFiles = FileSystem.readDirectory(config.usm_path);
		if (usmFiles.length == 0) {
			throw('*.usm files not found in: ' + FileSystem.absolutePath(config.usm_path));
		}
		var iUsm = 0;
		var iSrt = 0;
		while (iUsm < usmFiles.length) {
			while (iSrt < srtFiles.length) {
				var thisUsm = usmFiles[iUsm];
				var thisUsmPath = new haxe.io.Path(thisUsm);
				// trace(thisUsmPath);
				if (thisUsmPath.ext == 'usm') {
					// trace('next.');
					var thisSrt = srtFiles[iSrt];
					var thisSrtPath = new haxe.io.Path(thisSrt);
					// trace(thisSrtPath);
					if (thisSrtPath.ext == 'srt') {
						// trace('go next.');
						var thisSrtNotPostfix = thisSrtPath.file.endsWith(config.postfix);
						if (thisUsmPath.file == thisSrtPath.file) {
							new UsmPatcher(usmFiles[iUsm]).patchFile(srtFiles[iSrt]);
						} else if (thisSrtNotPostfix == true) {
							// trace('test');
							var thisSrtTrimmed = thisSrtPath.file.substr(0, thisSrtPath.file.length - config.postfix.length);
							if (thisUsmPath.file == thisSrtTrimmed) {
								new UsmPatcher(config.usm_path + usmFiles[iUsm]).patchFile(config.srtPath + srtFiles[iSrt]);
							}
						}
					}
				}
				iSrt++;
			}
			iSrt = 0;
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
		if (thisUSM.length > 0) {
			var save_location = "test/__2.6_CG107_mux.usm";

			var output = sys.io.File.write(save_location);
			trace('Start of usm file writing: "$save_location"');
			new SbtWriter(output).write(thisUSM);
			output.close();
			trace('end.');
		}
	}

	static function readSrt(location:String) {
		var input = sys.io.File.read(location);
		trace('Start of srt file reading: "$location"');
		var thisSrt = new SrtReader(input).read();
		input.close();
		return thisSrt;
	}

	static function writeSrt(location:String) {}

	static function writeTxt(location:String, SrtData:Array<SrtData>) {
		var output = sys.io.File.write(location);
		trace('Start of Scaleform txt file writing: "$location"');
		new SrtWriter(output).writeTxt(SrtData);
		output.close();
	}

	static function multipleWriteTxt(srt_location:String, save_location:String) {
		srt_location = Path.removeTrailingSlashes(srt_location);
		srt_location = Path.normalize(srt_location);
		var srtFiles = FileSystem.readDirectory(srt_location);

		var it = 0;
		while (it < srtFiles.length) {
			var srt_file = srt_location + '/' + srtFiles[it];
			var srtData = readSrt(srt_file);

			if (save_location.length > 0) {
				save_location = Path.removeTrailingSlashes(save_location);
				save_location = Path.normalize(save_location);

				var srt_location = new haxe.io.Path(srtFiles[it]);
				save_location = save_location + '/' + srt_location.file + '.txt';
			} else {
				var new_save_location = new haxe.io.Path(srtFiles[it]);
				save_location = srt_location + '/' + new_save_location.file + '.txt';
			}
			var dir_save_location = new haxe.io.Path(save_location);
			FileSystem.createDirectory(dir_save_location.dir);
			new UsmPatcher(save_location).writeTxt(srtData);
			it++;
		}
	}
}
