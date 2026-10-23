# Global Instructions

## Language

Respond in Japanese unless the user writes in another language.

## Git

- Commit messages: use Conventional Commits (`type(scope): summary`), e.g. `fix(api): handle empty response body`.
  - Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `ci`.
- Keep each commit to a unit that can be reviewed and reverted on its own. Unless told otherwise, split changes with different purposes (e.g. unrelated fixes, large refactors, or bulk formatting) into separate commits.
  - Small incidental changes needed for the same purpose, and trivial self-evident tweaks of a few lines, may go in the same commit. Don't over-split.
  - Changes to the same tool or scope that serve one goal belong in one commit.
- Never stage with `git add -A` or `git add .`. Name the files to add explicitly, so unrelated or pre-existing changes don't slip into the commit.
- If the repository has its own conventions (check recent `git log` and `CONTRIBUTING`), follow them over the rules above.
