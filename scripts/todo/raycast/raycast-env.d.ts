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
}

declare namespace Arguments {
  /** Arguments passed to the `todo` command */
  export type Todo = {
  /** add Buy groceries #errands */
  "query": string
}
}

