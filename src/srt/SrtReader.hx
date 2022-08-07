package srt;

import usm.*;
import usm.UsmData.StrData;

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
		while (it < fileLength) {
			var result = readSection();
			sectionBlock[result.number - 1] = result;
			it = i.tell();
		}
		return sectionBlock;
	}

	function readSection():StrData {
		var numberS = i.readLine();
		var timeStartS = i.readString(12);
		i.read(5);
		var timeEndS = i.readString(12);
		i.readLine();
		var text = i.readLine();
		var textNext = i.readLine();
		while (textNext.length > 0) {
			text = text + '\n' + textNext;
			textNext = i.readLine();
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
