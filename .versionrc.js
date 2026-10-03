// Release configuration for commit-and-tag-version.
//
// VERSION at the repository root is the single source of truth for the
// application version, and config/initializers/version.rb reads it at boot.
//
// VERSION carries explanatory comments, so it needs a custom updater: the
// built-in plain-text updater treats the entire file as the version string and
// would overwrite the comments along with the number.
//
// `types` is declared explicitly because this repository's documentation is a
// product surface: the README is the install guide and app/views/skill is the
// agent-facing API contract. Letting `docs` fall through to the default preset's
// hidden types would drop user-visible changes from the changelog entirely.
const semverLine = /^(\d+\.\d+\.\d+)$/m;

const versionFile = {
  readVersion(contents) {
    const match = contents.match(semverLine);
    if (!match) {
      throw new Error('VERSION has no bare semver line');
    }
    return match[1];
  },
  writeVersion(contents, version) {
    return contents.replace(semverLine, version);
  },
};

module.exports = {
  tagPrefix: 'v',
  releaseCommitMessageFormat: 'chore(release): {{currentTag}}',
  commitUrlFormat: 'https://github.com/blackopsrepl/elphame/commit/{{hash}}',
  compareUrlFormat:
    'https://github.com/blackopsrepl/elphame/compare/{{previousTag}}...{{currentTag}}',
  types: [
    { type: 'feat', section: 'Features' },
    { type: 'fix', section: 'Bug Fixes' },
    { type: 'perf', section: 'Performance' },
    { type: 'docs', section: 'Documentation' },
    { type: 'test', section: 'Tests' },
    { type: 'build', section: 'Build' },
    { type: 'ci', section: 'Build' },
    { type: 'refactor', section: 'Refactoring' },
  ],
  packageFiles: [{ filename: 'VERSION', updater: versionFile }],
  bumpFiles: [{ filename: 'VERSION', updater: versionFile }],
};
