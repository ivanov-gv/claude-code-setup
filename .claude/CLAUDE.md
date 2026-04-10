# Guidelines

You are precisely following all organisational, project, and team guidelines. It is your duty and responsibility.
Guidelines are located at `~/.claude/shared/guidelines/**/*` - search for them using this regex.
Also available at `https://github.com/ivanov-gv/claude-code-setup/tree/main/.claude/shared/guidelines`.
Load only guidelines relevant to the current task to avoid context overflow. All changes must comply with guideline
requirements and will be subject to review.

Content of the guidelines folder:

```
.claude/shared/guidelines/code/general:
total 32
drwxrwxr-x 2 ivanov_gv ivanov_gv 4096 Apr 10 19:28 .
drwxrwxr-x 5 ivanov_gv ivanov_gv 4096 Apr  9 17:52 ..
-rw-rw-r-- 1 ivanov_gv ivanov_gv 1742 Apr  9 17:52 coding.md
-rw-rw-r-- 1 ivanov_gv ivanov_gv 1334 Apr 10 19:28 deploy.md
-rw-rw-r-- 1 ivanov_gv ivanov_gv 2100 Apr 10 19:20 documentation.md
-rw-rw-r-- 1 ivanov_gv ivanov_gv 1642 Apr  9 17:52 optimisation.md
-rw-rw-r-- 1 ivanov_gv ivanov_gv   12 Apr  9 17:52 review.md
-rw-rw-r-- 1 ivanov_gv ivanov_gv 1502 Apr  9 17:52 testing.md

.claude/shared/guidelines/code/golang:
total 36
drwxrwxr-x 2 ivanov_gv ivanov_gv 4096 Apr 10 19:26 .
drwxrwxr-x 5 ivanov_gv ivanov_gv 4096 Apr  9 17:52 ..
-rw-rw-r-- 1 ivanov_gv ivanov_gv  885 Apr  9 17:52 build-and-deploy.md
-rw-rw-r-- 1 ivanov_gv ivanov_gv 9973 Apr  9 18:30 conventions.md
-rw-rw-r-- 1 ivanov_gv ivanov_gv 2026 Apr 10 19:26 linting.md
-rw-rw-r-- 1 ivanov_gv ivanov_gv 1924 Apr  9 17:52 optimisation.md
-rw-rw-r-- 1 ivanov_gv ivanov_gv 3705 Apr  9 17:52 testing.md

.claude/shared/guidelines/code/python:
total 8
drwxrwxr-x 2 ivanov_gv ivanov_gv 4096 Apr  9 17:52 .
drwxrwxr-x 5 ivanov_gv ivanov_gv 4096 Apr  9 17:52 ..
-rw-rw-r-- 1 ivanov_gv ivanov_gv    0 Apr  9 17:52 python-specific-conventions.md
```

# contribute

You are likely authenticated with `github.com/ivanov-gv/contribute`. Use it to interact with github and authenticate `gh`.

All gh commands should be prefixed with GH_TOKEN=$(contribute token):

```
GH_TOKEN=$(contribute token) gh pr list                                                                                                                                                                        
GH_TOKEN=$(contribute token) gh repo view ivanov-gv/contribute
```

Call `contribute --help` for more.
