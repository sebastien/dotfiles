---
name: review-js
description: When writing or editing JavaScript code
---

# JavaScript Convention

Follow this template:

```javascript
/** Module: {name} — {description}. */

import { someUtility } from "./utility.js";

// -----------------------------------------------------------------------------
//
// DEFINITIONS
//
// -----------------------------------------------------------------------------

// NOTE: Types first, using JSDoc rather than TypeScript syntax
/** @typedef {string|Uint8Array} T */
/** @typedef {{fieldName: string}} SomeData */

// NOTE: Then constants, singletons
const CONST_VALUE = 10;
const SomeSingleton = { fieldName: "…" };

// NOTE: Then data structures, using plain objects unless behavior is needed
class SomeContext {
	/** Represents the context for `fieldName`. */
	constructor(fieldName) {
		this.fieldName = fieldName;
	}
}

// -----------------------------------------------------------------------------
//
// UTILITIES
//
// -----------------------------------------------------------------------------

// NOTE: Put your utilities first; `export` marks the public API, so no `_` prefix

/** Do something with `a` and `b`.
 * @param {number} a
 * @param {number} b
 * @returns {number}
 */
function doSomething(a, b) {
	return a + b;
}

// -----------------------------------------------------------------------------
//
// OPERATIONS
//
// -----------------------------------------------------------------------------

// NOTE: Try to group common functions under a class that acts as namespace
// and context.

/** Provides operations with optional embedded context. */
class SomeOperations {
	/** Behavior with no instance context, using `arg`. */
	static Run(arg) {
		return someUtility(arg);
	}

	constructor(context) {
		this.context = context;
	}

	/** Behavior with instance context and parameter `arg`. */
	run(arg) {
		return someUtility(arg, this.context);
	}
}

// -----------------------------------------------------------------------------
//
// HIGH-LEVEL API
//
// -----------------------------------------------------------------------------

/** Process `a` and `b`.
 * @param {number} a
 * @param {number} b
 * @returns {number}
 */
export function myExportedFunction(a, b) {
	return doSomething(a, b);
}

// EOF
```

Module Content:
1) Module documentation comment first
2) Imports at the beginning, runtime built-ins first, then dependencies, then local modules
3) JSDoc types, constants, singletons, data structures
4) Utility functions
5) Key operations/functions namespaced under classes
6) High-Level API functions (exports)

Naming:
- Modules are `lowercase` (`module_submodule` -> `module/submodule.js`)
- Classes and singletons are `PascalCase`
- Static methods and static attributes are `PascalCase`
- Functions, instance methods, fields, attributes, parameters and locals are `camelCase`
- Globals and constants are `UPPER_CASE`
- No leading `_` on names: `export` declares a module's public API

Documentation:
- Short, behavior-focused JSDoc comments for public elements
- Mention parameters inline using backticks
- Keep wording aligned with JSDoc types and the actual behavior
- Comment when using tricks or hardcoded values
- Compact, not verbose

Style:
- Tabs for indentation
- Comments to explain decisions and help understand complex code
- `NOTE`, `TODO`, `FIXME` to mark notable locations
- Functional, data-driven, declarative
- Favor language features and runtime built-ins, avoid third-party dependencies
- Use ES modules, `const` by default, and `let` when reassignment is needed
- Files end with an explicit `// EOF`

Programming Style:
- Data-centric: define data shapes with JSDoc typedefs and use plain objects and arrays
- Serialisable: favor simple serialisable data structures (JSON/msgpack-able)
- Functional OOP: functions process data, but are grouped in classes for context and namespacing
- Declarative: reading the code should show the intent, which may require creating some abstraction to get there
- Patterns-based: define common patterns in shared modules, or create new ones for repeating code
