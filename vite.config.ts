import { defineConfig } from "vite";
// @ts-ignore
import { resolve } from "path";
import elmPlugin from "vite-plugin-elm";

// --------- User-adjustable

const host = "0.0.0.0"; // "0.0.0.0" = Allow clients from local network

const elmDevSettings = {
  debug: false, // true = enable Elm debugger and show debugger UI
  optimize: false,
};

// --------- App-specific

const port = 1234;

// --------- Common

export default defineConfig(({ command }) => {
  const elmProdSettings = { debug: false, optimize: true };
  const elmSettings =
    command === "build"
      ? elmPlugin(elmProdSettings)
      : elmPlugin(elmDevSettings);

  return {
    plugins: [elmSettings],
    server: { host, port, strictPort: true },
    build: {
      rollupOptions: {
        input: {
          // @ts-ignore
          main: resolve(__dirname, "index.html"),
          // @ts-ignore
          error: resolve(__dirname, "error.html"),
        },
      },
    },
    preview: { host, port, strictPort: true },
  };
});
