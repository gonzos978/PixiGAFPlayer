package com.github.haxePixiGAF.data;
import com.github.haxePixiGAF.data.tagfx.ITAGFX;
import com.github.haxePixiGAF.data.tagfx.TAGFXBase;
import com.github.haxePixiGAF.data.textures.TextureWrapper;
import com.github.haxePixiGAF.utils.DebugUtility;
import pixi.interaction.EventEmitter;

/**
 * Dispatched when he texture is decoded. It can only be used when the callback has been executed.
 */
//[Event(name="texturesReady", type="flash.events.Event")]

/**
 * Graphical data storage that used by<code>GAFTimeline</code>. It contain all created textures and all
 * saved images as<code>BitmapData</code>.
 * Used as shared graphical data storage between several GAFTimelines if they are used the same texture atlas(bundle created using "Create bundle" option)
 */

/**
 * TODO vu le système de chargement, les onReady et autre test de chargement ne servent a rien, a simplifier
 * @author Mathieu Anthoine
 * 
 */ 
class GAFGFXData extends EventEmitter
{
	public static inline var EVENT_TYPE_TEXTURES_READY:String="texturesReady";

	//--------------------------------------------------------------------------
	//
	//  PUBLIC VARIABLES
	//
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//
	//  PRIVATE VARIABLES
	//
	//--------------------------------------------------------------------------

	private var _texturesDictionary:Map<String,Map<String,Map<String,TextureWrapper>>>= new Map<String,Map<String,Map<String,TextureWrapper>>>();
	private var _taGFXDictionary:Map<String,Map<String,Map<String,ITAGFX>>> = new Map<String,Map<String,Map<String,ITAGFX>>>();

	private var _textureLoadersSet:Map<ITAGFX,ITAGFX>=new Map<ITAGFX,ITAGFX>();

	//--------------------------------------------------------------------------
	//
	//  CONSTRUCTOR
	//
	//--------------------------------------------------------------------------

	public function new()
	{
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  PUBLIC METHODS
	//
	//--------------------------------------------------------------------------

	public function addTAGFX(scale:Float, csf:Float, imageID:String, taGFX:ITAGFX):Void
	{
		
		var lScale:String = Std.string(scale);
		var lCsf:String = Std.string(csf);
		
		if (_taGFXDictionary[lScale]==null) _taGFXDictionary[lScale]=new Map<String,Map<String,ITAGFX>>();
		if (_taGFXDictionary[lScale][lCsf]==null) _taGFXDictionary[lScale][lCsf]=new Map<String,ITAGFX>();
		if (_taGFXDictionary[lScale][lCsf][imageID]==null) _taGFXDictionary[lScale][lCsf][imageID]=taGFX;
	}

	public function getTAGFXs(scale:Float, csf:Float):Map<String,ITAGFX>
	{
		var lScale:String = Std.string(scale);
		var lCsf:String = Std.string(csf);
		
		if(_taGFXDictionary!=null)
		{
			if(_taGFXDictionary[lScale]!=null)
			{
				return _taGFXDictionary[lScale][lCsf];
			}
		}

		return null;
	}

	public function getTAGFX(scale:Float, csf:Float, imageID:String):ITAGFX
	{
		var lScale:String = Std.string(scale);
		var lCsf:String = Std.string(csf);
		
		if(_taGFXDictionary!=null)
		{
			if(_taGFXDictionary[lScale]!=null)
			{
				if(_taGFXDictionary[lScale][lCsf]!=null)
				{
					return _taGFXDictionary[lScale][lCsf][imageID];
				}
			}
		}

		return null;
	}

	/**
	 * Creates textures from all images for specified scale and csf.
	 * @param scale
	 * @param csf
	 * @return {Boolean}
	 * @see #createTexture()
	 */
	public function createTextures(scale:Float, csf:Float):Bool
	{
		var taGFXs:Map<String,ITAGFX>=getTAGFXs(scale, csf);
		if(taGFXs!=null)
		{
			var lScale:String = Std.string(scale);
			var lCsf:String = Std.string(csf);
			if (_texturesDictionary[lScale]==null) _texturesDictionary[lScale]=new Map<String,Map<String,TextureWrapper>>();
			if (_texturesDictionary[lScale][lCsf]==null) _texturesDictionary[lScale][lCsf] =new Map<String,TextureWrapper>();

			for(imageAtlasID in taGFXs.keys())
			{
				if(taGFXs[imageAtlasID]!=null)
				{
					addTexture(_texturesDictionary[lScale][lCsf], taGFXs[imageAtlasID], imageAtlasID);
				}
			}
			return true;
		}

		return false;
	}

	/**
	 * Creates texture from specified image.
	 * @param scale
	 * @param csf
	 * @param imageID
	 * @return {Boolean}
	 * @see #createTextures()
	 */
	public function createTexture(scale:Float, csf:Float, imageID:String):Bool
	{
		var taGFX:ITAGFX=getTAGFX(scale, csf, imageID);
		if(taGFX!=null)
		{
			var lScale:String = Std.string(scale);
			var lCsf:String = Std.string(csf);
			if (_texturesDictionary[lScale]==null) _texturesDictionary[lScale]=new Map<String,Map<String,TextureWrapper>>();
			if (_texturesDictionary[lScale][lCsf]==null) _texturesDictionary[lScale][lCsf] =new Map<String,TextureWrapper>();

			addTexture(_texturesDictionary[lScale][lCsf], taGFX, imageID);

			return true;
		}

		return false;
	}

	/**
	 * Returns texture by unique key consist of scale + csf + imageID
	 */
	public function getTexture(scale:Float, csf:Float, imageID:String):TextureWrapper
	{
		var lScale:String = Std.string(scale);
		var lCsf:String = Std.string(csf);
		if(_texturesDictionary!=null)
		{
			
			if(_texturesDictionary[lScale]!=null)
			{
				
				if(_texturesDictionary[lScale][lCsf]!=null)
				{
					if(_texturesDictionary[lScale][lCsf][imageID]!=null)
					{
						return _texturesDictionary[lScale][lCsf][imageID];
					}
				}
			}
		}

		// in case when there is no texture created
		// create texture and check if it successfully created
		if(createTexture(scale, csf, imageID))
		{
			return _texturesDictionary[lScale][lCsf][imageID];
		}

		return null;
	}

	/**
	 * Returns textures for specified scale and csf in Dynamic as combination key-value where key - is imageID and value - is Texture
	 */
	public function getTextures(scale:Float, csf:Float):Map<String,TextureWrapper>
	{
		
		var lScale:String = Std.string(scale);
		var lCsf:String = Std.string(csf);
		if(_texturesDictionary!=null)
		{
			if(_texturesDictionary[lScale]!=null)
			{
				return _texturesDictionary[lScale][lCsf];
			}
		}
		
		return null;
	}

	/**
	 * Dispose specified texture or textures for specified combination scale and csf. If nothing was specified - dispose all texturea
	 */
	public function disposeTextures(?scale:Float, ?csf:Float, imageID:String=null):Void
	{
		trace ("disposeTextures: TODO");
		
		//if(Math.isNaN(scale))
		//{
			//for(scaleToDispose in _texturesDictionary)
			//{
				//disposeTextures(Std.parseFloat(scaleToDispose));
			//}
//
			//_texturesDictionary=null;
		//}
		//else
		//{
			//if(Math.isNaN(csf))
			//{
				//for(csfToDispose in _texturesDictionary[scale])
				//{
					//disposeTextures(scale, Std.parseFloat(csfToDispose));
				//}
//
				//_texturesDictionary.remove(scale);
			//}
			//else
			//{
				//if(imageID)
				//{
					//cast(_texturesDictionary[scale][csf][imageID],TempTexture).destroy();
//
					//_texturesDictionary[scale][csf].remove(imageID);
				//}
				//else
				//{
					//if(_texturesDictionary[scale] && _texturesDictionary[scale][csf])
					//{
						//for(atlasIDToDispose in _texturesDictionary[scale][csf])
						//{
							//disposeTextures(scale, csf, atlasIDToDispose);
						//}
						//_texturesDictionary[scale].remove(csf);
					//}
				//}
			//}
		//}
	}

	//--------------------------------------------------------------------------
	//
	//  PRIVATE METHODS
	//
	//--------------------------------------------------------------------------

	private function addTexture(dictionary:Map<String,TextureWrapper>, tagfx:ITAGFX, imageID:String):Void
	{
		
		if(DebugUtility.RENDERING_DEBUG)
		{
			//var bitmapData:BitmapData;
			//if(tagfx.sourceType==TAGFXBase.SOURCE_TYPE_BITMAP_DATA)
			//{
				//bitmapData=setGrayScale(tagfx.source.clone());
			//}
//
			//if(bitmapData)
			//{
				//dictionary[imageID]=Texture.fromBitmapData(bitmapData, GAF.useMipMaps, false, tagfx.textureScale, tagfx.textureFormat);
			//}
			//else
			//{
				if(tagfx.texture!=null)
				{
					//dictionary[imageID]=Texture.fromTexture(tagfx.texture);
				}
				else
				{
					throw "GAFGFXData texture for rendering not found!";
				}
			//}
		}
		else if(dictionary[imageID]==null)
		{
			if(!tagfx.ready)
			{
				_textureLoadersSet[tagfx] = tagfx;
				tagfx.on(TAGFXBase.EVENT_TYPE_TEXTURE_READY, onTextureReady);
			}

			dictionary[imageID] = TextureWrapper.fromTexture(tagfx.texture);
			//dictionary[imageID] = cast Texture.fromImage(tagfx.texture.baseTexture.imageUrl);
		}
	}

	//private function setGrayScale(image:BitmapData):BitmapData
	//{
		//var matrix:Array<Dynamic>=[
			//0.26231, 0.51799, 0.0697, 0, 81.775,
			//0.26231, 0.51799, 0.0697, 0, 81.775,
			//0.26231, 0.51799, 0.0697, 0, 81.775,
			//0, 0, 0, 1, 0];
//
		//var filter:ColorMatrixFilter=new ColorMatrixFilter(matrix);
		//image.applyFilter(image, new Rectangle(0, 0, image.width, image.height), new Point(0, 0), filter);
//
		//return image;
	//}

	//--------------------------------------------------------------------------
	//
	// OVERRIDDEN METHODS
	//
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//
	//  EVENT HANDLERS
	//
	//--------------------------------------------------------------------------
	private function onTextureReady(event:Dynamic):Void
	{
		var tagfx:ITAGFX=cast (event.target,ITAGFX);
		tagfx.off(TAGFXBase.EVENT_TYPE_TEXTURE_READY, onTextureReady);

		_textureLoadersSet.remove(tagfx);

		if(isTexturesReady)
			emit(EVENT_TYPE_TEXTURES_READY);
	}

	//--------------------------------------------------------------------------
	//
	//  GETTERS AND SETTERS
	//
	//--------------------------------------------------------------------------

	public var isTexturesReady(get_isTexturesReady, null):Bool;
 	private function get_isTexturesReady():Bool
	{
		var empty:Bool=true;
		for(tagfx in _textureLoadersSet)
		{
			empty=false;
			break;
		}
		
		trace ("isTexturesReady",empty);

		return empty;
	}
}