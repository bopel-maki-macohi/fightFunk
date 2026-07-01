package funkin.maki.fightfunk.ui;

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
import funkin.Conductor;
import funkin.util.SongSequence;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

using StringTools;

class FightUI extends Module
{
	final tab = '    ';

	public var middleScroll = false;

	public var UIEnabled:Bool = false;
	public var visiblePropNames:Array<String> = [];

	public var game(get, never):PlayState;

	function get_game():PlayState
	{
		return PlayState.instance;
	}

	public var songCode:String;

	public var elapsedTotal:Float = 0;

	override public function new()
	{
		super('FightUI');

		middleScroll = false;
	}

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
		clearObjects();
	}

	function onSongRetry(event:ScriptEvent):Void
	{
		super.onSongRetry(event);

		clearObjects();
		if (UIEnabled) initFightUI();
	}

	function onSongLoaded(event)
	{
		super.onSongLoaded(event);

		songCode = null;

		if (game != null)
		{
			songCode = '${game.currentSong.id}-${game.currentVariation}'.toLowerCase();

			if (FightConfig.fightSongs.contains(songCode) && !game.isMinimalMode)
			{
				event = FightConfigManager.loadConfig(songCode, event);
				initFightUI();
			}
		}
	}

	function onUpdate(event)
	{
		super.onUpdate(event);

		elapsedTotal += event.elapsed;

		if (!game?.isInCutscene && UIEnabled && game != null) updateFightUI();
	}

	public var boxBGPlayer:FlxBackdrop;
	public var boxBGOpponent:FlxBackdrop;

	public var arrowBox:FightBoxUI;
	public var statBox:FightBoxUI;

	public var camStrum:FunkinCamera;
	public var camStrumYOffsets:Float = -25;

	public var statTexts:Array<String> = [];
	public var statLines:Array<FlxBitmapText> = [];
	public var statTextsCount:Int = 3;

	public var statCenter:FlxBitmapText;

	public var hpBar:FlxBar;
	public final hpBarDefaultColor:FlxColor = 0xFFFFAA00;
	public var hpBarColor:FlxColor = hpBarDefaultColor;
	public var hpBarColorTween:FlxTween;

	public var bfWireframe:WireframeShader;
	public var dadWireframe:WireframeShader;
	public var damselWireframe:WireframeShader;

	public var noteColors = [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F];
	public var strumNoteWireframes:Array<WireframeShader> = [];
	public var noteWireframes:Array<WireframeShader> = [];

	public var playerName:String = 'Victim';

	public var battle:Dynamic;
	public var battleSequence:SongSequence;

	public var activeEffects:Array<Dynamic> = [];

	function initFightUI()
	{
		var j = 10;

		while (j > 0)
		{
			clearObjects();
			j--;
		}

		final isDownscroll:Bool = #if mobile (Preferences.controlsScheme == FunkinHitboxControlSchemes.Arrows
			&& !ControlsHandler.hasExternalInputDevice)
			|| #end Preferences.downscroll;

		UIEnabled = true;

		game.remove(game.scoreText);
		game.remove(game.comboPopUps);
		game.remove(game.healthBarBG);
		game.healthBar.visible = false;
		game.remove(game.iconP1);
		game.remove(game.iconP2);

		boxBGPlayer = FightBoxBG.create(0xff31ff87);
		boxBGPlayer.zIndex = 10;
		game.add(boxBGPlayer);

		boxBGOpponent = FightBoxBG.create(0xffff1d5a);
		boxBGOpponent.zIndex = 0;
		game.add(boxBGOpponent);

		arrowBox = new FightBoxUI();
		arrowBox.zIndex = game.healthBarBG.zIndex * (4 * 0.5);
		arrowBox.cameras = [game.camHUD];
		arrowBox.y = (isDownscroll) ? FlxG.height - arrowBox.height + 10 + camStrumYOffsets : -10 - camStrumYOffsets;
		game.add(arrowBox);

		statBox = new FightBoxUI();
		statBox.zIndex = game.healthBarBG.zIndex * (4 * 0.75);
		statBox.cameras = [game.camHUD];
		statBox.y = (isDownscroll) ? -10 : FlxG.height - statBox.height + 10;
		game.add(statBox);

		camStrum = new FunkinCamera('playStateCamStrum');
		camStrum.bgColor = game.camHUD.bgColor;
		FlxG.cameras.insert(camStrum, FlxG.cameras.list.indexOf(game.camCutscene) - 1, false);
		camStrum.y = camStrumYOffsets;

		arrowBox.cameras = [camStrum];

		var i = 0;
		while (i < 3)
		{
			addStatText(i);
			i++;
		}

		statCenter = makeUIText(statCenter);
		statCenter.screenCenter(0x01);
		statCenter.zIndex = statBox.zIndex * 2;

		statCenter.visible = false;

		game.add(statCenter);

		final b = game.healthBar;

		hpBar = new FlxBar(10, statBox.y + statBox.height - 40, null, Math.floor(statBox.width * 0.9), 25, game, 'healthLerp', b.min, b.max, false);
		hpBar.zIndex = (statBox.zIndex + 1) * 2;
		hpBar.screenCenter(0x01);
		hpBar.createFilledBar(0xFF3F3F3F, 0xFFFFFFFF);
		hpBar.color = hpBarColor;
		hpBar.cameras = statBox.cameras;
		hpBar.scrollFactor.set();
		game.add(hpBar);

		bfWireframe = new WireframeShader(0xFF00FF00);
		game.currentStage?.getBoyfriend()?.shader = bfWireframe;

		dadWireframe = new WireframeShader(0xFFFF0000);
		game.currentStage?.getDad()?.shader = dadWireframe;

		damselWireframe = new WireframeShader();
		game.currentStage?.getGirlfriend()?.shader = damselWireframe;

		for (char in [
			game.currentStage?.getBoyfriend(),
			game.currentStage?.getDad(),
			game.currentStage?.getGirlfriend(),
		])
			if (char?._data.renderType?.contains('atlas')) char?.useRenderTexture = true;

		var baseName = (game.currentStage?.getBoyfriend()?.characterName ?? 'Victim').split('(')[0];
		playerName = FightConfig.nameShortcuts.get(baseName.toLowerCase()) ?? baseName ?? 'Victim';
		battle = FightConfig.getSongBattle(songCode);

		FightConfigManager.currentCameraZoom = FightConfigManager.defaultCurrentCameraZoom;
		if (battle != null)
		{
			if (battle.camPositionStartOffset != null)
			{
				game.cameraFollowPoint.x += battle.camPositionStartOffset[0] ?? 0;
				game.cameraFollowPoint.y += battle.camPositionStartOffset[1] ?? 0;
			}

			if (battle.camZoomStartOffset != null) FightConfigManager.currentCameraZoom += battle?.camZoomStartOffset ?? 0.0;
		}

		battleSequence = new SongSequence(FightEventManager.getBattleSequence(this, battle.events));
		battleSequence.startTime = 0;

		game.currentCameraZoom = FightConfigManager.currentCameraZoom;

		game.currentStage.zIndex = 300;

		game.playerStrumline.zIndex = arrowBox.zIndex + 100;
		game.playerStrumline.background.visible = false;

		#if !mobile
		game.playerStrumline.setNoteSpacing(((FlxG.height / FlxG.width) * 2.8) * ((FlxG.width / FlxG.height) / (FlxG.initialWidth / FlxG.initialHeight)));
		#end

		game.playerStrumline.cameras = [camStrum];

		var i = 0;
		for (strumlineNote in game.playerStrumline.strumlineNotes)
		{
			var strumNoteWireframe = new WireframeShader();
			strumNoteWireframe.setOutlineColor(noteColors[i]);
			strumNoteWireframe.setFillingColor(0xFFFFFFFF);

			var noteWireframe = new WireframeShader();
			noteWireframe.setOutlineColor(noteColors[i]);
			noteWireframe.setFillingColor(noteColors[i]);

			strumNoteWireframes.push(strumNoteWireframe);
			noteWireframes.push(noteWireframe);

			strumlineNote.shader = strumNoteWireframe;
			i++;
		}

		game.refresh();
	}

	function onNoteHit(event)
	{
		super.onNoteHit(event);

		FightBattleManager.processNoteHit(this, event);
	}

	function addStatText(i)
	{
		var newLine:FlxBitmapText;
		newLine = makeUIText(newLine);
		newLine.text = '_';

		newLine.ID = i;
		newLine.x = 10;
		newLine.y = statBox.y + 10 + (newLine.height * newLine.ID);
		newLine.zIndex = statBox.zIndex + 1 + (newLine.height * (newLine.ID + 1));

		game.add(newLine);
		statLines.push(newLine);
	}

	// base: https://github.com/bopel-maki-macohi/funk_mondays_vslice/blob/develop/scripts/mondays/util/MondayUI.hx#L96C1-L121C3
	function makeUIText(baseText:FlxBitmapText)
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
		if (opponentStrumline != null) for (arrow in opponentStrumline.members)
			arrow.visible = false;
	}

	function centerPlayerStrumline()
	{
		// This is a song gimmick we are never making middlescroll an option.

		if (Preferences.controlsScheme == "Arrows" && !ControlsHandler.usingExternalInputDevice) return;

		var playerStrumline:FlxSprite = game.playerStrumline;
		if (playerStrumline != null) playerStrumline.x = FlxG.width / 2 - playerStrumline.width / 2;
	}

	function clearObjects()
	{
		var objs = [boxBGPlayer, boxBGOpponent, arrowBox, statBox, hpBar];
		var objArrays = [statLines];

		for (array in objArrays)
		{
			for (obj in array)
			{
				array.remove(obj);
				game?.remove(obj);
				obj.destroy();
			}

			array = [];
		}

		for (object in objs)
		{
			if (object != null)
			{
				game?.remove(object);
				object.destroy();
				object = null;
			}
		}

		noteWireframes = [];
		strumNoteWireframes = [];

		battleSequence?.destroy();
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

		game.currentCameraZoom = FightConfigManager.currentCameraZoom;
		game.defaultHUDCameraZoom = 1;
		game.hudCameraZoomIntensity = 0;

		game.camHUD.zoom = game.defaultHUDCameraZoom;

		for (member in game.currentStage?.members)
		{
			if (!member.visible) continue;

			if (game.currentStage?.getBoyfriend() != member) if (game.currentStage?.getDad() != member) if (game.currentStage?.getGirlfriend() != member)
			{
				member.active = false;
				member.visible = false;
			}
		}

		for (name => prop in game.currentStage?.namedProps)
		{
			if (prop.visible) continue;
			if (visiblePropNames.contains(name)) prop.active = prop.visible = true;
		}

		if (!middleScroll)
		{
			middleScroll = true;
			hideOpponentStrumline();
			centerPlayerStrumline();
		}

		for (noteGroup in [
			game.playerStrumline.notes,
			game.playerStrumline.holdNotes,
			// game.playerStrumline.noteSplashes,
			game.playerStrumline.noteHoldCovers,
		])
		{
			for (note in noteGroup)
				note.shader = noteWireframes[note.noteDirection ?? note.direction];
		}

		if (statCenter != null)
		{
			statCenter.y = statBox.getGraphicMidpoint().y - (statCenter.height / 1) - 10;
			statCenter.screenCenter(0x01);
		}

		statTexts[0] = '${playerName} ${tab} LV : ${battle?.level ?? 1}'.toUpperCase();
		statTexts[1] = 'Score : ' + '${Math.floor(game.songScore)}'.toUpperCase();
		statTexts[2] = 'Combo Breaks : ' + '${Highscore.tallies.bad + Highscore.tallies.shit + Highscore.tallies.missed}' + ''.toUpperCase();

		for (line in statLines)
		{
			line.text = statTexts[line.ID];
			line.visible = !statCenter.visible;
		}
	}
}
