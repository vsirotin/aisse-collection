---
name: security-audit/node-server
description: Security audit of a Node.js API server with a checklist. Use for a planned full audit of a server project, not for the review of a single change.
metadata:
  author: vsirotin
  version: "1.0"
---

# Security audit of a Node API server

Follow [the method](../method.md). Each request can come from anyone, with any content, in any order, and any number
of times. The client is not a protection.

## Checklist

Based on the OWASP API Security Top 10.

### Authentication and authorization

- [ ] A table of all endpoints: who may call each one, and how the server knows it.
- [ ] Each endpoint that touches an object checks that the caller may use this object. An ID in a request proves
      nothing.
- [ ] Fields of a request cannot set values that the caller must not set, such as a role, a price or a balance.
- [ ] Tokens have an end of life, and they are checked for it. IDs that act as a key are not guessable: they come from
      a cryptographic generator, never from `Math.random()`.

### Input

- [ ] Each input is checked for type, length and allowed values before it is used.
- [ ] No input reaches a query, a shell command, a file path or a URL of an outgoing request unchecked. Search for
      `exec`, `spawn`, `eval`, and for paths and URLs built from input.
- [ ] Objects built from input cannot change prototypes (`__proto__`, `constructor`).
- [ ] Size of the request body and of uploads is limited.

### Money and limited resources

- [ ] Each change of a balance is atomic, and it cannot run twice for the same event. Replay and parallel requests are
      considered.
- [ ] Amounts are computed on the server. Notifications of a payment provider are verified with the provider.
- [ ] A refund leaves nothing usable behind: a token or a connection that a caller already holds is revoked, or it
      stays paid for until it ends.
- [ ] Each call that costs money or quota has a limit per caller.

### Rate and availability

- [ ] Endpoints that an attacker can call in a loop have a rate limit, or a limit at the platform, with a maximum of
      instances.
- [ ] Expensive operations have a timeout. Loops over input have an upper limit.

### Input to AI models

- [ ] Text from a user that reaches a model is treated as untrusted. It cannot change the rights of the caller.
- [ ] System instructions and tools of the model do not depend on values that the caller controls, beyond what is
      meant.
- [ ] Output of a model counts as untrusted input of the next step.

### Secrets

- [ ] Secrets come from a secret store or the environment, and they are not in the repository or in its history.
- [ ] Logs and error answers contain no secrets, tokens or personal data.
- [ ] Each service account has only the rights it needs. Each stage has its own secrets.

### Errors and logs

- [ ] Error answers show no stack traces or internals.
- [ ] Actions that matter (payments, changes of rights) are logged, so that they can be traced.

### Configuration and dependencies

- [ ] CORS allows only what is meant. An open CORS setting is a decision with a reason.
- [ ] Direct access to the database from outside is closed by its rules. Check the deployed rules, not only the
      repository.
- [ ] Test modes and mock providers cannot be switched on in production.
- [ ] Production dependencies have no high or critical advisories.
- [ ] The runtime is a supported major version.
