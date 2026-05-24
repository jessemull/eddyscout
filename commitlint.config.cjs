module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'scope-enum': [
      2,
      'always',
      [
        'app',
        'core',
        'design-system',
        'networking',
        'persistence',
        'analytics',
        'routing',
        'localization',
        'tooling',
        'docs',
        'ci',
        'scripts',
        'deps',
        'release',
      ],
    ],
    'scope-empty': [1, 'never'],
    'subject-case': [2, 'never', ['start-case', 'pascal-case', 'upper-case']],
    'body-max-line-length': [1, 'always', 200],
  },
};
