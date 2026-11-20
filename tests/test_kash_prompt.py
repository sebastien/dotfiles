"""Module: test_kash_prompt — Check the Kash theme without touching live shell state."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


INIT = Path(__file__).resolve().parents[1] / "base/config/kash/init.kash"
BINARY = os.environ.get("KAME_NATIVE_CLI_TEST_BINARY") or shutil.which("kame")
TOOLS = {
	"hostname": 'echo "${TEST_HOST:-cerise-test}"',
	"id": 'echo "${TEST_USER:-tester}"',
	"ps": 'printf "PID\\n123\\n"',
	"date": 'echo 12:34:56',
	"who": 'echo "tester pts/0 (remote)"',
	"cd-store": 'exit 0',
	"git": '''
		test "$TEST_SCM" = git || exit 1
		case "$*" in
			"branch --show-current") echo main ;;
			"rev-parse --short HEAD") echo abc123 ;;
			"status --porcelain") echo " M file" ;;
		esac''',
	"jj": '''
		test "$TEST_SCM" = jj || exit 1
		case "$*" in
			root) echo /repo ;;
			*heads*) echo 'nearest*' ;;
			log*) printf 'abc|%s||!\\n' "$TEST_BOOKMARK" ;;
			diff*) printf 'file | 1 +\\n1 file changed\\n' ;;
		esac''',
	"tput": '''
		case "$1" in
			setaf) printf '\\033[38;5;%sm' "$2" ;;
			bold) printf '\\033[1m' ;;
			rev) printf '\\033[7m' ;;
			sgr0) printf '\\033[0m' ;;
		esac''',
}


@unittest.skipUnless(BINARY, "set KAME_NATIVE_CLI_TEST_BINARY to a freshly built kame")
class KashPromptTest(unittest.TestCase):
	def testTheme(self) -> None:
		with tempfile.TemporaryDirectory() as directory:
			root = Path(directory)
			binPath = root / "bin"
			binPath.mkdir()
			for name, body in TOOLS.items():
				tool = binPath / name
				tool.write_text("#!/bin/sh\n" + body + "\n")
				tool.chmod(0o755)
			(root / ".appenv").touch()
			env = dict(os.environ, PATH=f"{binPath}:/usr/bin:/bin",
				KASH_INIT=str(INIT), KASH_PROFILE="", TERM="xterm-256color",
				NO_COLOR="1", NOCOLOR="", HOME=directory, APPENV_STATUS="dev", TMUX="test")

			def render(status: int = 0, **values: str) -> list[str]:
				result = subprocess.run(
					[BINARY, "do", "run", "--lang", "kash", "-i"],
					input=f'printf "%s\\n" (kash-prompt {{status: {status}, dir: "/work/project"}})\n'
						'printf "%s\\n" (kash-rprompt {status: 0, dir: "/work/project"})\n',
					env=dict(env, **values), cwd=root, text=True, capture_output=True,
					timeout=15,
				)
				self.assertEqual(result.returncode, 0, result.stderr)
				self.assertEqual(result.stderr, "")
				return result.stdout.splitlines()

			for scm, bookmark, expected in [
				("jj", "main*", "[jj abc:main?+] !"),
				("jj", "", "[jj abc:nearest?+] !"),
				("git", "", "[git main+]"),
				("none", "", ""),
			]:
				with self.subTest(scm=scm, bookmark=bookmark):
					left, right = render(TEST_SCM=scm, TEST_BOOKMARK=bookmark)
					self.assertEqual(left, "tester 🍒 ─░▒▓ work/project ▓▒░ ▷ ")
					self.assertNotIn("⛬", left)
					self.assertIn("▶ dev", right)
					if expected:
						self.assertIn(expected, right)
					else:
						self.assertNotIn("[jj ", right)
						self.assertNotIn("[git ", right)
					self.assertIn("⛬ 2 ○12:34:56", right)
					self.assertIn("◫", right)
					self.assertIn("ssh@cerise-test", right)
					self.assertIn("🐢", right)
					self.assertNotIn("\x1b", left + right)
			left, right = render(TEST_SCM="git", NO_COLOR="")
			self.assertIn("\x1b[38;5;214m", left)
			self.assertIn("\x1b[38;5;55m", right)
			self.assertIn("\x1b[1mproject", left)
			self.assertNotIn("\\[", left + right)
			left, _ = render(status=9, TEST_SCM="none", NO_COLOR="")
			self.assertIn("\x1b[38;5;124m", left)
			left, right = render(TEST_SCM="none", NO_COLOR="", NOCOLOR="1")
			self.assertNotIn("\x1b", left + right)
			left, _ = render(TEST_SCM="none", TEST_USER="sebastien")
			self.assertEqual(left, "🍒 ─░▒▓ work/project ▓▒░ ▷ ")
			left, _ = render(TEST_SCM="none", TEST_USER="agent")
			self.assertEqual(left, "🍒 ─░▒▓ work/project ▓▒░ ▷ ")
			for host in ("agents", "agents.example"):
				with self.subTest(host=host):
					left, _ = render(TEST_SCM="none", TEST_HOST=host)
					self.assertEqual(left, "tester 🤖 ─░▒▓ work/project ▓▒░ ▷ ")


if __name__ == "__main__":
	unittest.main()

# EOF
