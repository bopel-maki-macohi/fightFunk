package funkin.maki.fightfunk;

import funkin.modding.module.Module;
import funkin.play.PlayState;

class FightUI extends Module
{
	override public function new()
	{
		super('FightUI');
	}

	var fightSongs = ['dadbattle-erect'];
	var fightUIEnabled:Bool = false;

	public var game(get, never):PlayState;

	function get_game():PlayState
	{
		return PlayState.instance;
	}

	function onSongLoaded(event)
	{
		super.onSongLoaded(event);

		var songCode = '${game.currentSong.id}-${game.currentVariation}'.toLowerCase();
		trace('songCode: $songCode');

		if (fightSongs.contains(songCode)) initFightUI();
	}

	function onUpdate(event)
	{
		super.onUpdate(event);

		if (fightUIEnabled) updateFightUI();
	}

	function initFightUI()
	{
		fightUIEnabled = true;
	}

	function updateFightUI()
	{
		if (!game.isInCutscene)
		{
			game.currentCameraZoom = 1;
			game.defaultHUDCameraZoom = 1;
			game.hudCameraZoomIntensity = 0;

			game.camHUD.zoom = game.defaultHUDCameraZoom;
		}
	}
}
