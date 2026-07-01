package funkin.maki.fightfunk.managers;

import funkin.maki.fightfunk.util.FightUtil;
import funkin.maki.fightfunk.util.FightTimeUtil;
import flixel.tweens.FlxTween;
import funkin.Conductor;

class FightBattleManager
{
	public static function getBattleSequence(ui:FightUI, events:Array<Dynamic>)
	{
		var sequence = [];

		if (ui != null) for (event in events)
		{
			if (event == null) continue;
			if (event.step == null) continue;

			var roadmapEntry =
				{
					time: FightTimeUtil.ms_to_s(Conductor.instance.getStepTimeInMs(event.step)),
					callback: null
				};

			var destinationSteps = event.step + (event.length ?? 16);
			var destinationEntry =
				{
					time: FightTimeUtil.ms_to_s(Conductor.instance.getStepTimeInMs(destinationSteps)),
					callback: null,
				};

			switch (event?.type?.toLowerCase())
			{
				case 'message':
					roadmapEntry.callback = function() {
						ui.statCenter.text = (event?.value ?? 'COOL SWAG').toUpperCase();
						ui.statCenter.screenCenter(0x01);
						ui.statCenter.visible = true;
					};

					destinationEntry.callback = function() {
						ui.statCenter.visible = false;
					};

				case 'effect':
					if (event.value != null && event.value.id != null)
					{
						roadmapEntry.callback = function() {
							ui.activeEffects.push(event.value);
						};

						destinationEntry.callback = function() {
							ui.activeEffects.remove(event.value);
						};
					}
			}

			if (roadmapEntry.callback != null) sequence.push(roadmapEntry);
			if (destinationEntry.callback != null) sequence.push(destinationEntry);
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
