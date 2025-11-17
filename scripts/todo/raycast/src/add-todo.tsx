import { Action, ActionPanel, Form, Toast, popToRoot, showToast } from "@raycast/api";
import { useState } from "react";

import { addTodo, getErrorMessage } from "./lib/todo";

type FormValues = {
  text: string;
};

type AddTodoFormProps = {
  initialText?: string;
  onCreate?: () => void;
};

export default function AddTodoCommand() {
  return <AddTodoForm />;
}

export function AddTodoForm({ initialText = "", onCreate }: AddTodoFormProps) {
  const [text, setText] = useState(initialText);

  async function handleSubmit(values: FormValues) {
    const value = (values.text ?? "").trim();
    if (!value.length) {
      await showToast(Toast.Style.Failure, "Enter a todo");
      return;
    }

    const toast = await showToast(Toast.Style.Animated, "Adding todo...");
    try {
      await addTodo(value);
      toast.style = Toast.Style.Success;
      toast.title = "Todo added";
      setText("");
      onCreate?.();
      await popToRoot({ clearSearchBar: true });
    } catch (error) {
      toast.style = Toast.Style.Failure;
      toast.title = "Failed to add todo";
      toast.message = getErrorMessage(error);
    }
  }

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Add Todo" onSubmit={handleSubmit} />
        </ActionPanel>
      }
    >
      <Form.TextArea
        id="text"
        title="Todo"
        placeholder="Buy groceries #errands"
        value={text}
        onChange={setText}
        autoFocus
      />
    </Form>
  );
}
