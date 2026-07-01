package funkin.maki.fightfunk;

class FightEventManager
{
	public static function getBattleSequence(events:Array<Dynamic>)
	{
		var sequence = [];

		for (event in events)
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
						statCenter.text = (event?.value ?? 'COOL SWAG').toUpperCase();
						statCenter.screenCenter(0x01);
						statCenter.visible = true;
					};

					destinationEntry.callback = function() {
						statCenter.visible = false;
					};

				case 'effect':
					if (event.value != null && event.value.id != null)
					{
						roadmapEntry.callback = function() {
							activeEffects.push(event.value);
						};

						destinationEntry.callback = function() {
							activeEffects.remove(event.value);
						};
					}
			}

			if (roadmapEntry.callback != null) sequence.push(roadmapEntry);
			if (destinationEntry.callback != null) sequence.push(destinationEntry);
		}

		return sequence;
	}
}
