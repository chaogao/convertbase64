package
{
	import flash.display.Sprite;
	import flash.display.Bitmap; //位图
	import flash.display.BitmapData; //位图数据格式
	import flash.display.Loader; //加载器
	import flash.net.URLRequest; //创建远程资源请求用的
	import flash.utils.ByteArray; //二进制数组
	import flash.system.LoaderContext; //flash跨域操作资源需要设置的一个东东
	import flash.external.ExternalInterface; //与js通讯用的
	import flash.events.Event; //同样的类似javascript里的事件对象类型
	import mx.graphics.codec.PNGEncoder; //pngEncoder
	import mx.utils.Base64Encoder; //base64 Encoder
	
	
	public class convertBase64 extends Sprite
	{
		public function convertBase64()
		{
			if(ExternalInterface.available){
				trace("added");
				ExternalInterface.addCallback('getImage',getImage); //给外部的object留一个getImage方法用于加载外部资源，比如图像
			}
		}
		
		private function getImage(value:String):void{
			var lc:LoaderContext = new LoaderContext(true);
			var loader:Loader = new Loader();
			loader.load(new URLRequest(value),lc);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
		}
		
		private function loadedFn(value:String):void{
			if(ExternalInterface.available){
				var param:Object = root.loaderInfo.parameters;
				var loadedFn:String = "Imageloaded";
				if(param && param['loaded']){
					loadedFn = param['loaded'];
				}
				ExternalInterface.call(loadedFn,value);  //这里就是给每次的loadsuccess触发的js的函数的回调，这里属于注册行为？总之call了一个js的函数，然后把as里的data反给了js，js在函数里就直接可以用鸟。。
			}
		}
		
		private function loadComplete(event:Event):void{
			var bitmap:Bitmap = event.target.content as Bitmap; //把这个货回传回去，图片高宽大小等信息居然在firebug里都可以打出来……
			var pngStream:ByteArray=(new PNGEncoder).encode(bitmap.bitmapData);
			var base64Enc:Base64Encoder = new Base64Encoder();
			base64Enc.encodeBytes(pngStream);
			var base64Str:String = base64Enc.toString();
			loadedFn(base64Str); //各种转换之后得到base64的字符串结果
		}
	}
}