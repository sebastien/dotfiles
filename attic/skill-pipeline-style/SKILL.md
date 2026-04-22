---
name: pipeline-style
description: Use it when writing data pipelines
version: 0.1.0
user-invocable: true
---

# Pipeline Style Guidelines

Pipeline style means writing code as a compact vocabulary of composable operations. Instead of building long procedural blocks, we define small, named operations and combine them into clear data-flow pipelines.

## Core Principles

### 1. Prefer composition over control flow

A pipeline should read as a sequence of transformations.

Prefer this:

```ts
const ExtractEntities = pipeline(
	(name) => LoadFile(`src/json/ref-${name}.json`),
	(_) => grouped(_, "fibery/id"),
	(_) => map(_, ary(1, head)),
);
```

Avoid this:

```ts
async function ExtractEntities(name) {
	const file = await LoadFile(`src/json/ref-${name}.json`);
	const groups = grouped(file, "fibery/id");
	const result = map(groups, ary(1, head));
	return result;
}
```

The pipeline version makes the shape of the computation visible: load, group, select.

### 2. Use a compact vocabulary of operations

Pipeline code should rely on a small set of reusable operations such as (available
in select.js utils):

```ts
map
filter
reduce
head
grouped
ary
pipeline
```



Agents should prefer existing vocabulary before introducing new helpers.

When adding a new operation, make sure it is:

* small
* reusable
* easy to compose
* named as a domain operation, not as an implementation detail

### 3. Name high-level operations in PascalCase

Domain-level pipeline functions should use PascalCase because they behave like named nodes in a processing graph.

```ts
const LoadFile = (path) => Bun.file(path).json();

const ExtractEntities = pipeline(
	(name) => LoadFile(`src/json/ref-${name}.json`),
	(_) => grouped(_, "fibery/id"),
	(_) => map(_, ary(1, head)),
);
```

Use PascalCase for operations such as:

```ts
LoadFile
ExtractEntities
ResolveReferences
BuildIndex
OutputConfiguration
```

Use lower-case names for generic utilities and local variables.

### 4. Keep pipeline steps small

Each pipeline step should do one thing.

Good:

```ts
(_) => grouped(_, "fibery/id")
```

Less good:

```ts
(_) => map(grouped(_, "fibery/id"), ary(1, head))
```

Prefer clarity over cleverness. A pipeline is readable when each step has a clear purpose.

### 5. Use comments to explain intent, not mechanics

Comments should explain why the step exists or what role it plays in the pipeline.

Good:

```ts
const ExtractEntities = pipeline(
	// Loads the JSON reference file
	(name) => LoadFile(`src/json/ref-${name}.json`),

	// Groups records by Fibery id
	(_) => grouped(_, "fibery/id"),

	// Keeps the first entity from each group
	(_) => map(_, ary(1, head)),
);
```

Avoid comments that merely repeat syntax.

Bad:

```ts
// Calls grouped
(_) => grouped(_, "fibery/id")
```

### 6. Let `pipeline` handle async flow

Pipeline functions may contain async operations. Do not manually thread `await` through every step unless the surrounding API requires it.

Good:

```ts
const LoadFile = (path) => Bun.file(path).json();

const ExtractEntities = pipeline(
	(name) => LoadFile(`src/json/ref-${name}.json`),
	(_) => grouped(_, "fibery/id"),
	(_) => map(_, ary(1, head)),
);
```

Callers should await the composed pipeline result:

```ts
console.log(await ExtractEntities("entities"));
```

### 7. Use `_` for the current pipeline value

Inside simple transformation steps, use `_` to represent the value flowing through the pipeline.

```ts
(_) => grouped(_, "fibery/id")
```

Use a named parameter when the input has domain meaning.

```ts
(name) => LoadFile(`src/json/ref-${name}.json`)
```

This keeps generic transformations visually distinct from domain inputs.

### 8. Separate pure transformations from side effects

Most pipeline steps should be pure transformations.

For side effects, yield commands instead of executing effects directly.

```ts
class Command {
	constructor(name, args) {
		this.name = name;
		this.args = args;
	}
}

function cmd(name, ...args) {
	return new Command(name, args);
}
```

Commands describe effects without performing them immediately.

### 9. Use generator pipelines for command-producing workflows

When a pipeline needs external effects, model those effects as yielded commands.

```ts
const OutputConfiguration = function* () {
	const path = yield cmd("config", "data.path");
	yield cmd("log", `Output path is ${path}`);
};
```

This allows the runtime to decide how commands are executed, cached, logged, replayed, mocked, or tested.

### 10. Return values are still meaningful

A pipeline may yield commands and still return a value.

The returned value is the result of the pipeline. Yielded commands are requests for effects.

```ts
const BuildOutput = function* () {
	const path = yield cmd("config", "data.path");
	yield cmd("log", `Output path is ${path}`);

	return { path };
};
```

### 11. Keep command names small and stable

Command names should be compact strings that represent effect types.

Good:

```ts
cmd("config", "data.path")
cmd("log", "Done")
cmd("write", path, data)
cmd("read", path)
```

Avoid command names that encode too much behavior.

Bad:

```ts
cmd("read-config-path-and-log-output-folder")
```

The command name should identify the kind of effect. The arguments should provide the details.

### 12. Design for loose coupling and caching

Commands create a boundary between the pipeline and the outside world.

This makes it possible to:

* cache command results
* mock commands in tests
* replay workflows
* inspect side effects
* swap runtimes
* keep business logic pure

Agents should prefer yielded commands whenever an operation touches IO, configuration, logging, network, databases, files, or environment state.

## Style Rules

### Do

Use pipelines for multi-step transformations:

```ts
const BuildIndex = pipeline(
	(_) => grouped(_, "type"),
	(_) => map(_, ary(1, head)),
);
```

Name domain operations clearly:

```ts
const ExtractEntities = pipeline(...);
const ResolveLinks = pipeline(...);
const BuildOutput = pipeline(...);
```

Use commands for effects:

```ts
yield cmd("log", "Starting export");
yield cmd("write", path, data);
```

Keep steps readable:

```ts
(_) => filter(_, isActive)
(_) => map(_, toEntity)
(_) => grouped(_, "id")
```

### Avoid

Avoid deeply nested expressions:

```ts
(_) => map(grouped(filter(_, isActive), "id"), toEntity)
```

Avoid mixing side effects into transformations:

```ts
(_) => {
	console.log(_);
	return _;
}
```

Prefer:

```ts
yield cmd("log", value);
```

Avoid large anonymous functions inside pipelines. Extract them into named operations instead.

```ts
const NormalizeEntity = (_) => ({
	id: _["fibery/id"],
	name: _.name,
});

const NormalizeEntities = pipeline(
	(_) => map(_, NormalizeEntity),
);
```

## Recommended Pattern

A good pipeline module usually has this shape:

```ts
import {
	map,
	filter,
	reduce,
	head,
	pipeline,
	grouped,
	ary,
} from "@select/utils";

const LoadFile = (path) => Bun.file(path).json();

const NormalizeEntity = (_) => ({
	id: _["fibery/id"],
	name: _.name,
});

const ExtractEntities = pipeline(
	// Loads the JSON reference file
	(name) => LoadFile(`src/json/ref-${name}.json`),

	// Groups records by Fibery id
	(_) => grouped(_, "fibery/id"),

	// Keeps one entity per Fibery id
	(_) => map(_, ary(1, head)),

	// Normalizes entity shape
	(_) => map(_, NormalizeEntity),
);
```

## Mental Model

Think of pipeline style as building a graph of named processing nodes.

Each operation should answer one of these questions:

1. What data enters this step?
2. What transformation happens here?
3. What data leaves this step?
4. Are there any effects, and if so, are they represented as commands?

The best pipeline code reads almost like a table of contents for the computation.

