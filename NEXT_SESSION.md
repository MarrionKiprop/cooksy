# Resume at: M1

M0 is complete: Cooksy has a committed recovery foundation and preserved briefs;
no application has been scaffolded. See docs/PROGRESS.md for the milestone hash.

First commands:

```bash
cd /home/langstkip/workspace/jac-code/cooksy
export PATH="/home/langstkip/workspace/jac/bin:$PATH"
cat AGENTS.md docs/PROGRESS.md docs/DECISIONS.md NEXT_SESSION.md
git status --short
git log -5 --oneline
jac --version
jac guide jac-core-cheatsheet
jac guide jac-types
jac guide jac-scaffold
jac guide jac-cl-components
jac guide jac-cl-routing
jac guide jac-cl-styling
```

Exact next task: scaffold the web-app in this repository with
`jac create --kind web-app --skip` (no name, no --force), inspect/reconcile generated
files without losing this documentation, then `jac install`. Record verified syntax
in decisions before implementing the warm responsive shell, accessible navigation,
basic pages, and visible development/demo status.

Definition of done: app starts with documented commands; core navigation works;
applicable type/build/tests pass; browser/manual evidence is recorded; recovery
files updated; focused M1 commit and clean tree. Follow the full M1 acceptance
criteria in docs/briefs/implementation-guidance.md. Stop at the milestone boundary.

Blockers/configuration: none for M0; M1 dependency installation may need network
permission. No provider needed for shell. GitHub SSH authentication works as MarrionKiprop; origin is configured for
MarrionKiprop/cooksy. Initial push succeeded and main tracks origin/main.
After each checked commit, run `git push` and compare `git rev-parse HEAD` with
`git ls-remote origin refs/heads/main`. Ongoing pushes are authorized. Provider/weights/GPU setup belongs
to later milestones. No uncommitted files are expected after final ledger commit;
verify git status before starting.
