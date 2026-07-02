package funkin.maki.fightfunk.ui;

import funkin.maki.fightfunk.shaders.WireframeShader;
import funkin.maki.fightfunk.managers.FightBattleManager;
import funkin.maki.fightfunk.managers.FightChartManager;
import funkin.maki.fightfunk.managers.FightEventManager;
import funkin.maki.fightfunk.util.FightUtil;
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
	public var DebugUIEnabled:Bool = false;

	public var visibleProps:Array<Dynamic> = [];
	public var visiblePropNames:Array<String> = [];

	public var game(get, never):PlayState;

	function get_game():PlayState
	{
		return PlayState.instance;
	}

	public var songCode:String = '';

	public var elapsedTotal:Float = 0;

	override public function new()
	{
		super('FightUI');

		middleScroll = false;
	}

	function onCreate(event:ScriptEvent):Void
	{
		super.onCreate(event);

		FightEventManager.damsel_ogAlpha = null;
		middleScroll = false;
	}

	function onDestroy(event:ScriptEvent):Void
	{
		super.onDestroy(event);
		middleScroll = false;

		FightEventManager.damsel_ogAlpha = null;
		clearObjects();
	}

	function onGameOver(event:ScriptEvent):Void
	{
		super.onGameOver(event);

		UIEnabled = false;
		game.currentStage?.getBoyfriend()?.shader = null;
		clearObjects();
	}

	function onSongRetry(event):Void
	{
		super.onSongRetry(event);

		clearObjects();
	}

	function onSongLoaded(event)
	{
		super.onSongLoaded(event);

		songCode = null;
		UIEnabled = false;

		if (game != null)
		{
			songCode = '${game.currentSong.id}-${game.currentVariation}'.toLowerCase().trim();

			if (FightUtil.isFightSong(songCode) && !game.isMinimalMode)
			{
				if (FightEventManager.damsel_ogAlpha == null) FightEventManager.damsel_ogAlpha = game.currentStage?.getGirlfriend().alpha;

				event = FightChartManager.cleanse(songCode, event);
				initFightUI(event);
			}
		}
	}

	function onSongStart(event)
	{
		super.onSongStart(event);

		battleSequence.running = true;

		trace('BATTLE');
	}

	var playerAlpha:Float = 0;
	var opAlpha:Float = 0;

	function onUpdate(event)
	{
		super.onUpdate(event);

		elapsedTotal += event.elapsed;

		if (UIEnabled && game != null)
		{
			playerAlpha = (game?.healthBar?.value / 2) * .25;
			opAlpha = (1 - (playerAlpha * 4)) * .25;

			event = FightEventManager.onUpdate(this, event);
			if (!game?.isInCutscene)
			{
				updateFightUI();
				FightEventManager.onUpdateFightUI(this);
			}
		}
	}

	function onNoteHit(event)
	{
		super.onNoteHit(event);

		if (UIEnabled) event = FightEventManager.onNoteHit(this, FightBattleManager.processNoteHit(this, event));
	}

	function onNoteMiss(event)
	{
		super.onNoteMiss(event);

		// if (UIEnabled) event = FightEventManager.onNoteMiss(this, FightBattleManager.processNoteHit(this, event));
		if (UIEnabled) event = FightEventManager.onNoteMiss(this, event);
	}

	function onPause(event)
	{
		super.onPause(event);

		for (tween in tweens)
			if (tween != null) tween.active = false;

		if (playerBGBoxTween != null) playerBGBoxTween.active = false;
		if (hpBarColorTween != null) hpBarColorTween.active = false;
	}

	function onResume(event)
	{
		super.onResume(event);

		for (tween in tweens)
			if (tween != null) tween.active = true;

		if (playerBGBoxTween != null) playerBGBoxTween.active = true;
		if (hpBarColorTween != null) hpBarColorTween.active = true;
	}

	public var boxBGPlayer:FlxBackdrop;
	public var playerBGBoxTween:FlxTween;

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

	public var currentCameraZoom:Float = 0.5;
	public var defaultCameraZoom:Float = 0.5;

	public var tweens:Array<FlxTween> = [];

	function initFightUI(songEvent)
	{
		var j = 10;

		while (j > 0)
		{
			clearObjects();
			j--;
		}

		final isDownscroll:Bool = (Preferences.controlsScheme == "Arrows" && !ControlsHandler.hasExternalInputDevice)
			|| Preferences.downscroll;

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
		while (i < statTextsCount)
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
		hpBar.color = FightUtil.hpBarDefaultColor;
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
		playerName = FightUtil.nameShortcuts.get(baseName.toLowerCase()) ?? baseName ?? 'Victim';
		battle = FightUtil.getSongBattle(songCode, songEvent);

		resetCamera();

		battleSequence = new SongSequence(FightBattleManager.getBattleSequence(this, battle.events), 1, false);
		battleSequence.startTime = game.startTimestamp;

		game.currentCameraZoom = currentCameraZoom;

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

		FightEventManager.onFightUIInit(this);

		game.refresh();
	}

	public function resetCamera()
	{
		currentCameraZoom = FightUtil.defaultCameraZoom;
		if (battle != null)
		{
			if (battle.camPositionStartOffset != null)
			{
				game.cameraFollowPoint.x += battle.camPositionStartOffset[0] ?? 0;
				game.cameraFollowPoint.y += battle.camPositionStartOffset[1] ?? 0;
			}

			if (battle.camZoomStartOffset != null) currentCameraZoom += battle?.camZoomStartOffset ?? 0.0;
		}

		defaultCameraZoom = currentCameraZoom;
	}

	function addStatText(i)
	{
		var newLine:FlxBitmapText;
		newLine = makeUIText(newLine);
		newLine.text = '_';

		newLine.ID = i;
		newLine.x = 10;
		newLine.y = statBox.y + 10 + (newLine.height * (newLine.ID % 3));
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

		for (tween in tweens)
		{
			tweens.remove(tween);

			if (tween != null)
			{
				tween.cancel();
				tween.destroy();
			}
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
		if (boxBGPlayer != null)
		{
			boxBGPlayer.velocity.x = 40 * (Math.cos(elapsedTotal) * (14 * 0.25));
			boxBGPlayer.velocity.y = 40 * (Math.sin(elapsedTotal) * (25 * 0.25));

			boxBGPlayer.alpha = FlxMath.lerp(boxBGPlayer.alpha, playerAlpha, .15);
		}

		if (boxBGOpponent != null)
		{
			boxBGOpponent.velocity.x = -40 * (Math.sin(elapsedTotal) * (5 * 0.25));
			boxBGOpponent.velocity.y = -40 * (Math.cos(elapsedTotal) * (7 * 0.25));

			boxBGOpponent.alpha = FlxMath.lerp(boxBGOpponent.alpha, opAlpha, .15);
		}

		game.currentCameraZoom = currentCameraZoom;
		game.defaultHUDCameraZoom = 1;
		game.hudCameraZoomIntensity = 0;

		game.camHUD.zoom = game.defaultHUDCameraZoom;

		for (member in game.currentStage?.members)
		{
			if (member == null) continue;
			if (!member.visible) continue;
			if (visibleProps.contains(member)) continue;

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

		if (FlxG.keys.justPressed.COMMA) DebugUIEnabled = !DebugUIEnabled;

		if (DebugUIEnabled)
		{
			statTexts = [
				'STT : ${statCenter.text}',
				'Step: ${Conductor.instance.currentStep}',
				'Beat: ${Conductor.instance.currentBeat}',
			];

			if (statCenter.visible) statCenter.visible = false;
		}
		else
		{
			statTexts = [
				'${playerName} ${tab} LV : ${battle?.level ?? 1}'.toUpperCase(),
				'Score : ' + '${Math.floor(game.songScore)}'.toUpperCase(),
				'Combo Breaks : ' + '${Highscore.tallies.bad + Highscore.tallies.shit + Highscore.tallies.missed}' + ''.toUpperCase(),
			];
		}
		for (line in statLines)
		{
			line.text = statTexts[line.ID] ?? 'line${line.ID}';
			line.visible = !statCenter.visible;
			line.updateHitbox();
			line.screenCenter(0x01);

			// line.x = 10;
			// if (line.ID >= 3) line.x = (statLines[line.ID - 3].x * 2) + (statLines[line.ID - 3].width * 1.1);
		}
	}
}
