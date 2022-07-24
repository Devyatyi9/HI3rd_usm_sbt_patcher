package;

import sys.io.FileInput;

class UsmTools {
	public static function checkInputLength(i:FileInput) {
		var cur = i.tell();
		i.seek(0, SeekBegin);
		var l = i.readAll().length;
		i.seek(cur, SeekBegin);
		return l;
	}

	public static function skipData(i:FileInput) {
		var tag_SBT = 'SBT';
		var fileLength = UsmTools.checkInputLength(i);
		var byteChar:Int;
		var tag:String;
		// trace('cur pos: ' + i.tell());
		var it = 0;
		it = i.tell();
		while (it < (fileLength - 3)) {
			byteChar = i.readByte();
			if (byteChar == 64) {
				it = it + 3;
				tag = i.readString(3);
				if (tag == tag_SBT)
					break;
				else if (tag != tag_SBT)
					it += skipTagData(i, tag);
			}
			it++;
		}
		if (it == (fileLength - 3)) {
			trace("@SBT tag not found in this file.");
			throw(haxe.Exception);
		}
		i.seek(-4, SeekCur);
		// trace('cur pos: ' + i.tell());
		return it - 4;
	}

	static function skipTagData(i:FileInput, tag:String) {
		i.bigEndian = true;
		var chunkSize = 0;
		if (tag == 'UTF' || tag == 'SFV' || tag == 'SFA') {
			chunkSize = i.readInt32();
			i.seek(chunkSize, SeekCur);
		}
		i.bigEndian = false;
		return chunkSize + 4;
	}
}
