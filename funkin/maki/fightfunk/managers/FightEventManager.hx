package funkin.maki.fightfunk.managers;

import funkin.maki.fightfunk.util.FightTimeUtil;
import funkin.maki.fightfunk.ui.FightUI;
import funkin.Conductor;
import funkin.graphics.FunkinSprite;
import flixel.util.FlxTimer;
import funkin.play.PlayState;
import funkin.play.PlayStatePlaylist;
import funkin.audio.FunkinSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import funkin.Conductor;
import funkin.util.ReflectUtil;
import flixel.FlxSprite;
import haxe.ds.ArraySort;

using StringTools;

class FightEventManager
{
	static var blammed_emotionalMoment = false;

	static var weekend1_cock = false;
	static var weekend1_explosions = [];
	static var weekend1_canWireframe:WireframeShader;

	static function weekend1_2hot_applyShaders(ui)
	{
		for (can in ui.game?.currentSong?.spawnedCans)
		{
			can.active = can.visible = true;
			can.shader = weekend1_canWireframe;
		}
		for (splode in weekend1_explosions)
		{
			if (splode != null)
			{
				splode.active = splode.visible = true;
				splode.shader = weekend1_canWireframe;
			}
		}
	}

	static function weekend1_explosion_shot(onDone:Dynamic = null):FunkinSprite
	{
		var can = PlayState.instance?.currentSong?.getNextCanWithState(2);

		var explode:FunkinSprite = FunkinSprite.createSparrow(can?.x + 150, can?.y - 300, "SpraypaintExplosion");
		explode.animation.addByPrefix("idle", "Explosion 1 movie0", 24, false);
		explode.animation.play("idle");

		explode.zIndex = 1000;
		PlayState.instance.currentStage.add(explode);
		PlayState.instance.currentStage.refresh();

		explode.animation.onFinish.add(() -> {
			explode.kill();

			if (onDone != null) onDone(explode);
		});

		return explode;
	}

	static function weekend1_explosion_hit(onDone:Dynamic = null):FunkinSprite
	{
		var can = PlayState.instance?.currentSong?.getNextCanWithState(2);

		var explodeEZ:FunkinSprite = FunkinSprite.createSparrow(can.x + 750, can.y - 150, "spraypaintExplosionEZ");
		explodeEZ.animation.addByPrefix("idle", "explosion round 1 short0", 24, false);
		explodeEZ.animation.play("idle");

		explodeEZ.zIndex = 1000;
		PlayState.instance.currentStage.add(explodeEZ);
		PlayState.instance.currentStage.refresh();

		explodeEZ.animation.finishCallback = () -> {
			explodeEZ.kill();
			if (onDone != null) onDone(explodeEZ);
		};
		return explodeEZ;
	}

	static var nene_wireframeFilled:WireframeShader;

	static function flashPlayerBG(tempColor, ui)
	{
		if (ui == null) return;
		if (ui.boxBGPlayer == null) return;

		if (ui.playerBGBoxTween != null)
		{
			ui.playerBGBoxTween.cancel();
			ui.playerBGBoxTween.destroy();
		}

		ui.playerBGBoxTween = FlxTween.color(ui.boxBGPlayer, 0.15, tempColor, ui.boxBGPlayer.color,
			{
				startDelay: .25,
				ease: FlxEase.expoOut,

				onComplete: function(tween) {
					ui.playerBGBoxTween.cancel();
					ui.playerBGBoxTween?.destroy();
				}
			});
	}

	public static function onNoteMiss(ui, event)
	{
		var playerStrum = Math.floor(event.note.noteData.data / 4) == 0;

		var tempColor = 0xFF6C8CFD;
		// if (playerStrum && !blammed_emotionalMoment) flashPlayerBG(tempColor, ui);

		if (ui.game != null)
		{
			switch (event?.note?.kind)
			{
				case "weekend-1-cockgun": // lol
					weekend1_cock = false;
				case "weekend-1-firegun":
					weekend1_cock = false;

					var splode:FunkinSprite;
					splode = weekend1_explosion_hit(function(explodeEZ) {
						ui.game?.currentStage?.remove(explodeEZ);
						weekend1_explosions.remove(splode);
					});

					weekend1_explosions.push(splode);
					ui.game?.currentStage?.add(splode);
			}
		}

		return event;
	}

	public static var damsel_ogAlpha:Float = 1;

	public static function onNoteHit(ui, event)
	{
		var tempColor = 0xFFFFFD5C;

		switch (event.judgement?.toLowerCase())
		{
			case 'sick':
				tempColor = 0xFFFFAFFF;
			case 'good':
				tempColor = 0xFFFFFFBC;
			// tempColor = 0xFFFCFFFF;
			case 'bad':
				tempColor = 0xFFFFAB86;
			case 'shit':
				tempColor = 0xFF6C8CFD;
		}

		var playerStrum = Math.floor(event.note.noteData.data / 4) == 0;
		// if (playerStrum && !blammed_emotionalMoment) flashPlayerBG(tempColor, ui);

		if (ui.game != null)
		{
			switch (event?.note?.kind)
			{
				case "weekend-1-lightcan":
					weekend1_2hot_applyShaders(ui);
					FunkinSound.playOnce(Paths.sound('Darnell_Lighter'), 1.0);

				case "weekend-1-kickcan":
					weekend1_2hot_applyShaders(ui);
					FunkinSound.playOnce(Paths.sound('Kick_Can_UP'), 1.0);

				case "weekend-1-kneecan":
					weekend1_2hot_applyShaders(ui);
					FunkinSound.playOnce(Paths.sound('Kick_Can_FORWARD'), 1.0);
				case "weekend-1-cockgun": // lol
					weekend1_cock = true;
					new FlxTimer().start(1.0, function() {
						weekend1_cock = false;
					});
				case "weekend-1-firegun":
					if (weekend1_cock)
					{
						trace('Firing gun!');

						var splode:FunkinSprite;
						splode = weekend1_explosion_shot(function(explodeEZ) {
							ui.game?.currentStage?.remove(explodeEZ);
							weekend1_explosions.remove(splode);
						});

						weekend1_explosions.push(splode);
						ui.game?.currentStage?.add(splode);
					}
					else
					{
						trace('Cannot fire gun!');
						// The player cannot hit this note.
						event.cancelEvent();

						var splode:FunkinSprite;
						splode = weekend1_explosion_hit(function(explodeEZ) {
							ui.game?.currentStage?.remove(explodeEZ);
							weekend1_explosions.remove(splode);
						});

						weekend1_explosions.push(splode);
						ui.game?.currentStage?.add(splode);
					}
			}
		}

		return event;
	}

	public static function onUpdate(ui, event)
	{
		return event;
	}

	public static function onUpdateFightUI(ui)
	{
		var daddy = ui.game?.currentStage?.getDad();
		var gf = ui.game?.currentStage?.getGirlfriend();

		if (gf?.characterId?.startsWith('nene') && nene_wireframeFilled != null)
		{
			gf.abotViz.shader = nene_wireframeFilled;
			for (viz in gf.abotViz.members)
				viz.shader = nene_wireframeFilled;
		}

		if (ui.game?.currentSong?.id == '2hot')
		{
			weekend1_2hot_applyShaders(ui);
		}
	}

	public static function onFightUIInit(ui)
	{
		if (ui.game == null) return;

		FlxG.camera.filters = [];

		var daddy = ui.game?.currentStage?.getDad();
		var gf = ui.game?.currentStage?.getGirlfriend();

		if (gf?.characterId?.startsWith('nene'))
		{
			nene_wireframeFilled = new WireframeShader();
			nene_wireframeFilled.setFillingColor(0xFFFFFFFF);

			ui.visibleProps.push(gf.abot);
			ui.visibleProps.push(gf.abotViz);
		}

		if (ui.game.currentStage.id == 'phillyTrainErect')
		{
			ui.game?.currentStage?.trainEnabled = false;
		}

		if (ui.game.currentStage.id == 'phillyStreets')
		{
			weekend1_canWireframe = new WireframeShader(0xFFFF0000);
			weekend1_canWireframe.setFillingColor(0xFFFF0000);

			ui.visiblePropNames.push('spraycanPile');
			ui.game?.currentStage.getNamedProp('spraycanPile').shader = weekend1_canWireframe;
		}

		if (damsel_ogAlpha != null) gf?.alpha = damsel_ogAlpha;

		if (ui.songCode == 'blammed-erect')
		{
			trace('ola');
			var referenceColors = [0xFF10FFFF, 0x00000000, 0xFFFE00BA, 0xFF000822, 0x00000000, 0xFF0C001C];
			var ogColors = [
				ui.bfWireframe.getOutlineColor(),
				ui.damselWireframe.getOutlineColor(),
				ui.dadWireframe.getOutlineColor(),

				ui.bfWireframe.getFillingColor(),
				ui.damselWireframe.getFillingColor(),
				ui.dadWireframe.getFillingColor(),
			];
			var boxes = [ui.boxBGPlayer, ui.boxBGOpponent,];
			var ogBoxColors = [ui.boxBGPlayer.color, ui.boxBGOpponent.color,];

			ui.battleSequence.events.push(
				{
					time: Conductor.instance.getStepTimeInMs(512),
					callback: function() {
						blammed_emotionalMoment = true;
						for (ID => charWireframe in [0 => ui.bfWireframe, 1 => ui.damselWireframe, 2 => ui.dadWireframe,])
						{
							charWireframe.setOutlineColor(referenceColors[ID]);
							charWireframe.setFillingColor(referenceColors[ID + 3]);
						}

						if (damsel_ogAlpha == null) damsel_ogAlpha = gf?.alpha;
						gf?.alpha = 0;

						ui.boxBGPlayer.color = referenceColors[0];
						ui.boxBGOpponent.color = referenceColors[2];
					}
				});

			ui.battleSequence.events.push(
				{
					time: Conductor.instance.getStepTimeInMs(768),
					callback: function() {
						blammed_emotionalMoment = false;
						for (ID => charWireframe in [0 => ui.bfWireframe, 1 => ui.damselWireframe, 2 => ui.dadWireframe,])
						{
							var outlineColor = new FlxSprite();
							var outlineTwen = FlxTween.color(outlineColor, 2, charWireframe.getOutlineColor(), ogColors[ID],
								{
									ease: FlxEase.expoOut,
									onUpdate: function(tween) {
										charWireframe.setOutlineColor(outlineColor.color);
									}
								});
							ui.tweens.push(outlineTwen);

							var fillingColor = new FlxSprite();
							var fillingTwen = FlxTween.color(fillingColor, outlineTwen.duration, charWireframe.getFillingColor(), ogColors[ID + 3],
								{
									ease: FlxEase.expoOut,
									onUpdate: function(tween) {
										charWireframe.setFillingColor(fillingColor.color);
									}
								});

							ui.tweens.push(fillingTwen);
						}

						ui.tweens.push(FlxTween.tween(gf, {alpha: damsel_ogAlpha}, 2,
							{
								ease: FlxEase.expoOut,
							}));

						ui.tweens.push(FlxTween.color(ui.boxBGPlayer, 0.15, ui.boxBGPlayer.color, ogBoxColors[0],
							{
								ease: FlxEase.expoOut,
								onUpdate: function(tween) {
									ui.boxBGPlayer.alpha = ui.playerAlpha;
								},
							}));
						ui.tweens.push(FlxTween.color(ui.boxBGOpponent, 0.15, ui.boxBGOpponent.color, ogBoxColors[1],
							{
								ease: FlxEase.expoOut,
								onUpdate: function(tween) {
									ui.boxBGOpponent.alpha = ui.opAlpha;
								},
							}));
					}
				});

			ArraySort.sort(ui.battleSequence.events, function(a, b):Int {
				if (a.time < b.time) return -1;
				if (a.time > b.time) return 1;
				return 0;
			});
		}
	}
}
