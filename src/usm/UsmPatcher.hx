package usm;

import haxe.Exception;
import usm.UsmData;
import haxe.io.Bytes;
import srt.*;

class UsmPatcher {
	var location:String;

	public function new(location) {
		this.location = location;
	}

	public function patchFile(srt_path:String) {
		// USM Read
		var fileData = read(false);
		if (fileData.length > 0) {
			var strData = readStr(srt_path);
			checkStr(strData);
			mergeData(fileData, strData);
			// USM Write
			write(fileData);
		}
	}

	public function extractSubtitles() {
		var fileData = read(1, true);
		// if (fileData.length > 0)
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
		trace('Start of srt file reading: "$location"');
		var thisStr = new SrtReader(input).read();
		input.close();
		return thisStr;
	}

	function checkStr(thisStr:Array<StrData>) {
		var i = 0;
		while (i < thisStr.length) {
			try {
				var number = thisStr[i].number;
				if (number < 0) {}
				var timeStart = thisStr[i].timeStart;
				if (timeStart < 0) {}
				var timeEnd = thisStr[i].timeEnd;
				if (timeEnd < 0) {}
				var text = thisStr[i].text;
				if (text.length < 0) {}
			} catch (e:Exception) {
				trace('Data error in this str file, element $i.\n' + e.message);
				throw(e.stack);
			}
			i++;
		}
	}

	function mergeData(fileData:Array<SbtTag>, strData:Array<StrData>) {
		trace('Start of merging data.');
		var usmI = 0;
		var srtI = 0;
		while (usmI < fileData.length) {
			if (srtI >= strData.length) {
				break;
			}
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
