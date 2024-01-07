// @ts-ignore
import { Elm } from "./.elm-land/src/Main.elm";

const getConfig = async () => {
  const res = await fetch("/nocache/config.json").catch((e) => {
    throw new Error(`Failed to load config.json: ${e.message}`);
  });
  const config = await res.json().catch((_) => {
    throw new Error("Failed to decode config.json: Invalid JSON syntax");
  });
  return config;
};

(async () => {
  const config = await getConfig();
  const rootNode = document.querySelector("#app div") as HTMLDivElement;

  Elm.Main.init({
    flags: {
      config,
      windowSize: {
        height: window.innerHeight,
        width: window.innerWidth,
      },
    },
    node: rootNode,
  });
})().catch(() => (window.location.href = "/error.html"));
