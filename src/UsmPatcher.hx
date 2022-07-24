package;

class UsmPatcher {
	var o:haxe.io.Output;
	var i:sys.io.FileInput;

	public function new(o) {
		this.o = o;
		o.bigEndian = false;
	}

	public function write() {}
}
