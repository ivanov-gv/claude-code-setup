---
name: guideline-discovery
description: >
  Discovers and loads relevant guidelines before any coding, review,
  refactoring, implementation, or debugging task. Use this skill at the start
  of any code-related work to ensure the correct guidelines are in context.
  Invoke when specific standards, patterns, or rules are needed.
user-invocable: false
context: fork
agent: Explore
allowed-tools: Read, Glob
---

# Guideline Discovery

Load the correct guidelines for the current task by navigating the shared
guidelines directory tree using README.md files as a map.

## Root
```
~/.claude/shared/
```

## Steps

1. **Detect context**
   Identify the primary language(s) and task type (code, review, testing, etc.)
   from the current task description or files involved.

2. **Read the root README**
   Read `~/.claude/shared/README.md`.
   It describes what top-level category subdirectories exist and what they
   contain. Select the category that matches the task type (e.g. `guidelines/`).

3. **Read the category README**
   Read `~/.claude/shared/{category}/README.md`.
   It describes the subdirectories available. Select the
   subdirectory matching the detected topic and read its README.md. 
   Repeat recursively until you find the necessary files. 

4. **Read the target README**
   Read `~/.claude/shared/guidelines/{category}/.../{topic}/README.md`.
   It lists the files in that directory and what each one covers.

5. **Load relevant files**
   Read only the files that are relevant to the current task.
   Do not load everything — use the README descriptions to select precisely.
   If multiple languages are involved, repeat steps 3–5 for each.

6. **Handle missing paths**
    - If a directory has no README, fall back to listing files with Glob
      and infer their purpose from filenames.
    - If no matching language directory exists, check for a `general/` or
      `default/` directory at the same level and load that instead.
    - If nothing matches, return an explicit notice: no guidelines found
      for `{language}` — proceed without them.

7. **Return guidelines to caller**
   Output the loaded guidelines content in full, clearly labelled by source
   file path. The calling agent uses this output as an active context — does not
   summarize or truncate.

## Output format

Return this to the caller verbatim.

For each file loaded, assess relevance before returning content:

**Partial relevance** — only specific sections apply to the current task.
Extract and return only those sections verbatim. Be precise: a section is
a heading + its content, or a clearly bounded block. Do not paraphrase.

```
### Source: ~/.claude/shared/{path/to/file.md} [excerpt]
{relevant section(s) only, verbatim}
```

**Full relevance** — the entire file applies, or relevance cannot be
determined without reading it all. Return the path and a read directive
instead of the content. The caller will read it when needed.

```
### Source: ~/.claude/shared/{path/to/file.md} [read in full]
This file is fully applicable. Read it entirely before proceeding.
```

Wrap all entries in a single block:

```
## Guidelines for: {language} / {task type}
 
### Source: ... [excerpt]
...
 
### Source: ... [read in full]
...
```

If nothing was found:
```
## Guidelines: none found for {language} / {task type}
Proceeding without language-specific guidelines.
```
