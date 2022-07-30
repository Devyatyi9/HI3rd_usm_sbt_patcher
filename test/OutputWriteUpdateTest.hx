package;

class OutputWriteUpdateTest {
	var o:sys.io.FileOutput;

	public function new(o) {
		this.o = o;
		o.bigEndian = false;
	}

	public function writeTest() {
		trace(o.tell());
		o.seek(4, SeekBegin);
		o.writeString('s');
		trace(o.tell());
		trace('test');
	}

	public function updateTest() {
		trace(o.tell());
		o.seek(4, SeekBegin);
		o.writeString('sSs');
		trace(o.tell());
		trace('test');
	}
}
