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
T = str|bytes

# NOTE: Then constants, singletons
CONST_VALUE = 10
SOME_SINGLETON = SomeData(field_name="…")

# NOTE: Then data structures
@dataclass(slots=True)
class SomeData:
	"""Represents ..."""

	field_name: str


# -----------------------------------------------------------------------------
#
# UTILITIES
#
# -----------------------------------------------------------------------------

# NOTE: Put your utilities first; `__all__` lists the exports, so no `_` prefix

def doSomething(a: int, b: int) -> int:
  """Do something with a and b"""
  ...

# -----------------------------------------------------------------------------
#
# OPERATIONS
#
# -----------------------------------------------------------------------------

# NOTE: Try to group common functions under a class that acts as namespace
# and context.

class SomeOperations:
	"""Provides ..."""

  @staticmethod
  def Run(arg:str) -> None:
		"""Behavior with no context embedded parameter like `arg`."""

	def run(self, arg: str) -> None:
		"""Behavior with context and embedded parameter like `arg`."""
		...

# -----------------------------------------------------------------------------
#
# HIGH-LEVEL API
#
# -----------------------------------------------------------------------------

def myExportedFunction(a: int, b: int) -> int:
  """Exported function that processed a and b"""

# EOF
```

Module Content:
1) Module docstring first
2) Imports at the beginning, standard library first
3) Types, Constant, Dataclasses
4) Utility functions
5) Key operations/functions namespaced under classes
6) High-Level API functions (exports)

Naming:
- Modules are `lowercase` (`module_submodule`->`module/submodule`)
- Classes and singletons are `PascalCase`
- Class and static methods and attributes are `PascalCase`
- Functions, methods, fields, attributes, parameters and locals are `camelCase`
- Globals and constants are `UPPER_CASE`
- No leading `_` on names: `__all__` declares a module's exports, and Python protocol names (`__init__`, `__all__`) keep their spelling
- Write `__all__` as a list literal (`__all__ = ["run", "report"]`), not a computed value such as `"run report".split()`, so linters, type checkers and IDEs can read it

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
- Favor the standard library, avoid third-party dependencies
- Files end with an explicit `# EOF`

Programming Style:
- Data-centric: define dataclasses and namedtuples for your data
- Serialisable: favor simple serialisable data structured (JSON/msgpack-able)
- Functional OOP: function process data, but are grouped in classes for context and namespacing
- Declarative: reading the code should show the intent, which may require creating some abstraction to get there
- Patterns-based: define common patterns in shared modules, or create new ones for repeating code
