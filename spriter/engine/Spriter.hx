package spriter.engine;
import spriter.definitions.ScmlObject;
import spriter.definitions.SpatialInfo;
import spriter.library.AbstractLibrary;

/**
 * ...
 * @author Loudo
 */
class Spriter
{

	public var scml:ScmlObject;
	public var library:AbstractLibrary;
	public var spriterName:String;
	public var timeMS:Int = 0;
	
	public var info:SpatialInfo;
	
	/**
	 * If the Spriter is paused.
	 */
	public var paused:Bool = false;
	
	public function new(_name:String, _scml:ScmlObject, _library:AbstractLibrary, _info:SpatialInfo) 
	{
		scml 	= _scml;
		library = _library;
		spriterName = _name;
		scml.name = spriterName;
		info = _info;
	}
	
	public function advanceTime(elapsedMS:Int):Void
	{
		if(!paused)
			timeMS += elapsedMS;
			
		scml.setCurrentTime(timeMS, library, info);//even if paused we need to draw it
	}
	/**
	 * Apply character mapping to change an element in the animation.
	 * @param	name of the character map in the xml
	 * @param	reset to apply only the new character map, if not, you can have multiple character map at the same time
	 * @return  true if the character map exist, false if doesn't exist
	 */
	public function applyCharacterMap(name:String, reset:Bool):Bool
	{
		return scml.applyCharacterMap(name, reset);
	}
	
	/**
	 * Play a specific animation
	 * @param	name of the animation
	 * @param	endAnimCallback function callback, return (s:Spriter, entity:String, anim:String)
	 * @param	removeCallback remove function callback after dispatch
	 * @return  true if the animation exist, false if doesn't exist
	 */
	public function playAnim(name:String, ?endAnimCallback:Spriter->String->String->Void, removeCallback:Bool = true):Bool
	{
		if (scml.entities.get(scml.currentEntity).animations.exists(name)) {
			resetTime();
			scml.currentAnimation = name;
			if (endAnimCallback != null) {
				scml.endAnimCallback = endAnimCallback.bind(this, scml.currentEntity, name);
				scml.endAnimRemoval = removeCallback;
			}
			return true;
		}else {
			return false;
		}
	}
	/**
	 * Play a specific entity.
	 * @param	name of the entity
	 * @param	name of the animation (optional)
	 * @param	endAnimCallback function callback, return (s:Spriter, entity:String, anim:String)
	 * @param	removeCallback remove function callback after dispatch
	 * @return  true if the entity exist, false if doesn't exist
	 */
	public function playEntity(name:String, anim:String = '', ?endAnimCallback:Spriter->String->String->Void, removeCallback:Bool = true):Bool
	{
		if (scml.entities.exists(name)) {
			resetTime();
			scml.currentEntity = name;
			if(anim != ''){
				if (scml.entities.get(name).animations.exists(anim)) {
					scml.currentAnimation = anim;
				}
			}
			if(endAnimCallback != null){
				scml.endAnimCallback = endAnimCallback.bind(this, name, scml.currentAnimation);
				scml.endAnimRemoval = removeCallback;
			}
			return true;
		}else {
			return false;
		}
	}
	/**
	 * Play a stack of animations
	 * @param	names of the animations in order
	 * @param	endAnimCallback function callback, return (s:Spriter, entity:String, anim:String)
	 * @param	removeCallback remove function callback after dispatch
	 * @return  true if the animation exist, false if doesn't exist
	 */
	public function playAnimsStack(names:Array<String>, ?endAnimCallback:Spriter->String->String->Void):Bool
	{
		if (scml.entities.get(scml.currentEntity).animations.exists(names[0])) {
			resetTime();
			scml.currentAnimation = names[0];
			scml.endAnimCallback = stackAnims.bind(names, 1, endAnimCallback);
			scml.endAnimRemoval = true;
			return true;
		}else {
			return false;
		}
	}
	/**
	 * Play a stack of animations from a specific entity.
	 * @param	name of the entity
	 * @param	anims names of the animations in order
	 * @param	endAnimCallback function callback, return (s:Spriter, entity:String, anim:String)
	 * @param	removeCallback remove function callback after dispatch
	 * @return  true if the entity exist, false if doesn't exist
	 */
	public function playEntityAnimsStack(name:String, anims:Array<String>, ?endAnimCallback:Spriter->String->String->Void):Bool
	{
		if (scml.entities.exists(name)) {
			resetTime();
			scml.currentEntity = name;
			if (scml.entities.get(name).animations.exists(anims[0])) {
				scml.currentAnimation = anims[0];
			}
			scml.endAnimCallback = stackAnims.bind(anims, 1, endAnimCallback);
			scml.endAnimRemoval = true;
			return true;
		}else {
			return false;
		}
	}
	
	private function stackAnims(anims:Array<String>, nextAnim:Int, endAnimsCallback:Spriter->String->String->Void):Void
	{
		if (scml.entities.get(scml.currentEntity).animations.exists(anims[nextAnim])) {
			resetTime();
			scml.currentAnimation = anims[nextAnim];
		}
		trace('stackAnims', scml.currentAnimation);
		//anim after next anim handler
		if (++nextAnim >= anims.length) {
			if(endAnimsCallback != null)
				scml.endAnimCallback = endAnimsCallback.bind(this, scml.currentEntity, scml.currentAnimation);
		}else {
				scml.endAnimCallback = stackAnims.bind(anims, nextAnim, endAnimsCallback);
		}
	}
	
	public function resetTime():Void
	{
		timeMS = 0;
	}
	
	public function destroy():Void
	{
		scml.destroy();
		info = null;
		//don't destroy library here since library is shared between all Spriter in the engine
	}
	
}