package usm;

import haxe.io.Bytes;
import usm.UsmData;

class UsmReader {
	var i:sys.io.FileInput;

	public function new(i) {
		this.i = i;
		i.bigEndian = false;
	}

	public function read(?sbtLang = -1, ?onlySbt = true) {
		if (i.readString(4) != 'CRID')
			throw 'This file not supported.';
		var sbtBlock = processing(sbtLang, onlySbt);
		return sbtBlock;
	}

	function processing(?sbtLang = -1, ?onlySbt = true) {
		var fileLength = UsmTools.checkInputLength(i);
		var rawBytesLength = -1;
		var previousDataPos = 0;
		var endValue = 0;
		var usmBlock = [];
		var it = 0;
		while (it < fileLength) {
			// отбрасывание последнего блока SBT без субтитров и выход из цикла
			if (usmBlock.length > 1) {
				if (usmBlock[it - 1].endTag == true) {
					i.seek(usmBlock[it - 1].startPos, SeekBegin);
					usmBlock.pop();
					break;
				}
			}
			// trace('before rawBytesLength tell: ' + i.tell());
			endValue = UsmTools.skipData(i, fileLength); // rawBytesLength
			if (endValue == -1) {
				usmBlock = [];
				break;
			}
			var beginPos = i.tell();
			// var chunkPos = i.tell();
			// var chunkLength = chunkPos - curPos;
			if (onlySbt == true) {
				usmBlock[it] = parseSbt();
			} else {
				// trace('only sbt false');
				// trace('after rawBytesLength tell: ' + i.tell());
				rawBytesLength = beginPos - previousDataPos;
				// если SBT блоки идут друг с за другом
				if (usmBlock.length > 1) {
					if (usmBlock[it - 1].isSbt == true) {
						var sbtEndPos = usmBlock[it - 1].startPos + usmBlock[it - 1].chunkLength + 8;
						if (beginPos == sbtEndPos) {
							// trace('sbt pos equal');
							usmBlock[it] = parseSbt();
							if (usmBlock[it].paddingSize > 0) {
								var paddingLength = usmBlock[it].chunkLength - 44 - usmBlock[it].textLength;
								if (usmBlock[it].textLengthEquals == true)
									paddingLength -= 2;
								// trace('paddingLength: ' + paddingLength);
								i.seek(paddingLength, SeekCur);
							}
							previousDataPos = i.tell();
							it++;
							continue;
						}
					}
				}
				i.seek(-rawBytesLength, SeekCur); // + длина блока сбт
				// trace('skip tell: ' + i.tell());
				// добавить i.seek() для возврата на позицию до чтения parseSbt();
				var previousChunkData = UsmTools.readBytesInput(i, rawBytesLength);
				// trace('read skip tell: ' + i.tell());
				usmBlock[it] = previousChunkData;
				it++;
				usmBlock[it] = parseSbt();
				if (usmBlock[it].type != 0) {
					var blockPos = i.tell();
					// trace("blockPos " + blockPos);
					var skipLength = blockPos - usmBlock[it].startPos;
					// trace("skipLength " + skipLength);
					i.seek(-skipLength, SeekCur);
					var previousChunkData = UsmTools.readBytesInput(i, skipLength);
					usmBlock[it] = previousChunkData;
				}
				previousDataPos = i.tell();
			}
			it++;
		}
		if (onlySbt == false && endValue != -1) {
			// trace(i.tell());
			// trace('only sbt false');
			previousDataPos = i.tell();
			// rawBytesLength = usmBlock[usmBlock.length - 1].startPos + usmBlock[usmBlock.length - 1].chunkLength + 8;
			rawBytesLength = fileLength - previousDataPos;
			// i.seek(-rawBytesLength, SeekEnd);
			// i.seek(rawBytesLength, SeekBegin);
			// rawBytesLength = fileLength - rawBytesLength;
			var previousChunkData = UsmTools.readBytesInput(i, rawBytesLength);
			usmBlock[usmBlock.length] = previousChunkData;
		}
		it = 0;
		while (it < usmBlock.length) {
			if (usmBlock[it].type != 0 && usmBlock[it].endTag == false && usmBlock[it].isSbt == true) {
				usmBlock.shift();
			} else
				it++;
		}
		if (sbtLang != -1 && endValue != -1) {
			it = 0;
			while (it < usmBlock.length) {
				if (usmBlock[it].langId != sbtLang) {
					usmBlock.splice(it, 1);
				} else
					it++;
			}
		}
		if (endValue != -1) {
			trace('Usm file has been read.');
		}
		return usmBlock;
	}

	/* 
		langId:
		0 - china
		1 - english
		4 - french
		5 - german
	 */
	function parseSbt():SbtTag {
		var result = {
			isSbt: true,
			previousRawBytes: Bytes.alloc(0),
			startPos: 0,
			endTag: false,
			chunkLength: 0,
			paddingSize: 0, // haxe.io.Bytes.Bytes.alloc(0)
			type: -1,
			timestamp: 0,
			langId: 0,
			interval: 0,
			startTime: 0,
			endTime: 0,
			textLength: 0,
			text: '',
			textLengthEquals: false
		};
		result.startPos = i.tell();
		i.readInt32(); // @SBT
		i.bigEndian = true;
		result.chunkLength = i.readInt32();
		i.read(2); // unknown 0x18 - probably Payload offset (24b)
		i.read(1);
		var paddingSize = i.read(1); // padding bytes
		result.paddingSize = haxe.io.Bytes.fastGet(paddingSize.getData(), 0);
		var type = i.readInt32();
		result.type = type;
		if (type == 0) {
			result.timestamp = i.readInt32(); // timestamp
			i.bigEndian = false;
			i.readInt32(); // unknown
			i.read(8); // unknown (always 0, padding?)
			result.langId = i.readInt32();
			result.interval = i.readInt32(); // always 1000
			result.startTime = i.readInt32();
			result.endTime = i.readInt32();
			// trace(result.paddingSize);
			result.textLength = i.readInt32();
			if (result.paddingSize > 0) {
				#if !static
				result.text = i.readString(result.textLength - 2);
				var addString = i.readString(2);
				// trace(addString);
				if (addString.length > 0 && addString != '\x00\x00') {
					result.textLengthEquals = true;
					// trace(addString.charAt(2).length);
					result.text += addString;
				}
				// trace(result.text);
				#else
				result.text = i.readString(result.textLength);
				var textBytesLength = Bytes.ofString(result.text).length;
				if (textBytesLength == result.textLength)
					result.textLengthEquals = true;
				#end
			} else
				result.text = i.readString(result.textLength);
		} else if (type == 2) {
			i.readInt32();
			i.readInt32();
			i.read(8);
			var text = i.readString(16);
			if (text == '#CONTENTS END   ') {
				result.endTag = true;
			}
		}
		return result;
	}
}
