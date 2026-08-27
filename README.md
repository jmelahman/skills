# skills

[Agent Skills](https://agentskills.io) I use with Claude Code, kept under version
control so a `git pull` updates every machine I've installed them on.

## Install

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

### From a clone

Pick this one if you'd rather own the checkout — to track a branch, carry local
edits, or send a patch back. `install.sh` symlinks each skill into
`~/.claude/skills/`, which is where Claude Code looks for personal skills, and the
symlinks keep pointing at your working tree:

```sh
git clone https://github.com/jmelahman/skills.git
cd skills
./install.sh
```

```
./install.sh                # link every skill
./install.sh <name>...      # link only the named skills
./install.sh --uninstall    # remove links that point back at this clone
./install.sh --target DIR   # link somewhere other than ~/.claude/skills
```

Updating is `git pull` — the symlinks already point at the new content. The script
never overwrites a real directory, and `--uninstall` only removes symlinks that
resolve back into this repository.

## Layout

```
.claude-plugin/
  marketplace.json   # makes this repo installable via /plugin marketplace add
  plugin.json        # plugin metadata; version is what /plugin update compares
skills/
  <skill-name>/
    SKILL.md         # required: YAML frontmatter + instructions
    references/      # optional: detail the skill loads on demand
```

`skills/<name>/SKILL.md` is the layout Claude Code's plugin loader and the
skills.sh CLI both discover by default, so no manifest entry is needed per skill —
adding a directory is enough.

## Adding a skill

1. Create `skills/<name>/SKILL.md` with `name` and `description` frontmatter. The
   directory name becomes the slash command, so keep it kebab-case.
2. Put anything long in `skills/<name>/references/` and link to it from `SKILL.md`
   so Claude knows what each file holds and when to read it.
3. Bump `version` in **both** `.claude-plugin/plugin.json` and the matching entry
   in `.claude-plugin/marketplace.json` — `/plugin update` compares that field, and
   `claude plugin tag` refuses to tag a release when the two disagree.
4. Run the checks below.

## Checks

[prek](https://github.com/j178/prek) drives everything:

```sh
prek install          # run the checks on every commit
prek run --all-files  # or run them on demand
```

`.pre-commit-config.yaml` is the standard format, so plain
[`pre-commit`](https://pre-commit.com) works too if that's what you have.

The interesting hook is `scripts/validate.py`, which checks that every skill has
frontmatter with a usable `description`, that frontmatter fields are ones agents
actually understand, that relative links in `SKILL.md` resolve, and that the two
manifests agree on name and version. The rest are JSON and YAML parsing plus
shellcheck.

CI runs the same hooks — [`.github/workflows/validate.yml`](.github/workflows/validate.yml)
is just `prek run --all-files` — so a green commit locally is a green build.

For a second opinion from the implementation that actually loads these files:

```sh
claude plugin validate .claude-plugin/plugin.json
```

## License

[GPL-3.0-or-later](LICENSE).
