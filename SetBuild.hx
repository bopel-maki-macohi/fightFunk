import sys.io.File;
import haxe.Json;

class SetBuild
{
	static function main()
	{
		var localChanges = GitShit.getGitHasLocalChanges();
		var build = GitShit.getGitCommitNumber() + (localChanges ? 1 : 0);

		trace('localChanges: $localChanges');
		trace('build: $build');

		var meta = Json.parse(File.getContent('_polymod_meta.json'));

		var mod_versionARRAY:Array<String> = meta.mod_version.split('.');

		while (mod_versionARRAY.length < 3)
			mod_versionARRAY.push('0');

		if (mod_versionARRAY[2] != '$build' && !localChanges) build++;

		mod_versionARRAY[2] = '$build';

		var mod_version:String = mod_versionARRAY.join('.');

		trace('mod_version: $mod_version');

		meta.mod_version = mod_version;
		File.saveContent('_polymod_meta.json', Json.stringify(meta, '\t'));
	}
}

class GitShit
{
	/**
	 * Get whether the local Git repository is dirty or not.
	 */
	public static function getGitHasLocalChanges()
	{
		// Get the current line number.
		var branchProcess = new sys.io.Process('git', ['status', '--porcelain']);

		if (branchProcess.exitCode() != 0)
		{
			var message = branchProcess.stderr.readAll().toString();
			trace(message);
			return false;
		}

		var output:String = '';
		output = branchProcess?.stdout?.readAll().toString() ?? '';
		trace(output);

		// Generates a string expression
		return output.length > 0;
	}

	public static function getGitCommitNumber()
	{
		// Get the current line number.
		var process = new sys.io.Process('git', ['rev-list', 'HEAD', '--count']);
		if (process.exitCode() != 0)
		{
			var message = process.stderr.readAll().toString();
			trace(message);
			return 0;
		}

		// Generates a string expression
		return Std.parseInt(process.stdout.readLine());
	}
}
