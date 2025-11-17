/// <reference types="@raycast/api">

/* 🚧 🚧 🚧
 * This file is auto-generated from the extension's manifest.
 * Do not modify manually. Instead, update the `package.json` file.
 * 🚧 🚧 🚧 */

/* eslint-disable @typescript-eslint/ban-types */

type ExtensionPreferences = {}

/** Preferences accessible in all the extension's commands */
declare type Preferences = ExtensionPreferences

declare namespace Preferences {
  /** Preferences accessible in the `todo` command */
  export type Todo = ExtensionPreferences & {}
  /** Preferences accessible in the `add-todo` command */
  export type AddTodo = ExtensionPreferences & {}
  /** Preferences accessible in the `quick-add` command */
  export type QuickAdd = ExtensionPreferences & {}
}

declare namespace Arguments {
  /** Arguments passed to the `todo` command */
  export type Todo = {}
  /** Arguments passed to the `add-todo` command */
  export type AddTodo = {}
  /** Arguments passed to the `quick-add` command */
  export type QuickAdd = {
  /** Buy groceries #errands */
  "text": string
}
}

