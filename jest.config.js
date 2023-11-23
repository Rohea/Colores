const rootConfig = require("./rescript.json");
const coloresConfig = require("./packages/colores/rescript.json");
const coloresBsCssConfig = require("./packages/colores-bs-css/rescript.json");

const rescriptDependencies = [
  ...rootConfig["bs-dependencies"],
  ...rootConfig["bs-dev-dependencies"],
  ...coloresConfig["bs-dependencies"],
  ...coloresConfig["bs-dev-dependencies"],
  ...coloresBsCssConfig["bs-dependencies"],
  ...coloresBsCssConfig["bs-dev-dependencies"],
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
  testMatch: ["**/__tests__/**/*_test.bs.js"],
  verbose: true,
};
