package;

import haxe.io.Bytes;
import haxe.Int32;

enum Tags {
	test;
}

typedef SbtTag = {
	var isSbt:Bool;
	var previousRawBytes:Bytes;
	var startPos:Int;
	var endTag:Bool;
	var chunkLength:Int;
	var paddingSize:Int; // haxe.io.Bytes //Int
	var type:Int;
	var langId:Int;
	var interval:Int;
	var startTime:Int;
	var endTime:Int;
	var textLength:Int;
	var text:String;
}

typedef StrData = {
	var number:Int;
	var timeStart:Int;
	var timeEnd:Int;
	var text:String;
}
