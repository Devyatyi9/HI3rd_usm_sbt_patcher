package usm;

import sys.io.FileInput;
import sys.io.FileOutput;
import usm.UsmData;

class UsmTools {
	public static function checkInputLength(i:FileInput) {
		var cur = i.tell();
		i.seek(0, SeekBegin);
		var l = i.readAll().length;
		i.seek(cur, SeekBegin);
		return l;
	}

	public static function skipData(i:FileInput, ?fileLength = -1) {
		var theEnd = false;
		var result = 0;
		var tag_SBT = 'SBT';
		fileLength = UsmTools.checkInputLength(i);
		var byteChar:Int;
		var tag:String;
		// trace('cur pos: ' + i.tell());
		var it = 0;
		it = i.tell();
		while (it < (fileLength - 3)) {
			byteChar = i.readByte();
			if (byteChar == 64) {
				it++;
				// trace('cur pos: ' + i.tell());
				it = it + 3;
				tag = i.readString(3);
				// trace('cur pos: ' + i.tell());
				if (tag == tag_SBT)
					break;
				else if (tag != tag_SBT)
					it += skipChunkData(i, tag);
			} else
				it++;
		}
		if (it == (fileLength - 3) || it == fileLength) {
			trace("Eof, @SBT tag not found in this file.");
			theEnd = true;
			// throw(haxe.Exception);
		}
		i.seek(-4, SeekCur);
		// trace('cur pos: ' + i.tell());
		if (theEnd == true) {
			result = -1;
		} else {
			result = it - 4;
		}
		return result;
	}

	static function skipChunkData(i:FileInput, tag:String) {
		i.bigEndian = true;
		var chunkSize = 0;
		if (tag == 'UTF' || tag == 'SFV' || tag == 'SFA') {
			chunkSize = i.readInt32();
			i.seek(chunkSize, SeekCur);
		}
		i.bigEndian = false;
		return chunkSize + 4;
	}

	public static function readMarker(i:FileInput) {
		var result = false;
		var cur = i.tell();
		i.seek(28, SeekBegin);
		var mark = i.readString(4);
		i.seek(cur, SeekBegin);
		if (mark == '@RUS') {
			trace('The file mark has been read.');
			result = true;
		}
		return result;
	}

	public static function writeMarker(o:FileOutput) {
		o.seek(28, SeekBegin);
		o.writeString('@RUS');
		trace('The file has been marked.');
	}

	public static function readBytesInput(i:FileInput, length:Int):SbtTag {
		var startPos = i.tell();
		// trace("readBytesInput tell: " + startPos);
		var rawBytes = i.read(length);
		var result = {
			isSbt: false,
			previousRawBytes: rawBytes,
			startPos: startPos,
			endTag: false,
			chunkLength: 0,
			paddingSize: 0,
			type: -1,
			timestamp: 0,
			langId: 0,
			interval: 0,
			startTime: 0,
			endTime: 0,
			textLength: 0,
			text: '',
			textLengthEquals: false
		}
		return result;
	}
}
