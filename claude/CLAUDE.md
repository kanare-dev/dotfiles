# Global Instructions

## Language

Respond in Japanese unless the user writes in another language.

## Git

- Commit messages: use Conventional Commits (`type(scope): summary`), e.g. `fix(api): handle empty response body`.
  - Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `ci`.
- One commit, one purpose. Unless told otherwise, do not mix feature additions, fixes, refactors, and formatting in the same commit; split them into logical units.
- Never stage with `git add -A` or `git add .`. Name the files to add explicitly, so unrelated or pre-existing changes don't slip into the commit.
- If the repository has its own conventions (check recent `git log` and `CONTRIBUTING`), follow them over the rules above.
