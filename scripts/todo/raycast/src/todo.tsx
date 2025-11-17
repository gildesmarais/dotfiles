import { Action, ActionPanel, CommandProps, Icon, List, Toast, showToast } from "@raycast/api";
import { useCachedPromise } from "@raycast/utils";
import { useEffect, useMemo, useRef, useState } from "react";

import {
  TodoItem,
  addTodo,
  defaultLookbackDays,
  fetchRecentTodos,
  getErrorMessage,
  markTodoDone,
  openTodo,
} from "./lib/todo";

type CommandArguments = {
  query?: string;
};

const LOOKBACK_OPTIONS = Array.from(new Set([7, 14, 28, 56, defaultLookbackDays])).sort((a, b) => a - b);

export default function TodoCommand(props: CommandProps<CommandArguments>) {
  const [lookbackDays, setLookbackDays] = useState(defaultLookbackDays);
  const { data, isLoading, revalidate } = useCachedPromise(fetchRecentTodos, [lookbackDays], {
    keepPreviousData: true,
    initialData: [],
  });

  const sections = useMemo(() => groupByDate(data ?? []), [data]);
  const initialQuery = props.arguments?.query?.trim() ?? "";
  const additionHandledRef = useRef(false);

  useEffect(() => {
    if (additionHandledRef.current) {
      return;
    }
    if (!initialQuery || !initialQuery.toLowerCase().startsWith("add")) {
      return;
    }

    const match = initialQuery.match(/^add\s+(.+)/i);
    additionHandledRef.current = true;

    (async () => {
      if (!match) {
        await showToast(Toast.Style.Failure, "Provide todo text after 'add'");
        return;
      }
      const todoText = match[1].trim();
      if (!todoText) {
        await showToast(Toast.Style.Failure, "Provide todo text after 'add'");
        return;
      }
      const toast = await showToast(Toast.Style.Animated, "Adding todo...");
      try {
        await addTodo(todoText);
        toast.style = Toast.Style.Success;
        toast.title = "Todo added";
        toast.message = todoText;
        await revalidate();
      } catch (error) {
        toast.style = Toast.Style.Failure;
        toast.title = "Failed to add todo";
        toast.message = getErrorMessage(error);
      }
    })();
  }, [initialQuery, revalidate]);

  async function handleMarkDone(id: string) {
    const toast = await showToast(Toast.Style.Animated, "Marking todo as done...");
    try {
      await markTodoDone(id);
      toast.style = Toast.Style.Success;
      toast.title = "Todo completed";
      await revalidate();
    } catch (error) {
      toast.style = Toast.Style.Failure;
      toast.title = "Failed to mark todo";
      toast.message = getErrorMessage(error);
    }
  }

  async function handleOpen(id: string) {
    const toast = await showToast(Toast.Style.Animated, "Opening note...");
    try {
      await openTodo(id);
      toast.style = Toast.Style.Success;
      toast.title = "Opened in editor";
    } catch (error) {
      toast.style = Toast.Style.Failure;
      toast.title = "Failed to open";
      toast.message = getErrorMessage(error);
    }
  }

  return (
    <List
      isLoading={isLoading}
      searchBarPlaceholder={`Filter todos from the last ${lookbackDays} days`}
      searchBarAccessory={
        <List.Dropdown
          tooltip="Lookback Window"
          value={String(lookbackDays)}
          onChange={(value) => setLookbackDays(Number.parseInt(value, 10))}
        >
          {LOOKBACK_OPTIONS.map((option) => (
            <List.Dropdown.Item key={option} title={`${option} days`} value={String(option)} />
          ))}
        </List.Dropdown>
      }
    >
      {sections.length === 0 ? (
        <List.EmptyView
          title="No open todos"
          description={`You are all caught up in the last ${lookbackDays} days—type 'todo add ...' to create one.`}
          actions={
            <ActionPanel>
              <Action title="Refresh" onAction={revalidate} />
              <ActionPanel.Submenu title="Set Lookback Window" icon={Icon.Calendar}>
                {LOOKBACK_OPTIONS.map((option) => (
                  <Action
                    key={option}
                    title={`${option} days`}
                    onAction={() => setLookbackDays(option)}
                    style={option === lookbackDays ? Action.Style.Primary : Action.Style.Regular}
                  />
                ))}
              </ActionPanel.Submenu>
            </ActionPanel>
          }
        />
      ) : (
        sections.map(([date, items]) => (
          <List.Section key={date} title={formatDate(date)} subtitle={`${items.length} todo${items.length === 1 ? "" : "s"}`}>
            {items.map((item) => (
              <List.Item
                key={item.id}
                title={item.text}
                accessories={[{ text: item.date }]}
                actions={
                  <ActionPanel>
                    <Action title="Mark Done" onAction={() => handleMarkDone(item.id)} />
                    <Action title="Open in Editor" onAction={() => handleOpen(item.id)} shortcut={{ modifiers: ["cmd"], key: "o" }} />
                    <ActionPanel.Section>
                      <Action.CopyToClipboard title="Copy Todo" content={item.text} />
                      <Action title="Refresh" onAction={revalidate} />
                      <ActionPanel.Submenu title="Set Lookback Window" icon={Icon.Calendar}>
                        {LOOKBACK_OPTIONS.map((option) => (
                          <Action
                            key={option}
                            title={`${option} days`}
                            onAction={() => setLookbackDays(option)}
                            style={option === lookbackDays ? Action.Style.Primary : Action.Style.Regular}
                          />
                        ))}
                      </ActionPanel.Submenu>
                    </ActionPanel.Section>
                  </ActionPanel>
                }
              />
            ))}
          </List.Section>
        ))
      )}
    </List>
  );
}

function groupByDate(items: TodoItem[]): Array<[string, TodoItem[]]> {
  const map = new Map<string, TodoItem[]>();
  for (const item of items) {
    if (!map.has(item.date)) {
      map.set(item.date, []);
    }
    map.get(item.date)!.push(item);
  }
  return Array.from(map.entries()).sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0));
}

function formatDate(value: string) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return value;
  }
  return date.toLocaleDateString(undefined, { weekday: "long", month: "short", day: "numeric" });
}
