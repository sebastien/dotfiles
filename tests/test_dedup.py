"""Module: test_dedup — Exercise the dedup command with real files."""

import hashlib
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


COMMAND = Path(__file__).resolve().parents[1] / "bin" / "dedup"


class DedupTest(unittest.TestCase):
	def testInputsAndErrors(self) -> None:
		with tempfile.TemporaryDirectory() as directory:
			root = Path(directory)
			for name, content in [("a", b"same"), ("b space", b"same"), ("c", b"different"), ("empty", b"")]:
				(root / name).write_bytes(content)

			def run(*args: str, data: bytes = b"") -> subprocess.CompletedProcess:
				return subprocess.run(
					[sys.executable, str(COMMAND), *args], input=data,
					cwd=root, capture_output=True,
				)

			args = ("a", "b space", "c", "empty")
			result = run(*args)
			self.assertEqual(result.returncode, 0, result.stderr)
			self.assertIn(f"{hashlib.sha256(b'same').hexdigest()} (2 files)".encode(), result.stdout)
			self.assertIn(f"{hashlib.sha256(b'different').hexdigest()} (1 file)".encode(), result.stdout)
			self.assertIn(f"{hashlib.sha256(b'').hexdigest()} (1 file)".encode(), result.stdout)
			self.assertEqual(run(data="\n".join(args).encode()).stdout, result.stdout)
			self.assertEqual(run("-0", data="\0".join(args).encode()).stdout, result.stdout)
			self.assertEqual(run("a", "a").stdout, run("a").stdout)
			self.assertEqual(run().stdout, b"")

			(root / "line\nbreak").write_bytes(b"same")
			unusual = run("-0", data=b"a\0line\nbreak\0")
			self.assertEqual(unusual.returncode, 0, unusual.stderr)
			self.assertIn(b'(2 files)\n  "a"\n  "line\\nbreak"\n', unusual.stdout)

			failed = run("missing", ".", "a")
			self.assertEqual(failed.returncode, 1)
			self.assertIn(b"missing", failed.stderr)
			self.assertIn(b"not a regular file", failed.stderr)
			self.assertEqual(failed.stdout, run("a").stdout)


if __name__ == "__main__":
	unittest.main()

# EOF
