package srt;

import usm.*;
import usm.UsmData.SrtData;
import usm.UsmData.SbtTag;

class SrtWriter {
	var o:sys.io.FileOutput;

	public function new(o) {
		this.o = o;
		o.bigEndian = false;
	}

	public function writeSrt(usm:Array<SbtTag>) {
		var it = 0;
		while (it < usm.length) {
			//
			o.writeString(it + '\r\n'); // number
			o.writeString('00:00:00,000'); // 00:00:00,000
			// -->
			// 00:00:00,000
			it++;
		}
	}

	// srt > txt subtitle format for Scaleform VideoEncoder - CRIWARE Medianoche
	public function writeTxt(SrtData:Array<SrtData>) {
		o.writeString('1000\r\n'); // interval
		var it = 0;
		while (it < SrtData.length) {
			o.writeString(Std.string(SrtData[it].timeStart) + ', ');
			o.writeString(Std.string(SrtData[it].timeEnd) + ', ');
			o.writeString(SrtData[it].text + '\r\n'); // \r (CR), \n (LF)
			it++;
		}
		trace('Txt file has been write.');
	}
}
