# skills

[Agent Skills](https://agentskills.io) I use with Claude Code, kept under version control and
updated with a simple `git pull`.

## Install

### From a clone

A simple way to track and manage skills either in your home directory.

```sh
git clone git@github.com:jmelahman/skills.git ~/.claude/skills/jmelahman
cd ~/.claude/skills
ln -s jmelahman/skills/testing testing
```

The clone has no top-level `SKILL.md`, so Claude Code ignores it and picks up only

Running `git pull` in the clone will update the content via symlinks.

### Into a project with `git subtree`

To check skills into a project so that everyone working on it gets them, vendor
this repository with `git subtree` and link what you want into `.claude/skills/`,
where Claude Code looks for project skills:

```sh
git remote add skills git@github.com:jmelahman/skills.git
git subtree add --prefix .claude/skills/jmelahman skills master --squash
ln -s jmelahman/skills/testing .claude/skills/testing
git add .claude/skills/testing && git commit -m "Add the testing skill"
```

Update with:

```sh
git subtree pull --prefix .claude/skills/jmelahman skills master --squash
```

Unlike a submodule, the content lands in the project's own history, so a plain
`git clone` of the project brings the skills along — nobody else needs an init or
update step. `--squash` keeps this repository's commits out of the project log;
drop it to keep the full history.

### As a Claude Code plugin

The repository is its own [plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces).
Inside Claude Code:

```
/plugin marketplace add jmelahman/skills
/plugin install skills@jmelahman-skills
```

Skills arrive namespaced as `/skills:<name>`, and `/plugin update skills` picks up
new versions. This is the option to pick if you just want the skills.

### With the skills.sh CLI

For Claude Code, Cursor, Copilot, and the other agents [skills.sh](https://skills.sh)
supports:

```sh
npx skills add jmelahman/skills
```

## Checks

[prek](https://github.com/j178/prek) drives everything:

```sh
prek run --all-files
```

CI runs the same hooks — [`.github/workflows/validate.yml`](.github/workflows/validate.yml)

For a second opinion from the implementation that actually loads these files:

```sh
claude plugin validate .claude-plugin/plugin.json
```

## License

[GPL-3.0-or-later](LICENSE).
