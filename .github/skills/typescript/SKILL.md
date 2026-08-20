---
name: typescript
description: Common rules for TypeScript code development. These guidelines apply to interfaces, types, error handling, async patterns, dependency injection, and module structure.
metadata:
  author: vsirotin
  version: "1.5"
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

## 1.4 Use a class AppError for all registration messages
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
  private readonly logger = LoggerFactory.getLogger('<project-name>/app/pages/my/MyComponent');
}
```

For modules containing free functions (not classes), declare a module-level logger. Use the file path relative to the project root, **including the file extension**:

```typescript
import { LoggerFactory } from '@vsirotin/log4ts';

const logger = LoggerFactory.getLogger('<project-name>/api/session/close/close-handler.ts');
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

### 1.10.4 What to log

Log all essential functions and methods in production code (not tests). "Essential" means functions with more than ~10 lines, or short but important functions (see `common-development` §2.1).

**Frontend**: log on entry to each function/method. That is sufficient.

**Backend**: log on entry **and** at each return point. Backend bugs are harder to reproduce in production, so every exit path must be traceable.

### 1.10.5 Log message format

Always pass the **function name as the first argument** so logs are greppable and self-describing:

```typescript
logger.log("extractCloseParams:",
  "sessionId=", sessionId,
  "sliceNumber=", sliceNumber,
  "clientId=", mask(clientId));
```

For return-point logs, state the outcome concisely:

```typescript
logger.log("extractCloseParams:", "Invalid parameters detected.");
return null;
```

```typescript
logger.log("extractCloseParams:", "Parameters extracted successfully.");
return { sessionId, sliceNumber, usedTokens, clientId };
```

### 1.10.6 Mask sensitive data

Never log raw sensitive data: user personal data, user IDs, API keys, e-tokens, or passwords. Use the `mask()` helper to obscure them:

```typescript
import { mask } from '<project-name>/utils/secure';

logger.log("createEToken:", "eTokenId=", mask(eTokenId));
```

`mask(key, visibleStart=2, visibleEnd=2)` keeps the first and last few characters and replaces the middle with `*`. It accepts strings only — convert/guard non-string values before calling it.

### 1.10.7 HTTP status-based log levels

When an operation returns an HTTP status code, log by status family:

| Status | Level | Notes |
|---|---|---|
| 4xx (client errors) | `warn` | Bad request, not found, conflict, rate-limited |
| 5xx (server errors) | `error` | Internal failures, infrastructure errors |
| 2xx (success) | `log` or `debug` | Routine |

If the project has a central `createErrorResult(...)` helper, it should already apply these levels — do not duplicate the `warn`/`error` call at every return site.

### 1.10.8 Complex functions: log each step

In functions with multiple sequential steps (e.g. request handlers, business logic), log each essential step using the pattern `"<function-name> Step N:"`:

```typescript
logger.log("createSessionLogic Step 2:", "Checking promocode existence.");
const promocode = await dbProvider.getPromocode(promocodeId);
if (!promocode) {
  logger.log("createSessionLogic Step 2:", "Promocode not found.");
  return createErrorResult('PROMOCODE_NOT_FOUND', `Promocode ${promocodeId} not found.`, 404);
}
logger.log("createSessionLogic Step 2:", "Promocode found.");
```

Log before external calls (DB, AI API) and after them, so latency and failures are visible.

### 1.10.9 Firebase Functions specifics

In Firebase Functions projects, require the compat shim once per file so `log4ts` output is forwarded to the Firebase logger:

```typescript
require("firebase-functions/logger/compat");
```

Place it immediately after the `LoggerFactory` import, before the `const logger = ...` line.
