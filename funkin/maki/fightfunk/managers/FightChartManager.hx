package funkin.maki.fightfunk.managers;

import funkin.play.PlayState;

class FightChartManager
{
	public static function cleanse(songCode:String, event)
	{
		trace('songCode: $songCode');

		var iterations = 10;

		while (iterations > 0)
		{
			event.events = cleanseCamStuffs(event.events);
			iterations--;
		}

		event = songStuff(songCode, event);

		// trace(event.events.length);

		return event;
	}

	static function songStuff(songCode:String, event)
	{
		var game = PlayState.instance;

		if (game == null || game.isMinimalMode)
		{
			return event;
		}

		var gf = game.currentStage?.getGirlfriend();

		if (gf != null && gf.cameraFocusPoint != null)
		{
			game.cameraFollowPoint.setPosition(gf.cameraFocusPoint.x, gf.cameraFocusPoint.y);
		}

		return event;
	}

	static function cleanseCamStuffs(events)
	{
		var camEvents = ['focuscamera', 'zoomcamera', 'setcamerabop',];

		for (eventCls in events)
		{
			var eventStr = eventCls.eventKind.toLowerCase();

			if (camEvents.contains(eventStr)) events.remove(eventCls);
			// else trace(eventStr);
		}

		return events;
	}
}
