import path from "path";
import { defineConfig } from "vite";
import createReactPlugin from "@vitejs/plugin-react";
import createReScriptPlugin from "@jihchi/vite-plugin-rescript";
import { createHtmlPlugin } from "vite-plugin-html";
import { viteStaticCopy } from "vite-plugin-static-copy";
import rescriptconfig from "./rescript.json";

const vars = await (async function () {
  const { NODE_ENV } = process.env;
  const ROOT = process.cwd();

  let entry = "./examples/Index.bs.js";

  return {
    root: ROOT,
    bsDependencies: rescriptconfig["bs-dependencies"].map((name) => ({
      find: name,
      replacement: path.resolve(ROOT, "node_modules", name),
    })),
    nodeEnv: NODE_ENV || "production",
    entry: entry,
  };
})();

export default defineConfig({
  root: vars.root,
  server: {
    port: 3030,
    watch: {
      // Ignore symlinks from the dev server file watcher, to avoid fs loops.
      ignored: [path.resolve(vars.root, "node_modules", "**")],
    },
  },
  plugins: [
    createReactPlugin(),
    createReScriptPlugin(),
    createHtmlPlugin({
      minify: true,
      entry: vars.entry,
      template: "./examples/index.html",
    }),
  ],
});
