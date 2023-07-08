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
			if (usm[it].isSbt == true) {
				o.writeString((it + 1) + '\r\n'); // number
				
				var startTime = Std.string(usm[it].startTime);
				var padstartTime = startTime.lpad('0', 9);
				var startTimeInt = (usm[it].startTime); // creates an Int copy of the duration. 				
				
				if(startTimeInt >= 100000) startTimeInt = (startTimeInt + 40000);
				if(startTimeInt >= 200000) startTimeInt = (startTimeInt + 40000);
				if(startTimeInt >= 300000) startTimeInt = (startTimeInt + 40000);
				if(startTimeInt >= 400000) startTimeInt = (startTimeInt + 40000);
				if(startTimeInt >= 500000) startTimeInt = (startTimeInt + 40000);
				if(startTimeInt >= 600000) startTimeInt = (startTimeInt + 40000); // adds an additional 40 seconds every 100 seconds because a start time of 100 gets written as 1:00 in the srt file which is 60 seconds. 
				if(startTimeInt >= 700000) startTimeInt = (startTimeInt + 40000);
				if(startTimeInt >= 800000) startTimeInt = (startTimeInt + 40000);
				if(startTimeInt >= 900000) startTimeInt = (startTimeInt + 40000);
				if(startTimeInt >= 1000000) startTimeInt = (startTimeInt + 40000);
				if(startTimeInt >= 1100000) startTimeInt = (startTimeInt + 40000);
				if(startTimeInt >= 1200000) startTimeInt = (startTimeInt + 40000);				
								
				var startTimeString = Std.string(startTimeInt); // converts the int to a string
				var padStartTime = startTimeString.lpad('0', 9); // creates the array of endTimeString
				o.writeString(padStartTime.substring(0, 2) + ':' + padStartTime.substring(2, 4) + ':' + padStartTime.substring(4, 6) + ','
					+ padStartTime.substring(6, 9));
					
				o.writeString(' --> ');				
				
				var endTime = Std.string(usm[it].endTime);
				var padEndTime = endTime.lpad('0', 9);
				
				var endTimeInt = (usm[it].endTime); // creates an Int copy of the duration. 
				var endTime; // Leaves endTime empty for now.
				endTimeInt = (endTimeInt + startTimeInt); // adds the start time and the duration to get the new end time				
				
				if (startTimeInt < 100000 && endTimeInt >= 100000 ) endTimeInt = (endTimeInt + 40000);
				if (startTimeInt < 200000 && endTimeInt >= 200000 ) endTimeInt = (endTimeInt + 40000); 
				if (startTimeInt < 300000 && endTimeInt >= 300000 ) endTimeInt = (endTimeInt + 40000);
				if (startTimeInt < 400000 && endTimeInt >= 400000 ) endTimeInt = (endTimeInt + 40000);
				if (startTimeInt < 500000 && endTimeInt >= 500000 ) endTimeInt = (endTimeInt + 40000); // adds an offset for if the start time is like 99 seconds and the end time is over 100 seconds
				if (startTimeInt < 600000 && endTimeInt >= 600000 ) endTimeInt = (endTimeInt + 40000);  // enabling the end time to correctly be written in the .srt file
				if (startTimeInt < 700000 && endTimeInt >= 700000 ) endTimeInt = (endTimeInt + 40000);
				if (startTimeInt < 800000 && endTimeInt >= 800000 ) endTimeInt = (endTimeInt + 40000);
				if (startTimeInt < 900000 && endTimeInt >= 900000 ) endTimeInt = (endTimeInt + 40000);
				if (startTimeInt < 1000000 && endTimeInt >= 1000000 ) endTimeInt = (endTimeInt + 40000); 
				if (startTimeInt < 1100000 && endTimeInt >= 1100000 ) endTimeInt = (endTimeInt + 40000);
				if (startTimeInt < 1200000 && endTimeInt >= 1200000 ) endTimeInt = (endTimeInt + 40000);				
				
				var endTimeString = Std.string(endTimeInt); // converts the int to a string
				var padEndTime = endTimeString.lpad('0', 9); // creates the array of endTimeString
				
				o.writeString(padEndTime.substring(0, 2) + ':' + padEndTime.substring(2, 4) + ':' + padEndTime.substring(4, 6) + ','
					+ padEndTime.substring(6, 9));
				o.writeString('\r\n');
				
				var newText = usm[it].text.replace('\x00', '');
				newText = usm[it].text.replace('\\n', '\n');
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
