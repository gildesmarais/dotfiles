import { existsSync } from "fs";
import os from "os";
import path from "path";

import { execa, type ExecaError } from "execa";

export type TodoItem = {
  id: string;
  date: string;
  text: string;
  raw: string;
};

export class TodoCLIError extends Error {
  stderr?: string;

  constructor(message: string, stderr?: string) {
    super(message);
    this.name = "TodoCLIError";
    this.stderr = stderr;
  }
}

const resolvedTodoCommand = resolveTodoCommand();
const loginShell = process.env.TODO_RAYCAST_SHELL || process.env.SHELL || "/bin/zsh";
const useLoginShell = process.env.TODO_RAYCAST_USE_SHELL !== "false";
export const defaultLookbackDays = resolveLookbackDays();

const isExecaError = (error: unknown): error is ExecaError => {
  return typeof error === "object" && error !== null && "stdout" in error;
};

async function runTodo(args: string[]): Promise<string> {
  try {
    if (useLoginShell && loginShell) {
      const commandLine = buildShellCommand(resolvedTodoCommand, args);
      const { stdout } = await execa(loginShell, ["-lc", commandLine], {
        env: buildEnv(),
      });
      return stdout.trim();
    }

    const { stdout } = await execa(resolvedTodoCommand, args, { env: buildEnv() });
    return stdout.trim();
  } catch (error) {
    if (isExecaError(error)) {
      const stderr = error.stderr?.trim();
      const stdout = error.stdout?.trim();
      const message = stderr?.length ? stderr : stdout?.length ? stdout : error.message;
      throw new TodoCLIError(message, stderr);
    }
    throw error;
  }
}

export async function fetchRecentTodos(lookbackDays = defaultLookbackDays): Promise<TodoItem[]> {
  const windowSize = Number.isFinite(lookbackDays) && lookbackDays > 0 ? lookbackDays : defaultLookbackDays;
  const output = await runTodo(["list", "--json", "--lookback-days", String(windowSize)]);
  if (!output) {
    return [];
  }

  try {
    const payload = JSON.parse(output) as TodoItem[];
    return Array.isArray(payload) ? payload : [];
  } catch (error) {
    throw new TodoCLIError("Failed to parse todo list JSON", output);
  }
}

export async function markTodoDone(id: string) {
  if (!id) {
    throw new TodoCLIError("Missing todo identifier");
  }
  await runTodo(["done", "--ids", id]);
}

export async function addTodo(text: string) {
  const value = text.trim();
  if (!value) {
    throw new TodoCLIError("Todo cannot be empty");
  }
  await runTodo(["add", value]);
}

export async function openTodo(id: string) {
  if (!id) {
    throw new TodoCLIError("Missing todo identifier");
  }
  await runTodo(["open", "--id", id]);
}

function resolveTodoCommand(): string {
  const envCandidate = process.env.TODO_RAYCAST_BIN || "";
  if (envCandidate) {
    const expanded = expandHome(envCandidate);
    if (isPathLike(expanded)) {
      if (existsSync(expanded)) {
        return expanded;
      }
    } else {
      return expanded;
    }
  }

  const home = os.homedir();
  const defaults = [path.join(home, ".dotfiles", "scripts", "todo", "todo")];

  for (const entry of defaults) {
    if (existsSync(entry)) {
      return entry;
    }
  }

  return "todo";
}

function expandHome(input: string) {
  if (!input.startsWith("~")) {
    return input;
  }
  return path.join(os.homedir(), input.slice(1));
}

function isPathLike(value: string) {
  return value.includes("/") || value.includes("\\") || value.startsWith(".");
}

function resolveLookbackDays() {
  const fallback = 28;
  const raw = process.env.TODO_RAYCAST_LOOKBACK_DAYS;
  if (!raw) {
    return fallback;
  }
  const parsed = Number.parseInt(raw, 10);
  if (Number.isNaN(parsed) || parsed <= 0) {
    return fallback;
  }
  return parsed;
}

function buildShellCommand(command: string, args: string[]) {
  const parts = [command, ...args].map(shellEscape);
  return parts.join(" ");
}

function shellEscape(value: string) {
  if (value === "") {
    return "''";
  }
  return `'${value.replace(/'/g, `'\\''`)}'`;
}

function buildEnv() {
  return {
    ...process.env,
    TODO_RAYCAST_CONTEXT: "true",
    TODO_PREFER_GUI_OPEN: "true",
  };
}

export function getErrorMessage(error: unknown): string {
  if (error instanceof TodoCLIError) {
    return error.message;
  }
  if (error instanceof Error) {
    return error.message;
  }
  return "Unknown error";
}
