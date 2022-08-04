package;

import haxe.io.Bytes;
import UsmData;

class SbtWriter {
	var o:sys.io.FileOutput;
	var i:sys.io.FileInput;

	public function new(?o, ?i) {
		this.o = o;
		this.i = i;
		o.bigEndian = true;
	}

	public function write(sbtLang = -1, sbtData:Array<StrData>) {
		// var fileLength = UsmTools.checkInputLength(i);
		var it = 0;
		while (it < sbtData.length) {
			UsmTools.skipData(i);
			trace('...');
			i.readInt32();
			i.bigEndian = true;
			var chunkLength = i.readInt32();
			i.read(2);
			i.read(2); // padding bytes
			var type = i.readInt32();
			i.bigEndian = false;
			if (type == 0) {
				i.readInt32(); // timestamp
				i.readInt32(); // unknown
				i.read(8); // unknown (always 0, padding?)
				var langId = i.readInt32();
				if (sbtLang == langId) {
					i.readInt32();
					o.writeInt32(sbtData[it].timeStart);
					o.writeInt32(sbtData[it].timeEnd - sbtData[it].timeStart);
					o.writeInt32(sbtData[it].text.length + 2);
					o.writeString(sbtData[it].text);
				}
			}
			it++;
		}
	}

	public function testWrite(usm:Array<SbtTag>) {
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
				o.bigEndian = true;
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
					var paddingLength = usm[it].chunkLength - 44 - usm[it].textLength + 2;
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
		trace('Usm file has been write.');
	}
}
