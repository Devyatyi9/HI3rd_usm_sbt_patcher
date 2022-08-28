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
		var fileData = read(true);
		if (fileData.length > 0) {
			var SrtData = readSrt(srt_path);
			checkSrt(SrtData);
			mergeData(fileData, SrtData);
			// USM Write
			// write(fileData);
			// USM Update
			update(fileData);
		}
	}

	// reading subtitles in usm file
	public function extractSubtitles(save_location = '', ?langId = -1) {
		if (langId == -1)
			langId = 1;
		var fileData = read(langId, true);
		if (fileData.length > 0) {
			var output = sys.io.File.write(save_location);
			trace('Start of srt file writing: "$save_location"');
			new SrtWriter(output).writeSrt(fileData);
			output.close();
		}
		// return fileData;
	}

	// writing subtitles (from srt) in txt format for Scaleform VideoEncoder - CRIWARE Medianoche
	public function writeTxt(SrtData:Array<SrtData>) {
		var output = sys.io.File.write(location);
		trace('Start of Scaleform txt file writing: "$location"');
		new SrtWriter(output).writeTxt(SrtData);
		output.close();
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

	function update(thisUSM:Array<SbtTag>) {
		var output = sys.io.File.update(location);
		trace('Start of usm file updating: "$location"');
		new SbtWriter(output).update(thisUSM);
		output.close();
	}

	function readSrt(location:String) {
		var input = sys.io.File.read(location);
		trace('Start of srt file reading: "$location"');
		var thisSrt = new SrtReader(input).read();
		input.close();
		return thisSrt;
	}

	function checkSrt(thisSrt:Array<SrtData>) {
		var i = 0;
		while (i < thisSrt.length) {
			try {
				var number = thisSrt[i].number;
				if (number < 0) {}
				var timeStart = thisSrt[i].timeStart;
				if (timeStart < 0) {}
				var timeEnd = thisSrt[i].timeEnd;
				if (timeEnd < 0) {}
				var text = thisSrt[i].text;
				if (text.length < 0) {}
			} catch (e:Exception) {
				trace('Data error in this srt file, element $i.\n' + e.message);
				throw(e.stack);
			}
			i++;
		}
	}

	function mergeData(fileData:Array<SbtTag>, SrtData:Array<SrtData>) {
		trace('Start of merging data.');
		var usmI = 0;
		var srtI = 0;
		while (usmI < fileData.length) {
			if (srtI >= SrtData.length) {
				break;
			}
			if (fileData[usmI].isSbt == true && fileData[usmI].langId == 1) {
				fileData[usmI].timestamp = SrtData[srtI].timeStart;
				fileData[usmI].startTime = SrtData[srtI].timeStart;
				fileData[usmI].endTime = SrtData[srtI].timeEnd - SrtData[srtI].timeStart;
				fileData[usmI].text = SrtData[srtI].text;
				fileData[usmI].textLength = Bytes.ofString(SrtData[srtI].text).length;
				fileData[usmI].textLengthEquals = false;
				fileData[usmI].paddingSize = 0;
				fileData[usmI].chunkLength = 44 + fileData[usmI].textLength;
				srtI++;
			}
			usmI++;
		}
	}
}
