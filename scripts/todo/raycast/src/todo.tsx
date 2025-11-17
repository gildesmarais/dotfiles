import { Action, ActionPanel, List, Toast, showToast } from "@raycast/api";
import { useCachedPromise } from "@raycast/utils";
import { useMemo } from "react";

import { AddTodoForm } from "./add-todo";
import { TodoItem, fetchMotdTodos, getErrorMessage, markTodoDone } from "./lib/todo";

export default function MotdCommand() {
  const { data, isLoading, revalidate } = useCachedPromise(fetchMotdTodos, [], {
    keepPreviousData: true,
    initialData: [],
  });

  const sections = useMemo(() => groupByDate(data ?? []), [data]);

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

  return (
    <List isLoading={isLoading} searchBarPlaceholder="Filter todos">
      {sections.length === 0 ? (
        <List.EmptyView
          title="No open todos"
          description="You are all caught up—add something new?"
          actions={
            <ActionPanel>
              <Action.Push title="Add Todo" target={<AddTodoForm onCreate={revalidate} />} />
              <Action title="Refresh" onAction={revalidate} />
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
                    <ActionPanel.Section>
                      <Action.Push title="Add Todo" target={<AddTodoForm onCreate={revalidate} />} />
                      <Action.CopyToClipboard title="Copy Todo" content={item.text} />
                      <Action title="Refresh" onAction={revalidate} />
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
