package funkin.maki.fightfunk.util;

class FightTimeUtil
{
	public static function ms_to_s(ms = 0.0)
	{
		return ms / 1000;
	}

	public static function s_to_ms(s = 0.0)
	{
		return s * 1000;
	}

	public static function m_to_s(m = 0.0)
	{
		return m * 60;
	}

	public static function h_to_m(h = 0.0)
	{
		m_to_s(h);
	}

	public static function h_to_s(h = 0.0)
	{
		return m_to_s(h_to_m(h));
	}

	public static function h_to_ms(h = 0.0)
	{
		return s_to_ms(h_to_s(h));
	}
}
