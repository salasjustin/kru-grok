# release — ship a roster change

Run after `hire`, `author`, `retire` or `fork-sync` has landed a change that should reach the team, and after `learn` once the user has reviewed its uncommitted diff.

1. On a branch, run `bash scripts/verify.sh` until it passes. It covers `audit`, every `*.test.sh`, frontmatter/data files and version consistency (`VERSION`, the `ROSTER.md` header and the `README.md` version line all equal). Run `bash scripts/smoke.sh` too when the change alters behavior.
2. Commit as `vX.Y.Z: <summary>`. Pushing the branch, opening the PR, merging and pushing the tag all follow wiring-map row #8: the user's approval in chat, which may be a standing grant they gave in chat (for example "merge once verification passes"). Without one, stop here and report the branch.
3. With approval: open the PR. CI (`.github/workflows/verify.yml`) must be green, and the diff must pass a review by someone other than its author (the `code-reviewer` seat or a fresh headless delegate that did not write it).
4. Merge, tag `vX.Y.Z` on the merge commit and push the tag.
5. Report to the user through Tali what changed and how a Grok Bot team picks it up (pull the updated kru-grok checkout). Name any update command only after checking it against that tool's `--help`.
