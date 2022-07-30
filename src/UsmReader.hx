package;

import haxe.io.Bytes;
import UsmData;

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
		var usmBlock = [];
		var it = 0;
		while (it < fileLength) {
			// var curPos = i.tell();
			var rawBytesLength = UsmTools.skipData(i);
			// var chunkPos = i.tell();
			// var chunkLength = chunkPos - curPos;
			usmBlock[it] = parseSbt();
			if (usmBlock[it].endTag == true) {
				usmBlock.pop();
				break;
			}
			if (onlySbt == false) {
				trace('only sbt false');
				i.seek(-rawBytesLength, SeekCur); // + длина блока сбт
				// добавить i.seek() для возврата на позицию до чтения parseSbt();
				var previousChunkData = UsmTools.readBytesInput(i, rawBytesLength);
				usmBlock[it] = previousChunkData;
				it++;
			}
			if (onlySbt == false && usmBlock[it].type == 0) {
				break;
			}
			it++;
		}
		if (onlySbt == false) {
				trace('only sbt false');
		}
		it = 0;
		while (it < usmBlock.length) {
			if (usmBlock[it].type != 0 && usmBlock[it].endTag == false) {
				usmBlock.shift();
			} else
				it++;
		}
		if (sbtLang != -1) {
			it = 0;
			while (it < usmBlock.length) {
				if (usmBlock[it].langId != sbtLang) {
					usmBlock.splice(it, 1);
				} else
					it++;
			}
		}
		trace('Usm file has been read.');
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
			langId: 0,
			interval: 0,
			startTime: 0,
			endTime: 0,
			textLength: 0,
			text: ''
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
		i.bigEndian = false;
		if (type == 0) {
			i.readInt32(); // timestamp
			i.readInt32(); // unknown
			i.read(8); // unknown (always 0, padding?)
			result.langId = i.readInt32();
			result.interval = i.readInt32(); // always 1000
			result.startTime = i.readInt32();
			result.endTime = i.readInt32();
			result.textLength = i.readInt32();
			if (result.paddingSize > 0) {
				result.text = i.readString(result.textLength - 2);
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
