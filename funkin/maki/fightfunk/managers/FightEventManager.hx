package funkin.maki.fightfunk.managers;

import funkin.maki.fightfunk.util.FightTimeUtil;
import funkin.maki.fightfunk.ui.FightUI;
import funkin.Conductor;
import funkin.graphics.FunkinSprite;
import flixel.util.FlxTimer;
import funkin.play.PlayState;
import funkin.play.PlayStatePlaylist;

using StringTools;

class FightEventManager
{
	static var weekend1_cock = false;
	static var weekend1_explosions = [];
	static var weekend1_canWireframe:WireframeShader;

	static var nene_wireframeFilled:WireframeShader;

	public static function onNoteMiss(ui, event)
	{
		if (ui.game != null)
		{
			switch (event?.note?.kind)
			{
				case "weekend-1-lightcan":
					if (FightUI.songCode.startsWith('2hot')) FunkinSound.playOnce(Paths.sound('Darnell_Lighter'), 1.0);

				case "weekend-1-kickcan":
					if (FightUI.songCode.startsWith('2hot')) FunkinSound.playOnce(Paths.sound('Kick_Can_UP'), 1.0);

				case "weekend-1-kneecan":
					if (FightUI.songCode.startsWith('2hot')) FunkinSound.playOnce(Paths.sound('Kick_Can_FORWARD'), 1.0);

				case "weekend-1-cockgun": // lol
					if (FightUI.songCode.startsWith('2hot')) weekend1_cock = false;
				case "weekend-1-firegun":
					if (FightUI.songCode.startsWith('2hot'))
					{
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
		}

		return event;
	}

	public static function onNoteHit(ui, event)
	{
		if (ui.game != null) switch (event?.note?.kind)
		{
			case "weekend-1-cockgun": // lol
				if (FightUI.songCode.startsWith('2hot'))
				{
					weekend1_cock = true;
					new FlxTimer().start(1.0, function() {
						weekend1_cock = false;
					});
				}
			case "weekend-1-firegun":
				if (FightUI.songCode.startsWith('2hot'))
				{
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

		if (PlayStatePlaylist.campaignId == 'weekend1')
		{
			weekend1_canWireframe = new WireframeShader(0xFFFF0000);
			weekend1_canWireframe.setFillingColor(0xFFFF0000);

			ui.visiblePropNames.push('spraycanPile');
			ui.game?.currentStage.getNamedProp('spraycanPile').shader = weekend1_canWireframe;
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
}
