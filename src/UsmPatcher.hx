package;

import UsmData;
import haxe.io.Bytes;

class UsmPatcher {
	var location:String;

	public function new(location) {
		this.location = location;
	}

	public function patchFile(srt_path:String) {
		// USM Read
		var fileData = read(false);
		var strData = readStr(srt_path);
		mergeData(fileData, strData);
		// USM Write
		write(fileData);
	}

	public function extractSubtitles() {
		var fileData = read(1, true);
		return fileData;
	}

	function read(?langId = -1, ?onlySbt = true) {
		var input = sys.io.File.read(location);
		trace('Start of usm file reading: "$location"');
		var thisUSM = new UsmReader(input).read(langId, onlySbt);
		input.close();
		return thisUSM;
	}

	function write(thisUSM:Array<SbtTag>) {
		var output = sys.io.File.write(location);
		trace('Start of usm file writing: "$location"');
		new SbtWriter(output).write(thisUSM);
		output.close();
	}

	function readStr(location:String) {
		var input = sys.io.File.read(location);
		trace('start test srt.');
		var thisStr = new SrtReader(input).read();
		input.close();
		return thisStr;
	}

	function mergeData(fileData:Array<SbtTag>, strData:Array<StrData>) {
		var usmI = 0;
		var srtI = 0;
		while (usmI < fileData.length || srtI < strData.length) {
			if (fileData[usmI].isSbt == true && fileData[usmI].langId == 1) {
				fileData[usmI].startTime = strData[srtI].timeStart;
				fileData[usmI].endTime = strData[srtI].timeEnd - strData[srtI].timeStart;
				fileData[usmI].text = strData[srtI].text;
				fileData[usmI].textLength = Bytes.ofString(strData[srtI].text).length;
				fileData[usmI].textLengthEquals = false;
				fileData[usmI].paddingSize = 0;
				fileData[usmI].chunkLength = 44 + fileData[usmI].textLength;
				srtI++;
			}
			usmI++;
		}
	}
}
