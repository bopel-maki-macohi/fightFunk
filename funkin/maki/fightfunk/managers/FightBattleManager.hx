package funkin.maki.fightfunk.managers;

import funkin.maki.fightfunk.util.FightUtil;
import funkin.maki.fightfunk.util.FightTimeUtil;
import flixel.tweens.FlxTween;

class FightBattleManager
{
	public static function processNoteHit(ui:FightUI, event)
	{
		if (ui.game == null) return;

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

						ui.hpBarColorTween = FlxTween.color(ui.hpBar, 0.5 + (0.05 * FightTimeUtil.ms_to_s(event.note.length)), FightUtil.hpBarKarmaColor, FightUtil.hpBarDefaultColor);

						if (ui.game.health - calc > 0.05) ui.game.health -= calc;
					}
			}
		}
	}
}
