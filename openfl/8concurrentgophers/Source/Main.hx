package; // written for FOSDEM14, using new (March 2014) openfl-html5 back-end, Dec 2014 rewrite for latest OpenFL

import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

import openfl.utils.Timer;

import openfl.Assets;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

import tardis.*; // import of the Go code


class Main extends Sprite {
	
	private var bigpile:Array<Sprite>;
	private var oven:Array<Sprite>;
	private var Code:Sprite;
	private var Logo1:Sprite;
	private var Logo2:Sprite;
	
	private var Sprite1:Array<Sprite>;
	private var s1x = 90;
	private var s1y = 45;
	
	private var Sprite2:Array<Sprite>;
	private var s2x = 420;
	private var s2y = 45;
	
	private var Books:Array<Sprite>;
	private var bx = 390;
	private var by = 50; 
	
	private var lineOffsets:Array<Int>;
	
	private var goTimer:Timer;
	
	private var textField:TextField;
	private var whatToDo:TextField;
	private var headline:TextField;

	public function new () {
		
		super ();

		// headline at the top
		headline = new TextField ();
		headline.selectable = true;
		headline.x = 300;
		headline.y = 10;
		headline.width = 300;
		headline.text = "TARDIS Go example; see tardisgo.github.io";
		headline.textColor = 0x008000;		
		addChild (headline);

		// the code extract in the centre
		Code = new Sprite ();
		Code.addChild (new Bitmap (Assets.getBitmapData ("assets/function.png")));
		Code.x = 200;
		Code.y = 110;
		addChild (Code);
		
		// the left hand code indicator
		Logo1 = new Sprite ();
		Logo1.addChild (new Bitmap (Assets.getBitmapData ("assets/gophercolor16x16.png")));
		Logo1.x = 230;
		Logo1.y = 140;
		addChild (Logo1);

		// the right hand code indicator
		Logo2 = new Sprite ();
		Logo2.addChild (new Bitmap (Assets.getBitmapData ("assets/gophercolor16x16flipped.png")));
		Logo2.x = 540;
		Logo2.y = 140;
		addChild (Logo2);
	
		// Explation text on the left
		whatToDo = new TextField ();
		whatToDo.selectable = false;
		whatToDo.x = 10;
		whatToDo.y = 130;
		whatToDo.width = 200;
		whatToDo.height = 200;
		whatToDo.text = "All animated gophers are \nrunning the Go code on the right.\nThe logos show where the 2 above\ngophers each are in that code now.\nThis Go code is running live,\ntranspiled into: "+Go.Platform();
		whatToDo.textColor = 0x008000;		
		addChild (whatToDo);

		bigpile = [null,null,null,null];
		oven = [null,null,null,null];		
		Books = [null,null,null,null];
		Sprite1 = [null,null,null,null];		
		Sprite2 = [null,null,null,null];
		lineOffsets = [0,210,305,400];
			
		for (l in 0...4){
			// big pile of books on the left
			bigpile[l] = new Sprite ();
			bigpile[l].addChild (new Bitmap (Assets.getBitmapData ("assets/bigpile.png")));
			bigpile[l].x = 10;
			bigpile[l].y = 20+lineOffsets[l];
			addChild(bigpile[l]);

			// oven on the right
			oven[l] = new Sprite ();
			oven[l].addChild (new Bitmap (Assets.getBitmapData ("assets/oven.png")));
			oven[l].x = 690;
			oven[l].y = 0+lineOffsets[l];
			addChild(oven[l]);
		
			// books (sometimes) in the middle
			Books[l] = new Sprite ();
			Books[l].addChild (new Bitmap (Assets.getBitmapData ("assets/smallpile.png")));
			Books[l].x = bx;
			Books[l].y = by+lineOffsets[l];
			addChild(Books[l]);
		
			// the left hand gopher
			Sprite1[l] = new Sprite ();
			Sprite1[l].addChild ( new Bitmap (Assets.getBitmapData ("assets/pick.png")));
			Sprite1[l].x = s1x;
			Sprite1[l].y = s1y+lineOffsets[l];
			addChild(Sprite1[l]);
			
			// the right hand gopher
			Sprite2[l] = new Sprite ();
			Sprite2[l].addChild ( new Bitmap (Assets.getBitmapData ("assets/pick.png")));
			Sprite2[l].x = s2x;
			Sprite2[l].y = s2y+lineOffsets[l];
			addChild(Sprite2[l]);
		}
					
		// the "inspired by"" text
		textField = new TextField ();
		textField.selectable = true;
		textField.x = 420;
		textField.y = 195;
		textField.width = 400;
		textField.height = 50;
		textField.textColor = 0x008000;		
		textField.text = "Inspired by \"Concurrency is not Parallelism (it's better)\" - Rob Pike\nhttp://concur.rspace.googlecode.com/hg/talk/concur.html";
		addChild (textField);
		
		// off we go...
		s1laststatus = [0, 0, 0];
		s2laststatus = [0, 0, 0];
		bookslaststatus = [true, true, true];
		Go.init(); // initialise the Go environment
		Go_main_SStartGGophers.hx(); // start the gopher animation goroutines
		goTimer=new Timer(25); // 25 ms per run
		goTimer.addEventListener ( "timer", goTimerEvent); // schedule some go every so often
		goTimer.start();
	}
	

	private var s1laststatus : Array<Int> ;
	private var s2laststatus : Array<Int> ;
	private var bookslaststatus : Array<Bool> ;

	private function goTimerEvent(e:Dynamic):Void { // the entry point for every tick
		
		//trace("event listner!");

		Scheduler.runLimit=1;
		Scheduler.timerEventHandler(e); // schedule the Go code

		for(l in 0...4){

			var hc:Bool=tardis.Channel.hasContents(Go.main_smallpiles.addr(l<<2).load());
			if(hc!=bookslaststatus[l]){
				bookslaststatus[l]=hc;
				Books[l].removeChildAt(0);		
				if(hc==true){		
					Books[l].addChild (new Bitmap (Assets.getBitmapData ("assets/smallpile.png")));			
				} else {
					Books[l].addChild (new Bitmap (Assets.getBitmapData ("assets/emptypile.png")));			
				}
			}
		
			if(Go.main_SSprite1state.addr(l<<2).load_int32()!=s1laststatus[l]){
			
				// make sure we don't leave any stray pixels unset and flag for GC
				Sprite1[l].removeChildAt(0);
	
				s1laststatus[l] = Go.main_SSprite1state.addr(l<<2).load_int32(); // switch to the new state
				if(l==0)
					Logo1.y = 140 + (15*s1laststatus[l]); // move the logo to reflect the new state
			
				// add the new image
				if(s1laststatus[l]==Go.main_PPick) {
					Sprite1[l].addChild (new Bitmap (Assets.getBitmapData ("assets/pick.png")));
				}
				if(s1laststatus[l]==Go.main_FFull) {
					Sprite1[l].addChild (new Bitmap (Assets.getBitmapData ("assets/full.png")));
				}
				if(s1laststatus[l]==Go.main_SShovel) {
					Sprite1[l].addChild (new Bitmap (Assets.getBitmapData ("assets/shovel.png")));
				}
				if(s1laststatus[l]==Go.main_EEmpty) {
					Sprite1[l].addChild (new Bitmap (Assets.getBitmapData ("assets/empty.png")));
				}
			}
			Sprite1[l].x = s1x + Go.main_SSprite1XX.addr(l<<3).load_float64();
			Sprite1[l].y = s1y + Go.main_SSprite1YY.addr(l<<3).load_float64() + lineOffsets[l];
			
			if(Go.main_SSprite2state.addr(l<<2).load_int32()!=s2laststatus[l]){
				
				// make sure we don't leave any stray pixels unset and flag for GC
				Sprite2[l].removeChildAt(0);
				
				s2laststatus[l] = Go.main_SSprite2state.addr(l<<2).load_int32(); // switch to the new state
				if (l==0)
						Logo2.y = 140 + (15*s2laststatus[l]); // move the logo to reflect the new state
				
				// add the new image
				if(s2laststatus[l]==Go.main_PPick) {
					Sprite2[l].addChild (new Bitmap (Assets.getBitmapData ("assets/pick.png")));
				}
				if(s2laststatus[l]==Go.main_FFull) {
					Sprite2[l].addChild (new Bitmap (Assets.getBitmapData ("assets/full.png")));
				}
				if(s2laststatus[l]==Go.main_SShovel) {
					Sprite2[l].addChild (new Bitmap (Assets.getBitmapData ("assets/shovel.png")));
				}
				if(s2laststatus[l]==Go.main_EEmpty) {
					Sprite2[l].addChild (new Bitmap (Assets.getBitmapData ("assets/empty.png")));
				}
			}
			Sprite2[l].x = s2x + Go.main_SSprite2XX.addr(l<<3).load_float64();
			Sprite2[l].y = s2y + Go.main_SSprite2YY.addr(l<<3).load_float64() + lineOffsets[l];
		}			
	}
}