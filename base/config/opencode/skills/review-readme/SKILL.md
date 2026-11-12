---
name: review-readme
description: When writing, editing or reviewing a project README
---

# README Convention

A README is a letter from the author to someone deciding whether to use the
project. It answers, in order: what is this, why does it exist, what does it
look like to use, how is it designed, and what else is out there. Everything
else belongs in `docs/`.

## Before writing

Read the code, the manifest, the examples and the existing README. You need:
the problem it solves and for whom, the shortest working example, the two to
four design decisions that shape it, and its limits. If the motivation, the
intended audience or the related projects cannot be found in the repository,
ask the author. Do not invent them.

## Structure

````markdown
```
<BANNER: ASCII art of the project name, added by the author>
```

<badges, one line, only if CI or a package exists>

*Name* is a <what it is> for <who/what>. <What it does, in one or two
sentences, with concrete nouns.>

<Second paragraph: the problem or origin, the niche it fills, and where it
does not fit, pointing to an alternative when there is one.>

## Get started

<Prerequisites in one sentence. Install command.>

## In a nutshell

<One complete example, copy-paste runnable, with comments carrying the
explanation. For a CLI, a short session of the core workflow.>

## Features

- *Label*: one line saying what it gives you.

## Design

<The approach in a paragraph, then the main decisions as bullet points,
each with what it trades away. Caveats and known limits go here, stated
plainly. Prose and bullet points only: no source tree, no diagrams.>

## References

<Papers and articles, each with a sentence on why it matters here.>

Related projects, compared to Name:

- [other](url): what it is, and how it differs.

## Where to go next

- [docs/](docs/): what is in there
- [examples/](examples/): how to run them
````

Sections can be renamed to fit (`Quick Start`, `Architecture`, `Use Cases`),
and one that has nothing to say is dropped. The order stays.

## Banner

Do not generate the ASCII art. Leave the placeholder above in a code fence
and tell the author to make their own, for instance with
[TAAG](https://patorjk.com/software/taag/#p=display&f=BBST+Blue&t=Hello&x=none&v=4&h=4&w=80&we=false&ft=thedraw).
If the README already has a banner, keep it untouched.

## Voice

- Write as the author: "you" for the reader, "we" or "our view" for
  opinions. Take a position and say why.
- State limits and trade-offs without softening them. "The UI library is not
  the fastest" earns more trust than a list of strengths.
- Use plain declarative sentences. Name things concretely: the command, the
  file, the number.
- Italics for the project name and feature labels, backticks for code. Bold
  is rare. No emoji.
- Wrap prose at 78 columns.

## Keeping it short

- Aim for 80 to 180 lines. Past 200, move material to `docs/` and link it.
- Show one example, not one per feature.
- Keep the feature list to seven items at most, each a capability. UI
  behaviour, key bindings, option tables and edge cases go in `docs/`.
- Leave out the full CLI or API reference, changelog, roadmap, file-by-file
  source tree, contributing guide and licence text. Link to them.
- When updating an existing README, edit the sentence that changed. Do not
  append a paragraph for every new behaviour.

## Avoid

- Openers and taglines that sell: "powerful", "blazing fast", "seamless",
  "modern", "simple yet flexible".
- A features list that restates the opening paragraph.
- Headings for one-paragraph sections, tables of contents, emoji headings.
- Explaining what the reader already knows (what npm is, what a CLI is).
- Closing summaries or invitations ("Happy hacking!", "Feel free to…").
- Comparisons that only flatter. Say when the other tool is the better pick.

## Check before finishing

- Does the first sentence tell a stranger what this is?
- Can the example be pasted and run as written? Run it if you can.
- Is every claim backed by the code or by the author?
- Does each related project say how it differs, in both directions?
