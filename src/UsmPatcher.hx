package;

import sys.io.FileOutput;
import sys.io.FileInput;

class UsmPatcher {
	var location:String;

	public function new(location) {
		this.location = location;
	}

	public function patchFile() {
		// USM Read
		var fileData = usmRead();
		// USM Write
		usmWrite(fileData);
	}

	function usmRead() {
		var input = sys.io.File.read(location);
		trace('Start of usm file reading: "$location"');
		var fileLength = UsmTools.checkInputLength(input);
		var thisUSM = new UsmReader(input).read(1);
		input.seek(0, SeekBegin);
		var bytesArray = [];
		var mapInfo = new Map<Int, Array<Int>>();
		var numOfElements = thisUSM.length;
		var curPos = input.tell();
		var it = 0;
		while (curPos <= thisUSM[numOfElements - 1].startPos) {
			curPos = input.tell();
			if (curPos == thisUSM[numOfElements - 1].startPos)
				break;
			var chunkPos = thisUSM[it].startPos;
			if (curPos != chunkPos) {
				var chunkLength = chunkPos - curPos;
				var chunkData = UsmTools.readBytesInput(input, chunkLength);
				bytesArray.push(chunkData);
				mapInfo[it] = [0, it];
				it++;
				mapInfo[it] = [1, it];
			} else
				mapInfo[it] = [1, it];
			it++;
		}
		/*
			RawBytes = 0
			Sbt = 1
			map - key - type, order (value)
		 */
		var curPos = input.tell();
		var chunkData = UsmTools.readBytesInput(input, fileLength - curPos);
		bytesArray.push(chunkData);
		mapInfo[it + 1] = [0, it + 1];
		trace('RawBytes length: ' + bytesArray.length);
		trace('Sbt length: ' + thisUSM.length);
		// bytesArray[0].startPos;
		// thisUSM[0].startPos;
		input.close();
		var result = {
			mapInfo: mapInfo,
			bytesArray: bytesArray,
			thisUSM: thisUSM
		}
		return result;
	}

	function usmWrite(fileData:{mapInfo:haxe.ds.Map<Int, Array<Int>>, bytesArray:Array<{startPos:Int, rawBytes:haxe.io.Bytes}>, thisUSM:Array<UsmData.SbtTag>}) {
		// var output = sys.io.File.write(location);
		trace('Start of usm file writing: "$location"');
		// fileData.mapInfo
		// trace(fileData.mapInfo.keys());
		for (key in fileData.mapInfo.keys()) {
			var value = fileData.mapInfo[key];
			trace('$key in $value');
		}
		var it = 0;
		while (it < fileData.bytesArray.length + fileData.thisUSM.length) {
			var value = fileData.mapInfo[it];
			trace(value);
			var type = value[0];
			var order = value[1];
			if (type == 0) {
				fileData.bytesArray[order].rawBytes;
			} else
				fileData.thisUSM[order];
			it++;
		}
		trace('test');
		// new SbtWriter(output).write();
		// output.close();
	}
}
