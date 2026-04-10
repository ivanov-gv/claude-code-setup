---
name: contribute-cli
description: When and how to use contribute cli for GitHub interactions. Use whenever you need to do anything related to GitHub or GitHub repos.
---

# Login, pull, commit, push

`contribute login` automatically configures git for the app's bot identity:

```
INF login: git credential helper configured for github.com
INF login: git identity configured user.email=115546723+ai-contributor-helper[bot]@users.noreply.github.com user.name=ai-contributor-helper[bot]
INF login: authenticated successfully app=AI contributor helper app_id=3063096
```
This sets:

git config --global user.name → {app-slug}[bot]
git config --global user.email → {installation_id}+{app-slug}[bot]@users.noreply.github.com

So git commit and git push work immediately after login with no further setup.

Check with: `contribute auth status`

# PR interaction

```
# install
go install github.com/ivanov-gv/contribute/cmd/contribute@latest

# see PR details (auto-detects from current branch)
contribute pr

# list all comments and reviews on a PR
contribute comments

# post a comment
contribute comment "Fixed the issue, please re-review"

# react to a comment
contribute react 123456789 eyes --type issue
contribute react 987654321 rocket --type review

# show inline comments for a specific review
contribute review 3929204495

# show all comments in a thread across reviews (use thread id from review output)
contribute thread 2935138407

# reply to a review comment in-thread
contribute reply 2935138407 "Fixed, thanks"

# resolve a thread
contribute resolve 2935138407

# post an inline review comment
contribute review-comment "Nit: rename this variable" --file internal/cmd/pr.go --line 42

# approve a PR
contribute submit-review --event APPROVE --body "LGTM"
```

# Get GitHub token

`contribute token` writes valid token to stdout. Use to authenticate gh.s
