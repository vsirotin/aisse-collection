---
name: typescript
description: Common rules for TypeScript code development. These guidelines apply to interfaces, types, error handling, async patterns, dependency injection, and module structure.
metadata:
  author: vsirotin
  version: "1.4"
---

# 1. Core Principles

## 1.1 Use type for value objects
Value objects like DataVersion should be defined as type:
```typescript
export type DataVersion = {
  version: string;
  build: string;
  timestamp: number;
};
```

## 1.2 Use interface for contracts
Interfaces define behavior, not data:
```typescript
export interface IMetadataProvider {
  getMetadata(): Promise<Result<DataVersion>>;
}
```

## 1.3 Never throw exceptions across layers
All functions return:
```typescript
type Result<T> =
  | { ok: true; data: T }
  | { ok: false; error: AppError };
```

1.4 Use a unified AppError structure
```typescript
export type AppError = {
  code: string;
  description: string;
  instanceId: string;
  timestamp: string;
};
```
Write the same data as the error message in the logs, but with more details (e.g. stack trace, function name, etc.).

## 1.5 Document possible error codes in JSDoc
Not in the interface signature.
```typescript
/**
 * Retrieves metadata.
 * Error codes:
 * - NOT_FOUND
 * - FIRESTORE_ERROR
 */
```

## 1.6 All I/O must be async
Long computations, network, and DB operations must use async/await.
Reason:
Avoid blocking the event loop.

## 1.7 Dependency injection via constructor or function parameter
Logic layer receives only interfaces:
```typescript
getDataVersion(provider: IMetadataProvider, instanceId: string)
```
Reason:
Logic stays infrastructure‑agnostic.

## 1.8 No cross‑layer imports
- Logic imports only interfaces
- Adapters import interfaces
- Wrappers import logic + adapters
- Never import Firebase SDK into logic
Reason:
Strict layering = maintainability.

## 1.9 Use explicit exports
Avoid default exports.
Reason:
Better refactoring, clearer dependency graph.

## 1.10 Logging

Every component and service **must** use the `log4ts` library ([source](https://github.com/vsirotin/digital-treasure-chest/tree/f82ee04686934fc6d618eb02eac5a74fdcc7064a/projects/log4ts)) for logging. Do not use `console.log`, `console.error`, or other `console` calls directly.

### 1.10.1 Logging Setup

Declare a logger as a class field using `LoggerFactory.getLogger(...)`. Use the source-code path of the class as the logger ID (recommended for large applications):

```typescript
import { LoggerFactory } from '@vsirotin/log4ts';

export class MyComponent {
  private readonly logger = LoggerFactory.getLogger('app/pages/my/MyComponent');
}
```

### 1.10.2 Log levels

Use the appropriate level for each message:

| Method | When to use |
|---|---|
| `this.logger.error(...)` | Unrecoverable errors |
| `this.logger.warn(...)` | Recoverable problems or unexpected states |
| `this.logger.log(...)` | Key lifecycle events and state transitions |
| `this.logger.debug(...)` | Internal details useful only during development |

By default, `log4ts` suppresses `log` and `debug` output (only `error` and `warn` are shown). Enable verbose output on demand during development:

```typescript
logger.setLogLevel(0); // show all levels
```

### 1.10.3 Logging and testing

When it is possible to verify internal behaviour by observing `debug`-level log output (captured via a test spy on the logger), **prefer that approach over introducing mocks** for the same purpose. Mocks add coupling and maintenance cost; log-based assertions are lighter and stay close to the real code path.
