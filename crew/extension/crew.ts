/**
 * crew — bootstrap + status for the crew workflow (skills/agents/prompts shipped separately).
 *
 * Injects one tagged system-prompt section per run (`crew active` block) and
 * exposes /crew: which roles, models, and crew-* skills are installed.
 */
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const ROLES = ["scout", "sage", "smith", "lens"] as const;

const BOOTSTRAP = `crew active
roles: @scout research/verify · @sage debug/reason · @smith build · @lens vision
thinking: scout low · smith xhigh · sage max · lens low (orchestrator: high)
protocol: force-load /skill:crew-orchestrate before dispatching; ledger -> dispatch background tasks in parallel -> reconcile each terminal result; claims need evidence; images -> @lens (you may not see them).`;

const agentDir = () => path.join(os.homedir(), ".pi", "agent", "agents");
const skillDir = () => path.join(os.homedir(), ".pi", "agent", "skills");

function frontmatter(file: string, key: string): string | undefined {
  try {
    const m = fs.readFileSync(file, "utf8").match(new RegExp(`^${key}:\\s*(.+)$`, "m"));
    return m?.[1].trim();
  } catch {
    return undefined;
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("before_agent_start", (event) => {
    event.systemPromptOptions.sections["crew"] = BOOTSTRAP;
  });

  pi.registerCommand("crew", {
    description: "Show installed crew roles, models, and skills",
    handler: async (_name, ctx) => {
      const lines: string[] = ["crew status"];
      for (const role of ROLES) {
        const file = path.join(agentDir(), `${role}.md`);
        lines.push(
          `  @${role}: ${frontmatter(file, "model") ?? "MISSING (install agents/" + role + ".md)"}`,
        );
      }
      const skills = fs
        .readdirSync(skillDir())
        .filter((d) => d.startsWith("crew-") && fs.existsSync(path.join(skillDir(), d, "SKILL.md")));
      lines.push(`  skills: ${skills.length ? skills.join(" ") : "MISSING (install skills/)"}`);
      ctx.ui.notify(lines.join("\n"), "info");
    },
  });
}
