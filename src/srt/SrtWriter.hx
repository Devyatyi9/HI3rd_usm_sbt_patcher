package srt;

import usm.*;
import usm.UsmData.SrtData;
import usm.UsmData.SbtTag;

using StringTools;

class SrtWriter {
	var o:sys.io.FileOutput;

	public function new(o) {
		this.o = o;
		o.bigEndian = false;
	}

	public function writeSrt(usm:Array<SbtTag>) {
		var it = 0;
		while (it < usm.length) {
			if (usm[it].isSbt == true && usm[it].langId == 1) {
				o.writeString((it + 1) + '\r\n'); // number
				var startTime = Std.string(usm[it].startTime);
				var padStartTime = startTime.lpad('0', 9);
				o.writeString(padStartTime.substring(0, 2) + ':' + padStartTime.substring(2, 4) + ':' + padStartTime.substring(4, 6) + ','
					+ padStartTime.substring(6, 9));
				o.writeString(' --> ');
				var endTime = Std.string(usm[it].endTime);
				var padEndTime = endTime.lpad('0', 9);
				o.writeString(padEndTime.substring(0, 2) + ':' + padEndTime.substring(2, 4) + ':' + padEndTime.substring(4, 6) + ','
					+ padEndTime.substring(6, 9));
				o.writeString('\r\n');
				var newText = usm[it].text.replace('\\n', '\n');
				o.writeString(newText + '\r\n\r\n');
			}
			it++;
		}
		trace('Srt file has been write.');
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
