package srt;

import haxe.Exception;
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
		var sectionBlock:Array<SrtData> = [];
		var sectionPosition = [];
		var duplicateIndex = -1;
		var it = 0;
		it = checkEncoding();
		while (it < fileLength - 30) {
			var result = readSection();
			if (sectionBlock.length > 0) {
				// проверка повторяющихся блоков
				// и проверка склейки блоков, не учитываются случаи когда предпоследний блок склеен с последним
				var arrIndex = sectionBlock.length - 1;
				if (sectionBlock[arrIndex].number == result.number) {
					if ((sectionBlock[arrIndex].timeStart == result.timeStart) && (sectionBlock[arrIndex].timeEnd == result.timeEnd)) {
						trace('Error in index: ${arrIndex}, number: ${sectionBlock[arrIndex].number}! Duplicate block.');
						throw('This is the wrong end!');
					} else {
						duplicateIndex = arrIndex;
					}
				} else if ((sectionBlock[arrIndex].number + 1) != result.number) {
					trace('Error in index: ${arrIndex}, number: ${sectionBlock[arrIndex].number}! Let\'s fix this.');
					if (sectionBlock.length > 1) {
						var number = sectionBlock[arrIndex].number + 1;
						var posNumber = '' + number;
						result = readSection(sectionPosition[arrIndex - 1], posNumber);
					} else {
						result = readSection(0, '2');
					}
					it = i.tell();
					sectionPosition[sectionBlock.length - 1] = it;
					sectionBlock[result.number - 1] = result;
					continue;
				}
			}
			sectionBlock[sectionPosition.length] = result; // result.number - 1
			it = i.tell();
			sectionPosition[sectionBlock.length - 1] = it;
		}
		if (duplicateIndex != -1) {
			// result.number = sectionBlock[arrIndex].number + 1;
			while (duplicateIndex < sectionBlock.length) {
				sectionBlock[duplicateIndex].number = duplicateIndex + 1;
				duplicateIndex++;
			}
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
				trace('Subtitle time mismatch in first part. Pos: ' + i.tell());
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
				trace('Subtitle time mismatch in second part. Pos: ' + i.tell());
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
				trace('Subtitle time mismatch in third part. Pos: ' + i.tell());
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
				trace('Subtitle time mismatch in fourth part. Pos: ' + i.tell());
				fourth = fourth.lpad('0', 3);
			}
		}
		var resultString = first + second + third + fourth;
		return {
			resultString: resultString,
			anotherChar: anotherChar
		}
	}

	function readSection(?position = -1, ?pNumber = '-1'):SrtData {
		if (position != -1) {
			i.seek(position, SeekBegin);
		}
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
				// проверка склейки блоков
				if (position != -1) {
					if (textNext == pNumber) {
						i.seek(-textNext.length, SeekCur); // i.seek(-(textNext.length + 2), SeekCur);
						var diffNumber = i.readString(textNext.length);
						if (diffNumber != textNext) {
							i.seek(-(textNext.length + 1), SeekCur);
							diffNumber = i.readString(textNext.length);
							if (diffNumber != textNext) {
								i.seek(-(textNext.length + 1), SeekCur);
								diffNumber = i.readString(textNext.length);
								i.seek(-(textNext.length), SeekCur);
								if (diffNumber != textNext) {
									i.seek(-(textNext.length), SeekCur);
								}
							}
							// trace(diffNumber);
						} else
							i.seek(-textNext.length, SeekCur);
						break;
					}
				}
				text = text + '\\n' + textNext;
				textNext = i.readLine();
			}
		} catch (e:haxe.io.Eof) {
			stopLoop = true;
			trace(e);
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
