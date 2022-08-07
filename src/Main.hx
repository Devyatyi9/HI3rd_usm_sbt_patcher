package;

import haxe.ui.HaxeUIApp;

class Main {
	public static function main() {
		#if (cpp && debug)
		Sys.setCwd("..");
		#end
		trace('author: Devyatyi9');
		var app = new HaxeUIApp();
		app.ready(function() {
			app.addComponent(new MainView());

			app.start();
		});
	}
}
