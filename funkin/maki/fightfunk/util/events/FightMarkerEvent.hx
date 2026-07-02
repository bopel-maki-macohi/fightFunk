package funkin.maki.fightfunk.util.events;

import funkin.play.event.SongEvent;

class FightMarkerEvent extends SongEvent
{
	public function new()
	{
		super('FightMarkerEvent');
	}

	public override function getTitle():String
	{
		return 'Battle Marker';
	}

	override public function handleEvent(data:SongEventData):Void {}

	public override function getEventSchema():SongEventSchema
	{
		return [
			{
				name: 'm',
				title: 'Marker',
				defaultValue: 'hmm',
				type: "string"
			}
		];
	}
}
