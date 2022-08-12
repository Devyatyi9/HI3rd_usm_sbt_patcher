package srt;

import usm.*;
import usm.UsmData.StrData;

using StringTools;

class SrtReader {
	var i:sys.io.FileInput;

	public function new(i) {
		this.i = i;
		i.bigEndian = false;
	}

	public function read():Array<StrData> {
		var fileLength = UsmTools.checkInputLength(i);
		var sectionBlock = [];
		var it = 0;
		it = checkEncoding();
		while (it < fileLength - 30) {
			var result = readSection();
			sectionBlock[result.number - 1] = result;
			it = i.tell();
		}
		trace('Srt file has been read.');
		return sectionBlock;
	}

	function checkEncoding() {
		var marker = i.read(3);
		if (marker.toHex() == 'efbbbf') {
			trace('UTF-8 BOM.');
		} else {
			i.seek(0, SeekBegin);
		}
		return i.tell();
	}

	function checkSpace() {
		var space = '\x20';
		while (space.isSpace(0)) {
			space = i.readString(1);
		}
		// i.seek(-1, SeekCur);
		return space;
	}

	function timeParser() {}

	function readSection():StrData {
		// variables
		var timeStartS = '';
		var arrow = '';
		var timeEndS = '';

		// number
		var numberS = i.readLine();
		while (numberS.length == 0) {
			numberS = i.readLine();
		}
		// timeStart
		while (timeStartS.length < 12) {
			timeStartS += checkSpace();
			if (timeStartS.charAt(timeStartS.length - 1) == '-') {
				arrow = timeStartS.charAt(timeStartS.length - 1);
				timeStartS = timeStartS.substr(0, timeStartS.length - 1);
				timeStartS = timeStartS.rpad('0', 12);
				break;
			}
		}
		// Arrow
		while (arrow.length < 3) {
			arrow += checkSpace();
		}
		// timeEnd
		while (timeEndS.length < 12) {
			timeEndS += checkSpace();
		}
		// line break
		i.readLine();
		// text
		var text = i.readLine();
		var stopLoop = false;
		try {
			var textNext = i.readLine();
			while (textNext.length > 0 || stopLoop == true) {
				text = text + '\n' + textNext;
				textNext = i.readLine();
			}
		} catch (e:haxe.io.Eof) {
			stopLoop = true;
			trace(e + ' pos: ${i.tell()}');
		}
		// String to int
		var number = Std.parseInt(numberS);
		// Time start
		var timeSArray = timeStartS.split(':');
		var timeStartSpop = timeSArray.pop();
		var timeStartSplit = timeStartSpop.split(',');
		var timeSArrayConcat = timeSArray.concat(timeStartSplit);
		timeStartS = timeSArrayConcat.join('');
		var timeStart = Std.parseInt(timeStartS);
		// Time end
		var timeEArray = timeEndS.split(':');
		var timeEndSpop = timeEArray.pop();
		var timeEndSplit = timeEndSpop.split(',');
		var timeEArrayConcat = timeEArray.concat(timeEndSplit);
		timeEndS = timeEArrayConcat.join('');
		var timeEnd = Std.parseInt(timeEndS);

		return {
			number: number,
			timeStart: timeStart,
			timeEnd: timeEnd,
			text: text
		}
	}
}
