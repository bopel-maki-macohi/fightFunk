package funkin.maki.fightfunk.managers;

import funkin.maki.fightfunk.util.FightTimeUtil;
import funkin.Conductor;

class FightEventManager
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
}
