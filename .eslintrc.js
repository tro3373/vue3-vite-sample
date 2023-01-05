module.exports = {
  root: true,
  env: {
    es2020: true,
    node: true,
    browser: true,
  },
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module',
    parser: 'babel-eslint',
  },
  extends: ['eslint:recommended', 'prettier', 'plugin:json/recommended'],
  overrides: [
    {
      files: ['**/__tests__/*.{j,t}s?(x)', '**/test/*.spec.{j,t}s?(x)'],
      env: {
        jest: true,
      },
    },
  ],
};
