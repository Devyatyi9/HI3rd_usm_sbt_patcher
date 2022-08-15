package usm;

import haxe.io.Bytes;
import usm.UsmData;

class SbtWriter {
	var o:sys.io.FileOutput;

	public function new(o) {
		this.o = o;
		o.bigEndian = true;
	}

	public function write(usm:Array<SbtTag>) {
		var it = 0;
		while (it < usm.length) {
			if (usm[it].isSbt == false) {
				o.write(usm[it].previousRawBytes);
			} else {
				o.writeString("@SBT");
				o.writeInt32(usm[it].chunkLength);
				o.writeString('\x00');
				o.writeByte(24); // \x18
				o.writeString('\x00');
				o.writeByte(usm[it].paddingSize);
				o.writeInt32(usm[it].type);
				o.writeInt32(usm[it].timestamp);
				// E8 03 00 00
				o.writeInt32(1000);
				o.bigEndian = false;
				o.writeString('\x00\x00\x00\x00');
				o.writeString('\x00\x00\x00\x00');
				o.writeInt32(usm[it].langId);
				o.writeInt32(usm[it].interval);
				o.writeInt32(usm[it].startTime);
				o.writeInt32(usm[it].endTime);
				o.writeInt32(usm[it].textLength);
				o.writeString(usm[it].text);
				if (usm[it].paddingSize > 0) {
					var paddingLength = usm[it].chunkLength - 44 - usm[it].textLength + 2; // -8?
					// var paddingLength = usm[it].paddingSize + 2;
					if (usm[it].textLengthEquals == true)
						paddingLength = paddingLength - 2;
					// trace('paddingLength: ' + paddingLength);
					// trace('textLength: ' + usm[it].textLength);
					// trace('text: ' + usm[it].text.length);
					var i = 0;
					while (i < paddingLength) {
						o.writeString('\x00');
						i++;
					}
				}
				o.bigEndian = true;
			}
			it++;
		}
		UsmTools.writeMarker(o);
		trace('Usm file has been write.');
	}

	public function update(usm:Array<SbtTag>) {
		// be sure to use sys.io.File.update, not write.
		// need sbt from all language tracks
		var it = 0;
		while (it < usm.length) {
			if (usm[it].isSbt == true && usm[it].langId == 1) {
				if (usm[it - 1] == null) {
					trace('Stop right there criminal scum!');
				}
				if (usm[it + 1] == null) {
					trace('Stop right there criminal scum!');
				}
				//
				var nextChunkPos = usm[it + 1].startPos;
				var nextChunkSize = usm[it + 1].chunkLength + 8;
				var currentEndPos = usm[it].startPos + usm[it].chunkLength + 8;
				// если конечная позиция текущего (старого) чанка находиться далеко от начала позиции следующего чанка (т.е. меньше)
				var currentOldEndPos = usm[it].startPos + usm[it].oldChunkLength + 8;
				if (currentOldEndPos < nextChunkPos) {
					var previousChunkPos = usm[it - 1].startPos;
					var summarySize = currentOldEndPos - previousChunkPos;
					if (usm[it].textLength <= summarySize - 55) {
						o.seek(previousChunkPos, SeekBegin);
						while (summarySize > 0) {
							o.writeString('\x00');
							summarySize--;
						}
						o.seek(previousChunkPos, SeekBegin);
					} else {
						trace('Warning! This text is too big!');
						throw('Stop!');
					}
				} else
					o.seek(usm[it].startPos, SeekBegin);
				o.writeString("@SBT");
				o.writeInt32(usm[it].chunkLength);
				o.writeString('\x00');
				o.writeByte(24); // \x18
				o.writeString('\x00');
				o.writeByte(usm[it].paddingSize);
				o.writeInt32(usm[it].type);
				o.writeInt32(usm[it].timestamp);
				// E8 03 00 00
				o.writeInt32(1000);
				o.bigEndian = false;
				o.writeString('\x00\x00\x00\x00');
				o.writeString('\x00\x00\x00\x00');
				o.writeInt32(usm[it].langId);
				o.writeInt32(usm[it].interval);
				o.writeInt32(usm[it].startTime);
				o.writeInt32(usm[it].endTime);
				o.writeInt32(usm[it].textLength);
				o.writeString(usm[it].text);
				// если позиция начала следующего чанка находится в области текущего чанка
				if (currentEndPos > nextChunkPos) {
					var difference = currentEndPos - nextChunkPos;
					var fillerLength = nextChunkSize - difference;
					while (fillerLength > 0) {
						o.writeString('\x00');
						fillerLength--;
					}
				}
				o.bigEndian = true;
			}
			it++;
		}
		UsmTools.writeMarker(o);
		trace('Usm file has been updated.');
	}
}
