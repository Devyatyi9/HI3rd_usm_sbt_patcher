package;

import UsmData;

class SbtWriter {
	var o:sys.io.FileOutput;
	var i:sys.io.FileInput;

	public function new(?o, ?i) {
		this.o = o;
		this.i = i;
		o.bigEndian = false;
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
}
