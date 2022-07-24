package;

class SrtReader {
	var i:sys.io.FileInput;

	public function new(i) {
		this.i = i;
		i.bigEndian = false;
	}

	public function read() {
		var numberS = i.readLine();
		var number = Std.parseInt(numberS);
		var timeStart = i.readString(12);
		i.read(5);
		var timeEnd = i.readString(12);
		return {
			number: number,
			timeStart: timeStart,
			timeEnd: timeEnd
		}
	}
}
