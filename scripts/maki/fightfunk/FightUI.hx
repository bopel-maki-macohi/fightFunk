package funkin.maki.fightfunk;

import funkin.modding.module.Module;
import funkin.play.PlayState;
import funkin.mobile.input.ControlsHandler;

class FightUI extends Module
{
	override public function new()
	{
		super('FightUI');

		middleScroll = false;
	}

	var fightSongs = ['dadbattle-erect'];
	var fightUIEnabled:Bool = false;
	var fightUI_visiblePropName:Array<String> = [];

	public var game(get, never):PlayState;

	function get_game():PlayState
	{
		return PlayState.instance;
	}

	function onSongLoaded(event)
	{
		super.onSongLoaded(event);

		if (game != null)
		{
			var songCode = '${game.currentSong.id}-${game.currentVariation}'.toLowerCase();
			trace('songCode: $songCode');

			if (fightSongs.contains(songCode)) initFightUI();
		}
	}

	function onUpdate(event)
	{
		super.onUpdate(event);

		if (fightUIEnabled && game != null) updateFightUI();
	}

	function initFightUI()
	{
		fightUIEnabled = true;

		game.remove(game.comboPopUps);

		game.refresh();
	}

	function hideOpponentStrumline()
	{
		var opponentStrumline:FlxSprite = game.opponentStrumline;
		if (opponentStrumline != null)
		{
			for (arrow in opponentStrumline.members)
			{
				arrow.visible = false;
			}
		}
	}

	function centerPlayerStrumline()
	{
		// This is a song gimmick we are never making middlescroll an option.

		if (Preferences.controlsScheme == "Arrows" && !ControlsHandler.usingExternalInputDevice) return;

		var playerStrumline:FlxSprite = game.playerStrumline;
		if (playerStrumline != null)
		{
			playerStrumline.x = FlxG.width / 2 - playerStrumline.width / 2;
		}
	}

	var middleScroll = false;

	function onCreate(event:ScriptEvent):Void
	{
		super.onCreate(event);

		middleScroll = false;
	}

	function onDestroy(event:ScriptEvent):Void
	{
		super.onDestroy(event);
		middleScroll = false;
	}

	function updateFightUI()
	{
		if (!game.isInCutscene)
		{
			game.currentCameraZoom = 0.5;
			game.defaultHUDCameraZoom = 1;
			game.hudCameraZoomIntensity = 0;

			game.camHUD.zoom = game.defaultHUDCameraZoom;

			for (bopper in game.currentStage?.boppers)
			{
				bopper.active = false;
				bopper.visible = false;
			}

			for (name => prop in game.currentStage?.namedProps)
			{
				if (!fightUI_visiblePropName.contains(name))
				{
					prop.active = false;
					prop.visible = false;
				}
			}

			if (!middleScroll)
			{
				middleScroll = true;
				hideOpponentStrumline();
				centerPlayerStrumline();
			}
		}
	}
}
