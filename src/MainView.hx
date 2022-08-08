package;

import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
import haxe.ui.core.Screen;

@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class MainView extends VBox {
	public function new() {
		super();
		// Screen.instance.frame.setBitmap(hx.widgets.Bitmap.fromHaxeResource("images/haxeui.png"));
		// Screen.instance.frame.setBitmap(hx.widgets.Bitmap.fromHaxeResource("images/chibi_kiana_kaslana-256.png"));
		// Screen.instance.frame.setBitmap(hx.widgets.Bitmap.fromHaxeResource("haxeui-core/styles/default/haxeui.png"));
	}

	@:bind(button2, MouseEvent.CLICK)
	private function onMyButton(e:MouseEvent) {
		button2.text = "Thanks!";
	}
}
