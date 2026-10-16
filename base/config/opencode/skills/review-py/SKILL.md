---
name: review-py
description: When writing or editing Python code
---

# Python Convention

Follow this template:

```python
"""Module: {name} — {description}."""

from __future__ import annotations

from dataclasses import dataclass

# -----------------------------------------------------------------------------
#
# DEFINITIONS
#
# -----------------------------------------------------------------------------

# NOTE: Types first


@dataclass(slots=True)
class SomeData:
	"""Represents ..."""

	field_name: str


# NOTE: Then constants, singletons
CONST_VALUE = 10
SOME_SINGLETON = SomeData(field_name="…")


# -----------------------------------------------------------------------------
#
# OPERATIONS
#
# -----------------------------------------------------------------------------

# Function: do_something
# Multiplies `a` by `b`.
def do_something(a: int, b: int) -> int:
	return a * b


# -----------------------------------------------------------------------------
#
# API
#
# -----------------------------------------------------------------------------

# NOTE: This is your high-level API/operations
class SomeService:
	"""Provides ..."""

	def run(self, arg: str) -> None:
		"""Behavior with embedded parameter like `arg`."""
		...


# EOF
```

Naming:
- Modules are `lowercase`
- Classes and singletons are `PascalCase`
- Class and static methods and attributes are `PascalCase`
- Functions, methods, fields, attributes, parameters and locals are `camelCase`
- Globals and constants are `UPPER_CASE`
- Private/protected members are prefixed with `_`

Structure:
- Module docstring first
- Imports at the beginning, standard library first
- Type declarations first
- Utilities first
- Functions grouped logically, headers to delimit
- High level APIs last

Documentation:
- Short, behavior-focused docstrings for public elements
- Mention parameters inline using backticks
- Keep wording aligned with type hints and annotations
- Comment when using tricks or hardcoded values
- Compact, not verbose

Style:
- Tabs for indentation
- Comments to explain decisions and help understand complex code
- `NOTE`, `TODO`, `FIXME` to mark notable locations
- Functional, data-driven, declarative
- Favor the standard library, minimize third-party dependencies
- Files end with an explicit `# EOF`
