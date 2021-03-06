package com.github.mathieuanthoine.gaf;

import com.github.haxePixiGAF.core.GAFLoader;
import com.github.haxePixiGAF.core.ZipToGAFAssetConverter;
import com.github.haxePixiGAF.data.GAFBundle;
import com.github.haxePixiGAF.data.GAFGFXData;
import com.github.haxePixiGAF.data.GAFTimeline;
import com.github.haxePixiGAF.display.GAFImage;
import com.github.haxePixiGAF.display.GAFMovieClip;
import com.github.haxePixiGAF.display.GAFTexture;
import com.github.haxePixiGAF.display.IGAFTexture;
import com.github.haxePixiGAF.events.GAFEvent;
import haxe.Timer;
import haxe.ds.ObjectMap;
import js.Browser;
import js.Lib;
import js.html.CanvasElement;
import js.html.MouseEvent;
import pixi.core.display.Container;
import pixi.core.math.Matrix;
import pixi.core.renderers.Detector;
import pixi.core.renderers.webgl.WebGLRenderer;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import pixi.interaction.InteractionEvent;
import pixi.loaders.LoaderOptions;

/**
 * @author Mathieu Anthoine
 */

class Main
{

	private var renderer:WebGLRenderer;
	private var stage:Container;
	
	private var _gafMovieClip: GAFMovieClip;
	private var _gunSlot: GAFImage;
	private var _gun1: IGAFTexture;
	private var _gun2: IGAFTexture;
	private var _currentGun: IGAFTexture;

	private static function main ():Void
	{
		new Main();
	}

	/**
	 * création du jeu
	*/
	private function new ()
	{
		renderer = Detector.autoDetectRenderer(800, 600, {backgroundColor : 0x999999});
		Browser.document.body.appendChild(renderer.view);

		stage = new Container();
		
		new Perf("TL");
		
		var converter: ZipToGAFAssetConverter = new ZipToGAFAssetConverter();
		converter.on(GAFEvent.COMPLETE, onConverted);		
		converter.convert("gun_swap/gun_swap.gaf");
		
	}
	
	private function onConverted (pEvent:Dynamic):Void {

		var gafBundle:GAFBundle = cast(pEvent.target, ZipToGAFAssetConverter).gafBundle;
		//"gun_swap" - the name of the SWF which was converted to GAF
		var gafTimeline: GAFTimeline = gafBundle.getGAFTimeline("gun_swap");
		var mc: GAFMovieClip = new GAFMovieClip(gafTimeline);
		
		_gafMovieClip = new GAFMovieClip(gafTimeline);
		_gafMovieClip.play(true);

		_gunSlot = cast(_gafMovieClip.getChildByName("GUN"),GAFImage);

		_gun1 = gafBundle.getCustomRegion("gun_swap", "gun1");
		_gun2 = gafBundle.getCustomRegion("gun_swap", "gun2");
		//"gun2" texture is made from Bitmap
		//thus we need to adjust its' pivot matrix
		_gun2.pivotMatrix.translate(-24.2, -41.55);

		setGun(_gun1);

		stage.addChild(_gafMovieClip);
		
		Browser.window.addEventListener("click", onClick);		
		Browser.window.requestAnimationFrame(gameLoop);
		
	}
	
	private function onClick(pEvent: MouseEvent): Void
	{
		if (_currentGun == _gun2)
		{
			setGun(_gun1);
		}
		else
		{
			setGun(_gun2);
		}
	}
	
	private function setGun(gun: IGAFTexture): Void
	{
		_currentGun = gun;
		_gunSlot.changeTexture(gun);
	}
	
	private function gameLoop(pIdentifier:Float)
	{
		Browser.window.requestAnimationFrame(gameLoop);
		renderer.render(stage);
	}

}