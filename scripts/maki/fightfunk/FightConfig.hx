package funkin.maki.fightfunk;

import funkin.maki.fightfunk.FightTimeUtil;
import funkin.play.PlayState;

class FightConfig
{
	public static var currentCameraZoom:Float = 0.5;

	public static function loadConfig(songCode:String, event)
	{
		currentCameraZoom = 0.5;

		trace('songCode: $songCode');

		trace(event.events.length);

		event.events = cleanseCamStuffs(event.events);
		event.events = cleanseCamStuffs(event.events);

		event.events = loadEvents(songCode, event.events);

		trace(event.events.length);

		return event;
	}

	static function cleanseCamStuffs(events)
	{
		var camEvents = ['focuscamera', 'zoomcamera', 'setcamerabop',];

		for (eventCls in events)
		{
			var eventStr = eventCls.eventKind.toLowerCase();

			if (camEvents.contains(eventStr)) events.remove(eventCls);
			else trace(eventStr);
		}

		return events;
	}

	static function loadEvents(songCode:String, events)
	{
		switch (songCode)
		{
			case 'dadbattle-erect':
				events.push(focusCamera(FightTimeUtil.s_to_ms(-1), 0));
		}

		return events;
	}

	static function focusCamera(ms = 0.0, char = -1, x = 0.0, y = 0.0, duration = 4, ease = 'CLASSIC', easeDir = 'In')
	{
		return {
			t: ms,
			e: 'FocusCamera',
			v:
				{
					char: char,
					x: x,
					y: y,
					duration: duration,
					ease: ease,
					easeDir: easeDir,
				}
		}
	}
}
