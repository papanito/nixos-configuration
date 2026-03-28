module.exports = {
  extends: ['@commitlint/config-conventional'],
  parserPreset: {
    name: 'conventional-changelog-conventionalcommits',
    parserOpts: {
      // RegEx: type[scope]: subject
      headerPattern: /^(\w+)(?:\[([^\]]+)\])?:\s*(.*)$/,
      headerCorrespondence: ['type', 'scope', 'subject'],
    },
  },
  rules: {
    // Sentence Case for the subject [Level, Applicability, Case]
    // 'sentence-case' ensures the first letter is capitalized, rest is lower
    'subject-case': [2, 'always', 'sentence-case'],
    'subject-empty': [2, 'never'],

    // Block (Error) if the subject itself is longer than 72 chars
    // [Level 2 = Error, Applicability, Length]
    'subject-max-length': [2, 'always', 72],

    //  Warn if the whole header is longer than 50 chars
    // [Level 1 = Warning, Applicability, Length]
    'header-max-length': [1, 'always', 50],
    // Disable the global 'scope-empty' rule so we can handle it manually
    'scope-empty': [0],
    'scope-enum': [2, 'always', [
      'api',
      'infra',
      'ui',
      'security']],

    'type-enum': [1, 'always', ['clawfinger', 'envy', 'rpi4', 'lenovo', 'profiles']],
  },
};
