package funkin.maki.fightfunk;

import funkin.modding.module.Module;
import funkin.play.PlayState;
import funkin.play.components.HealthIcon;
import funkin.mobile.input.ControlsHandler;
import flixel.math.FlxMath;
import flixel.addons.display.FlxBackdrop;
import funkin.graphics.FunkinSprite;

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

	var elapsedTotal:Float = 0;

	function onUpdate(event)
	{
		super.onUpdate(event);

		elapsedTotal += event.elapsed;

		if (fightUIEnabled && game != null) updateFightUI();
	}

	var boxBGPlayer:FlxBackdrop;
	var boxBGOpponent:FlxBackdrop;

	var arrowBox:FunkinSprite;
	var statBox:FunkinSprite;

	function initFightUI()
	{
		final isDownscroll:Bool = #if mobile (Preferences.controlsScheme == FunkinHitboxControlSchemes.Arrows
			&& !ControlsHandler.hasExternalInputDevice)
			|| #end Preferences.downscroll;

		fightUIEnabled = true;

		game.remove(game.scoreText);
		game.remove(game.comboPopUps);

		var healthBarY = game.healthBarBG.y;

		for (HBP in [game.healthBarBG, game.healthBar,])
		{
			HBP.scale.set(1.5, 1);
			HBP.updateHitbox();
			HBP.screenCenter();

			HBP.zIndex *= 4;
		}

		game.healthBarBG.y = healthBarY;

		game.healthBar.x = game.healthBarBG.x + 4;
		game.healthBar.y = game.healthBarBG.y + 4;

		boxBGPlayer = new FlxBackdrop(Paths.image('ui/fight/box'));
		boxBGPlayer.zIndex = 10;
		boxBGPlayer.color = 0xff00ff6a;
		boxBGPlayer.velocity.set(20, -20);
		boxBGPlayer.scale.set(2, 2);
		boxBGPlayer.updateHitbox();

		boxBGPlayer.blend = 0;

		game.add(boxBGPlayer);

		boxBGOpponent = new FlxBackdrop(Paths.image('ui/fight/box'));
		boxBGOpponent.zIndex = 0;
		boxBGOpponent.color = 0xffff0000;
		boxBGOpponent.velocity.set(-40, -40);
		boxBGOpponent.scale.set(2, 2);
		boxBGOpponent.updateHitbox();

		boxBGOpponent.blend = 0;
		game.add(boxBGOpponent);

		game.currentStage.zIndex = 300;

		arrowBox = FunkinSprite.create(0, 0, 'ui/fight/box');
		arrowBox.antialiasing = false;
		arrowBox.scale.set(FlxG.width * 1.1 / arrowBox.width, 3);
		arrowBox.updateHitbox();
		arrowBox.zIndex = game.healthBarBG.zIndex * 0.5;
		arrowBox.cameras = [game.camHUD];
		arrowBox.screenCenter(0x01);
		arrowBox.y = (isDownscroll) ? FlxG.height - arrowBox.height + 10 : -10;
		game.add(arrowBox);

		statBox = FunkinSprite.create(0, 0, 'ui/fight/box');
		statBox.antialiasing = false;
		statBox.scale.set(FlxG.width * 1.1 / statBox.width, 3);
		statBox.updateHitbox();
		statBox.zIndex = game.healthBarBG.zIndex * 0.75;
		statBox.cameras = [game.camHUD];
		statBox.screenCenter(0x01);
		statBox.y = (isDownscroll) ? -10 : FlxG.height - statBox.height + 10;
		game.add(statBox);

		game.playerStrumline.zIndex = arrowBox.zIndex + 100;
		game.playerStrumline.background.visible = false;

		for (icon in [game.iconP1, game.iconP2,])
		{
			icon?.bopEvery = 0;
			icon?.zIndex *= 4;
		}

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
			// if (game.isBotPlayMode)
			// 	game.healthLerp = Constants.HEALTH_MAX;
			// else
			// 	game.healthLerp = FlxMath.lerp(game.healthLerp, game.health, 0.000000015);

			boxBGPlayer.velocity.x = 40 * (Math.cos(elapsedTotal) * (14 * 0.25));
			boxBGPlayer.velocity.y = 40 * (Math.sin(elapsedTotal) * (25 * 0.25));

			boxBGOpponent.velocity.x = -40 * (Math.sin(elapsedTotal) * (5 * 0.25));
			boxBGOpponent.velocity.y = -40 * (Math.cos(elapsedTotal) * (7 * 0.25));

			boxBGPlayer.alpha = (game.healthBar.value / 2);
			boxBGOpponent.alpha = 1 - boxBGPlayer.alpha;

			boxBGPlayer.alpha = boxBGPlayer.alpha * .25;
			boxBGOpponent.alpha = boxBGOpponent.alpha * .25;

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
