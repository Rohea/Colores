const rootConfig = require("./rescript.json");
const colorConfig = require("./packages/color/rescript.json");
const colorBsCssConfig = require("./packages/color-bs-css/rescript.json");

const rescriptDependencies = [
  ...rootConfig["bs-dependencies"],
  ...rootConfig["bs-dev-dependencies"],
  ...colorConfig["bs-dependencies"],
  ...colorConfig["bs-dev-dependencies"],
  ...colorBsCssConfig["bs-dependencies"],
  ...colorBsCssConfig["bs-dev-dependencies"],
  "rescript",
];

module.exports = {
  injectGlobals: true,
  testEnvironment: "node",
  transform: {
    "\\.js$": ["babel-jest", { configFile: "./babel.config.jest.js" }],
  },
  // ReScript dependencies must be transformed
  transformIgnorePatterns: [`node_modules/(?!${rescriptDependencies.join("|")}).+\\.js$`],
  // transformIgnorePatterns: ["<rootDir>/node_modules/(?!(rescript|@glennsl/rescript-jest)/)"],
  testMatch: ["**/__tests__/**/*_test.bs.js"],
  // transformIgnorePatterns: ["node_modules/(?!(rescript)/)"],
  verbose: true,
};
