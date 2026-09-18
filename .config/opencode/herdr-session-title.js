// sidecar to herdr's managed plugins (herdr-tui-session.js); not touched by
// integration reinstalls. Mirrors the selected session's title into herdr
// sidebar metadata tokens $desc1/$desc2 so the agents panel shows the
// conversation topic instead of the generic agent name.

import net from "node:net";

const SOURCE = "opencode-title";
const ROUTE_POLL_INTERVAL_MS = 250;
const LINE_LIMIT = 18;
const TOKEN_MAX = 80;

let reportSeq = Date.now() * 1000;

function splitTitle(title) {
  if (title.length <= LINE_LIMIT) return [title, ""];
  const cut = title.lastIndexOf(" ", LINE_LIMIT);
  const head =
    cut > LINE_LIMIT / 2 ? title.slice(0, cut) : title.slice(0, LINE_LIMIT);
  const tail =
    cut > LINE_LIMIT / 2 ? title.slice(cut + 1) : title.slice(LINE_LIMIT);
  return [
    head,
    tail.length <= TOKEN_MAX ? tail : `${tail.slice(0, TOKEN_MAX - 1)}…`,
  ];
}

export default {
  id: "local.session-title-metadata",
  tui: async (api) => {
    if (
      process.env.HERDR_ENV !== "1" ||
      !process.env.HERDR_SOCKET_PATH ||
      !process.env.HERDR_PANE_ID
    ) {
      return;
    }

    const paneId = process.env.HERDR_PANE_ID;
    const socketEndpoint =
      process.platform === "win32"
        ? `\\\\.\\pipe\\${process.env.HERDR_SOCKET_PATH}`
        : process.env.HERDR_SOCKET_PATH;

    let lastSessionID;
    let lastTitle;

    const report = (tokens) => {
      reportSeq += 1;
      const request = {
        id: `${SOURCE}:${Date.now()}:${reportSeq}`,
        method: "pane.report_metadata",
        params: {
          pane_id: paneId,
          source: SOURCE,
          seq: reportSeq,
          tokens,
        },
      };
      return new Promise((resolve) => {
        const client = net.createConnection(socketEndpoint, () => {
          client.write(`${JSON.stringify(request)}\n`);
        });
        const finish = () => {
          client.destroy();
          resolve();
        };
        client.setTimeout(500, finish);
        client.on("data", finish);
        client.on("error", finish);
        client.on("end", finish);
        client.on("close", resolve);
      });
    };

    const sync = () => {
      const route = api.route.current;
      const sessionID =
        route?.name === "session" ? route.params?.sessionID : undefined;
      const session =
        typeof sessionID === "string" && sessionID
          ? api.state.session.get(sessionID)
          : undefined;
      const title =
        session && !session.parentID && typeof session.title === "string"
          ? session.title.trim()
          : "";
      if (sessionID === lastSessionID && title === lastTitle) return;
      lastSessionID = sessionID;
      lastTitle = title;
      const [desc1, desc2] = title ? splitTitle(title) : ["", ""];
      void report({ desc1, desc2 });
    };

    await sync();
    const poll = setInterval(sync, ROUTE_POLL_INTERVAL_MS);
    api.lifecycle.onDispose(() => clearInterval(poll));
  },
};
