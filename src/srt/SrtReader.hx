package srt;

import usm.*;
import usm.UsmData.SrtData;

using StringTools;

class SrtReader {
	var i:sys.io.FileInput;

	public function new(i) {
		this.i = i;
		i.bigEndian = false;
	}

	public function read():Array<SrtData> {
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

	function timeParser(?newChar = '') {
		var r = ~/[0-9]/i;
		var anotherChar = '';
		// 2
		var first = '';
		if (newChar.length > 0)
			first = newChar;
		while (first.length < 2) {
			var char = checkSpace();
			if (r.match(char)) {
				first += char;
			} else {
				trace('Subtitle time mismatch in first part.');
				i.seek(-1, SeekCur);
				first = first.lpad('0', 2);
			}
		}
		i.read(1);
		first += ':';
		// 2
		var second = '';
		while (second.length < 2) {
			var char = checkSpace();
			if (r.match(char)) {
				second += char;
			} else {
				trace('Subtitle time mismatch in second part.');
				i.seek(-1, SeekCur);
				second = second.lpad('0', 2);
			}
		}
		i.read(1);
		second += ':';
		// 2
		var third = '';
		while (third.length < 2) {
			var char = checkSpace();
			if (r.match(char)) {
				third += char;
			} else {
				trace('Subtitle time mismatch in third part.');
				i.seek(-1, SeekCur);
				third = third.lpad('0', 2);
			}
		}
		i.read(1);
		third += ',';
		// 3
		var fourth = '';
		while (fourth.length < 3) {
			var char = checkSpace();
			if (r.match(char)) {
				anotherChar = char;
				fourth += char;
			} else {
				trace('Subtitle time mismatch in fourth part.');
				fourth = fourth.lpad('0', 3);
			}
		}
		var resultString = first + second + third + fourth;
		return {
			resultString: resultString,
			anotherChar: anotherChar
		}
	}

	function readSection():SrtData {
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
		var timePars1 = timeParser();
		timeStartS = timePars1.resultString;
		// arrow = timePars1.anotherChar;
		// Arrow
		while (arrow.length < 3) {
			arrow += checkSpace();
		}
		// timeEnd
		timeEndS = timeParser().resultString;
		// line break
		i.readLine();
		// text
		var text = i.readLine();
		var stopLoop = false;
		try {
			var textNext = i.readLine();
			while (textNext.length > 0 || stopLoop == true) {
				text = text + '\\n' + textNext;
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
