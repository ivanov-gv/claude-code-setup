---  
name: review-cycle  
description: Full AI agent workflow — pick an issue, code, push, create PR, respond to reviews

---  

# Review Cycle Skill

You are an AI agent working on a GitHub repository using `contribute` CLI.

## Usage

```  
/review-cycle issue <issue-number>       — Start from an issue  
/review-cycle pr <pr-number>             — Resume on an existing PR  
```  

If no argument is given, auto-detect the PR from the current branch.

## Full Workflow (from issue)

### 1. Pick and read the issue

`contribute issue <number>`

Understand the task from the issue body, comments, and labels.

### 2. Implement the fix

1. Authenticate using `contribute`, if needed.
2. Create a branch: `git checkout -b issue/<issue-number>-<short-description>`
3. Write code, run tests (`make test`), lint (`make lint`)
4. Commit: `git commit -m "Fix #<number>: <description>"`
5. Push: `git push -u origin <branch>`

### 3. Create a PR

Use `GH_TOKEN=$(contribute token) gh pr create` with `Fixes #<number>` in the body, then notify:

`contribute comment "Ready for review" --pr <N>`

### 4. Enter the review loop

## Review Loop (for new or existing PRs)

### 1. Read the current PR state

`contribute comments --pr <N>`

Look for new reviews (CHANGES_REQUESTED or COMMENTED) that have not been addressed.

### 2. For each unaddressed review

`contribute review <review-id> --pr <N>`

Read all inline threads. Understand the overall feedback before making changes.

### 3. For each thread in the review

1. **Acknowledge** — react with eyes to signal you've seen it:
   ```bash  
   contribute react <comment-id> EYES   
   ```  
2. **Understand** — read the comment body and the file/line context.

3. **Fix** — make the requested code change.

4. **Reply** — tell the reviewer what you did:
   ```bash  
   contribute reply <comment-id> "Fixed in <short-sha> — <what you changed>"   
   ```  
5. **React** — signal completion:
   ```bash  
   contribute react <comment-id> ROCKET   
   ```  

### 4. Push and notify

```bash  
git push
contribute comment "All feedback addressed, PTAL" --pr <N>
```  

### 5. Check for approval

```bash  
contribute comments --pr <N>
```  

If the latest review is APPROVED, the cycle is complete. Otherwise, wait for the next review.

## Commands

See `contribute --help`

## Important Notes

- Always read the full review before making changes — understand the overall feedback first.
- A comment made to particular lines of code may be applicable to other changes too. It is important to address feedback
  entirely and apply changes to the other lines too. Address comment in general, not only to particular lines.
- Group related fixes into a single commit when possible.
- If a comment is unclear, reply asking for clarification instead of guessing.
- Never force-push during a review cycle — it breaks the review context.
- Use `contribute thread <thread-id>` to see the full conversation history of a specific thread.
