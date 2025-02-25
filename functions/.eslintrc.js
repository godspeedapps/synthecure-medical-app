module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    "ecmaVersion": 2018,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "quotes": "off", // Disables double vs single quote errors
    "no-unused-vars": "off", // Disables unused variables warnings
    "max-len": ["error", {"code": 120, "ignoreComments": true}], // Allow 120 chars per line
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
