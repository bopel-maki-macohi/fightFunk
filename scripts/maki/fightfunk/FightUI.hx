package funkin.maki.fightfunk;

import funkin.maki.fightfunk.WireframeShader;
import funkin.modding.module.Module;
import funkin.play.PlayState;
import funkin.play.components.HealthIcon;
import funkin.mobile.input.ControlsHandler;
import flixel.math.FlxMath;
import flixel.addons.display.FlxBackdrop;
import funkin.graphics.FunkinSprite;
import funkin.graphics.FunkinCamera;
import flixel.text.FlxBitmapText;
import flixel.text.FlxBitmapFont;
import funkin.Highscore;
import flixel.ui.FlxBar;

using StringTools;

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

			if (fightSongs.contains(songCode) && !game.isMinimalMode) initFightUI();
		}
	}

	var elapsedTotal:Float = 0;

	function onUpdate(event)
	{
		super.onUpdate(event);

		elapsedTotal += event.elapsed;

		if (!game?.isInCutscene && fightUIEnabled && game != null) updateFightUI();
	}

	var boxBGPlayer:FlxBackdrop;
	var boxBGOpponent:FlxBackdrop;

	var arrowBox:FunkinSprite;
	var statBox:FunkinSprite;

	var camStrum:FunkinCamera;
	var camStrumYOffsets:Float = -25;

	var hpBar:FlxBar;

	var bfWireframe:WireframeShader;
	var dadWireframe:WireframeShader;
	var damselWireframe:WireframeShader;

	function initFightUI()
	{
		clearObjects();

		final isDownscroll:Bool = #if mobile (Preferences.controlsScheme == FunkinHitboxControlSchemes.Arrows
			&& !ControlsHandler.hasExternalInputDevice)
			|| #end Preferences.downscroll;

		fightUIEnabled = true;

		game.remove(game.scoreText);
		game.remove(game.comboPopUps);
		game.remove(game.healthBarBG);
		game.healthBar.visible = false;
		game.remove(game.iconP1);
		game.remove(game.iconP2);

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
		arrowBox.zIndex = game.healthBarBG.zIndex * (4 * 0.5);
		arrowBox.cameras = [game.camHUD];
		arrowBox.screenCenter(0x01);
		arrowBox.y = (isDownscroll) ? FlxG.height - arrowBox.height + 10 + camStrumYOffsets : -10 - camStrumYOffsets;
		game.add(arrowBox);

		statBox = FunkinSprite.create(0, 0, 'ui/fight/box');
		statBox.antialiasing = false;
		statBox.scale.set(FlxG.width * 1.1 / statBox.width, 3);
		statBox.updateHitbox();
		statBox.zIndex = game.healthBarBG.zIndex * (4 * 0.75);
		statBox.cameras = [game.camHUD];
		statBox.screenCenter(0x01);
		statBox.y = (isDownscroll) ? -10 : FlxG.height - statBox.height + 10;
		game.add(statBox);

		game.playerStrumline.zIndex = arrowBox.zIndex + 100;
		game.playerStrumline.background.visible = false;

		camStrum = new FunkinCamera('playStateCamStrum');
		camStrum.bgColor = game.camHUD.bgColor;
		FlxG.cameras.insert(camStrum, FlxG.cameras.list.indexOf(game.camCutscene) - 1, false);
		camStrum.y = camStrumYOffsets;

		arrowBox.cameras = [camStrum];
		game.playerStrumline.cameras = [camStrum];

		game.playerStrumline.setNoteSpacing(1.2);

		var colors = [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F];

		var i = 0;
		for (strumlineNote in game.playerStrumline.strumlineNotes)
		{
			var strumNoteWireframe = new WireframeShader();
			strumNoteWireframe.setOutlineColor(colors[i]);
			strumNoteWireframe.setFillingColor(0xFFFFFFFF);
			strumlineNote.shader = strumNoteWireframe;
			i++;
		}

		characterText = makeExtraUIText(characterText);
		game.add(characterText);

		characterText.x = 10;
		characterText.y = statBox.y + 10;
		characterText.zIndex = statBox.zIndex + 1;

		comboText = makeExtraUIText(comboText);
		game.add(comboText);

		comboText.x = characterText.x;
		comboText.y = characterText.y + characterText.height + 10;
		comboText.zIndex = characterText.zIndex + 1;

		final b = game.healthBar;

		hpBar = new FlxBar(characterText.x, statBox.y + statBox.height - 40, null, Math.floor(statBox.width * 0.9), 25, game, 'healthLerp', b.min, b.max, false);
		hpBar.zIndex = characterText.zIndex * 2;
		hpBar.screenCenter(0x01);
		hpBar.createFilledBar(0xFF1B0101, 0xFFFFAA00);
		hpBar.cameras = characterText.cameras;
		hpBar.scrollFactor.set();
		game.add(hpBar);

		bfWireframe = new WireframeShader();
		bfWireframe.setOutlineColor(0xFF00FF00);
		game.currentStage?.getBoyfriend()?.shader = bfWireframe;

		dadWireframe = new WireframeShader();
		dadWireframe.setOutlineColor(0xFFFF0000);
		game.currentStage?.getDad()?.shader = dadWireframe;

		damselWireframe = new WireframeShader();
		damselWireframe.setOutlineColor(0xFFFFFFFF);
		game.currentStage?.getGirlfriend()?.shader = damselWireframe;

		for (char in [
			game.currentStage?.getBoyfriend(),
			game.currentStage?.getDad(),
			game.currentStage?.getGirlfriend(),
		])
		{
			if (char?._data.renderType?.contains('atlas'))
				char?.useRenderTexture = true;
		}

		game.refresh();
	}

	var characterText:FlxBitmapText;
	var comboText:FlxBitmapText;

	// base: https://github.com/bopel-maki-macohi/funk_mondays_vslice/blob/develop/scripts/mondays/util/MondayUI.hx#L96C1-L121C3
	function makeExtraUIText(baseText:FlxBitmapText)
	{
		var newText = baseText;

		if (newText != null)
		{
			game.remove(newText);
			newText.destroy();
			newText = null;
		}

		newText = new FlxBitmapText(0, 0, '', FlxBitmapFont.fromAngelCode(Paths.font("vcr-bmp.png"), Paths.font("vcr-bmp.fnt")));
		newText.alignment = game.scoreText.alignment;
		newText.borderStyle = game.scoreText.borderStyle;
		newText.borderColor = game.scoreText.borderColor;
		newText.letterSpacing = game.scoreText.letterSpacing;
		newText.scrollFactor = game.scoreText.scrollFactor;
		newText.scale.set(2, 2);
		newText.cameras = game.scoreText.cameras;
		newText.wordWrap = game.scoreText.wordWrap;
		newText.antialiasing = false;

		return newText;
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

		clearObjects();
	}

	function onGameOver(event:ScriptEvent):Void
	{
		super.onGameOver(event);

		game.currentStage?.getBoyfriend()?.shader = null;
	}

	function clearObjects()
	{
		for (object in [boxBGPlayer, boxBGOpponent, arrowBox, statBox, characterText, hpBar])
		{
			if (object != null)
			{
				game?.remove(object);
				object.destroy();
				object = null;
			}
		}
	}

	function updateFightUI()
	{
		boxBGPlayer.velocity.x = 40 * (Math.cos(elapsedTotal) * (14 * 0.25));
		boxBGPlayer.velocity.y = 40 * (Math.sin(elapsedTotal) * (25 * 0.25));

		boxBGOpponent.velocity.x = -40 * (Math.sin(elapsedTotal) * (5 * 0.25));
		boxBGOpponent.velocity.y = -40 * (Math.cos(elapsedTotal) * (7 * 0.25));

		boxBGPlayer.alpha = (game.healthBar.value / 2);
		boxBGOpponent.alpha = 1 - boxBGPlayer.alpha;

		boxBGPlayer.alpha = boxBGPlayer.alpha * .25;
		boxBGOpponent.alpha = boxBGOpponent.alpha * .25;

		// game.currentCameraZoom = 0.5;
		game.defaultHUDCameraZoom = 1;
		game.hudCameraZoomIntensity = 0;

		game.camHUD.zoom = game.defaultHUDCameraZoom;

		for (member in game.currentStage?.members)
		{
			if (game.currentStage?.getBoyfriend() != member) if (game.currentStage?.getDad() != member) if (game.currentStage?.getGirlfriend() != member)
			{
				member.active = false;
				member.visible = false;
			}
		}

		for (name => prop in game.currentStage?.namedProps)
		{
			if (fightUI_visiblePropName.contains(name))
				prop.active = prop.visible = true;
		}

		if (!middleScroll)
		{
			middleScroll = true;
			hideOpponentStrumline();
			centerPlayerStrumline();
		}

		characterText.text = 'Boyfriend';
		comboText.text = 'Combo : ${Highscore.tallies.combo} (Max: ${Highscore.tallies.maxCombo})'.toUpperCase();
	}
}
