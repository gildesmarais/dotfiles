import { Toast, showToast } from "@raycast/api";

import { addTodo, getErrorMessage } from "./lib/todo";

type CommandArguments = {
  text: string;
};

export default async function QuickAddCommand(props: { arguments: CommandArguments }) {
  const todoText = props.arguments.text?.trim();
  const toast = await showToast(Toast.Style.Animated, "Adding todo...");

  if (!todoText) {
    toast.style = Toast.Style.Failure;
    toast.title = "Missing todo text";
    return;
  }

  try {
    await addTodo(todoText);
    toast.style = Toast.Style.Success;
    toast.title = "Todo added";
    toast.message = todoText;
  } catch (error) {
    toast.style = Toast.Style.Failure;
    toast.title = "Failed to add todo";
    toast.message = getErrorMessage(error);
    throw error;
  }
}
