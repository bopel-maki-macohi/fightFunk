package funkin.maki.fightfunk.managers;

import funkin.maki.fightfunk.util.FightUtil;
import funkin.maki.fightfunk.util.FightTimeUtil;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import funkin.Conductor;
import funkin.util.ReflectUtil;

class FightBattleManager
{
	static var cameraTweens:Array<FlxTween> = [];

	public static function cancelAllCameraTweens(ui)
	{
		for (tween in cameraTweens)
		{
			if (ui != null) ui.tweens.remove(tween);
			cameraTweens.remove(tween);

			tween.cancel();
		}
	}

	public static function getBattleSequence(ui:FightUI, events:Array<Dynamic>)
	{
		var sequence = [];
		cancelAllCameraTweens(ui);

		// var startPadding = FightTimeUtil.ms_to_s(ui.game.startTimestamp + (Conductor.instance.beatLengthMs * -5));
		// trace(startPadding);

		if (ui != null) for (event in events)
		{
			if (event == null) continue;
			if (event.step == null) continue;
			if (event.type == null) continue;

			var roadmapStr = '${event.step}-${event.type?.toLowerCase()}';
			var destinationStr = null;

			var roadmapEntry =
				{
					time: FightTimeUtil.ms_to_s(Conductor.instance.getStepTimeInMs(event.step)),
					callback: null
				};

			var destinationSteps = (event.length ?? 16);
			var destinationEntry =
				{
					time: null,
					callback: null,
				};

			switch (event?.type?.toLowerCase())
			{
				case 'marker':
					roadmapStr += '-"${event.value}"';
					roadmapEntry.callback = function() {
						trace(event.value);
					};

				case 'message':
					roadmapStr += '_${destinationSteps}-"${event.value}"';
					roadmapEntry.callback = function() {
						ui.statCenter.text = '${event.value}'.toUpperCase();
						ui.statCenter.screenCenter(0x01);
						ui.statCenter.visible = true;
					};

					destinationStr = 'message_remove-"${event.value}"';
					destinationEntry.callback = function() {
						if (ui.statCenter.text == event.value.toUpperCase()) ui.statCenter.visible = false;
					};

				case 'effect':
					if (event.value != null && event.value.id != null)
					{
						roadmapStr += '_${destinationSteps}-"${event.value.id}"';
						roadmapEntry.callback = function() {
							ui.activeEffects.push(event.value);
						};

						destinationStr = 'effect-"${event.value.id}"-removed';
						destinationEntry.callback = function() {
							ui.activeEffects.remove(event.value);
						};
					}

				case 'camera':
					if (event.value != null)
					{
						event.value.ease ??= 'linear';

						var easeFunction = ReflectUtil.field(FlxEase, event.value.ease) ?? FlxEase.linear;
						var isInstant = event.value.instant || event.value.event?.toLowerCase() == 'set';

						var increase:Null<Float> = event.value.increase ?? event.value.value ?? null;

						var length = (isInstant) ? 0 : destinationSteps;
						if (length < 0) length = -length;

						destinationSteps = length;
						length = FightTimeUtil.ms_to_s(Conductor.instance.getStepTimeInMs(event.step + length));

						roadmapStr += '_${event.value.event}';
						if (!isInstant) roadmapStr += '_${destinationSteps}';
						roadmapStr += '-${(isInstant) ? 'instant' : 'transition'}';

						if (event.value.event?.toLowerCase() == 'set' || event.value.event?.toLowerCase() == 'zoom') roadmapStr += '_${increase}';

						if (!isInstant) roadmapStr += '-"${event.value.ease}"';
						if (event.value.cancelOthers || event.value.cancelTweens) roadmapStr += '-cancelOthers';

						switch (event.value.event?.toLowerCase())
						{
							case 'reset':
								roadmapEntry.callback = function() {
									if (event.value.cancelOthers || event.value.cancelTweens) cancelAllCameraTweens(ui);

									var newZoom = ui.defaultCameraZoom;

									if (isInstant)
									{
										ui.currentCameraZoom = newZoom;
										return;
									}
									else
									{
										var thing =
											{
												currentCameraZoom: ui.currentCameraZoom
											};

										var twen = FlxTween.tween(thing, {currentCameraZoom: newZoom}, length,
											{
												ease: easeFunction,
												onUpdate: function(t) {
													ui.currentCameraZoom = thing.currentCameraZoom;
												},
												onComplete: function(t) {
													if (t != null)
													{
														ui.tweens.remove(t);
														cameraTweens.remove(t);
													}
												}
											});

										cameraTweens.push(twen);
										ui.tweens.push(twen);
									}
								};

							case 'zoom':
								if (increase != null)
								{
									roadmapEntry.callback = function() {
										if (event.value.cancelOthers || event.value.cancelTweens) cancelAllCameraTweens(ui);

										var newZoom = ui.currentCameraZoom + increase;

										if (isInstant)
										{
											ui.currentCameraZoom = newZoom;
											return;
										}
										else
										{
											var thing =
												{
													currentCameraZoom: ui.currentCameraZoom
												};

											var twen = FlxTween.tween(thing, {currentCameraZoom: newZoom}, length,
												{
													ease: easeFunction,
													onUpdate: function(t) {
														ui.currentCameraZoom = thing.currentCameraZoom;
													},
													onComplete: function(t) {
														if (t != null)
														{
															ui.tweens.remove(t);
															cameraTweens.remove(t);
														}
													}
												});

											cameraTweens.push(twen);
											ui.tweens.push(twen);
										}
									};
								}

							case 'set':
								if (increase != null)
								{
									roadmapEntry.callback = function() {
										if (event.value.cancelTweens) cancelAllCameraTweens(ui);

										ui.currentCameraZoom = increase;
									}
								}
						}
					}
			}

			destinationEntry.time = FightTimeUtil.ms_to_s(Conductor.instance.getStepTimeInMs(event.step + destinationSteps));

			// roadmapEntry.time += startPadding;
			// destinationEntry.time += startPadding;

			if (roadmapEntry.callback != null)
			{
				if (roadmapStr != null) sequence.push(
					{
						time: roadmapEntry.time,
						callback: function() {
							trace('\nRoadmap Entry (@ ${Conductor.instance.currentStep}): ${roadmapStr}');
						}
					});
				sequence.push(roadmapEntry);
			}
			if (destinationEntry.callback != null)
			{
				if (destinationStr != null) sequence.push(
					{
						time: destinationEntry.time,
						callback: function() {
							trace('\nDestination Entry: ${destinationStr}');
						}
					});
				sequence.push(destinationEntry);
			}
		}

		return sequence;
	}

	public static function processNoteHit(ui:FightUI, event)
	{
		if (ui.game == null) return event;

		var playerStrum = Math.floor(event.note.noteData.data / 4) == 0;
		var holdNote = event.note.length <= Constants.HOLD_DROP_PENALTY_THRESHOLD_MS;

		for (effect in ui.activeEffects)
		{
			if (effect.id == null) continue;

			switch (effect.id?.toLowerCase())
			{
				case 'karma', 'kr', 'drain', 'hp-drain', 'hpdrain':
					if (!playerStrum)
					{
						final calc = effect.strength * ((holdNote) ? 0.1 : 1);

						if (ui.hpBarColorTween != null)
						{
							ui.hpBarColorTween.cancel();
							ui.hpBarColorTween?.destroy();
						}

						ui.hpBarColorTween = FlxTween.color(ui.hpBar, 0.5 + (0.05 * FightTimeUtil.ms_to_s(event.note.length)), FightUtil.hpBarKarmaColor,
							FightUtil.hpBarDefaultColor);

						if (ui.game.health - calc > 0.05) ui.game.health -= calc;
					}
			}
		}

		return event;
	}
}
