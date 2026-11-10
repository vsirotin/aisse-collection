---
name: security-audit/web-client
description: Security audit of a web client (single-page application) with a checklist. Use for a planned full audit of a client project, not for the review of a single change.
metadata:
  author: vsirotin
  version: "1.0"
---

# Security audit of a web client

Follow [the method](../method.md). A web client runs on the computer of the attacker: everything in it can be read and
changed. So the client protects its user, and it never protects the server.

## Checklist

Based on the OWASP Top 10.

### Injection into the page

- [ ] No user or server text reaches the page as HTML without sanitizing: search for `innerHTML`, `outerHTML`,
      `insertAdjacentHTML`, `document.write`, `eval`, `new Function`, and for bypasses of the framework sanitizer (in
      Angular `bypassSecurityTrust*`).
- [ ] Text from an AI model counts as untrusted input, and so does text from any other user.
- [ ] URLs from data are checked before they are used in `href`, `src` or a redirect (no `javascript:`, no open
      redirect).
- [ ] Values of the page URL are treated as untrusted input.

### Data in the browser

- [ ] `localStorage`, `sessionStorage`, IndexedDB and cookies hold only what is needed. List each key with its
      content.
- [ ] Tokens live as short as possible, and they are removed on logout and at their end.
- [ ] Cookies with a meaning for security have `Secure`, `HttpOnly` and `SameSite`.
- [ ] Logs in the browser console contain no tokens or personal data in a production build.

### Secrets and the bundle

- [ ] The production bundle contains no secret. Search the built files, not only the sources. Public identifiers, such
      as the configuration of a client SDK, are named as public.
- [ ] Source maps are not published, or their publication is a decision.
- [ ] Debug switches and test URLs have no effect in a production build, or their effect is harmless.

### Trust in the client

- [ ] Each check of permission, price or limit that the client makes is repeated on the server.
- [ ] Hidden or disabled controls are not the only protection of a function.

### Third parties

- [ ] All scripts, styles and fonts from other hosts are listed, with the reason. Each one can read the page.
- [ ] Production dependencies have no high or critical advisories.
- [ ] Permissions of the browser (microphone, camera, location) are requested only when needed.

### Delivery

- [ ] HTTPS only, with HSTS.
- [ ] Response headers checked on the deployed page: `Content-Security-Policy`, `X-Content-Type-Options`,
      `Referrer-Policy`, `Permissions-Policy`, and protection against framing.
- [ ] Caching cannot deliver a page or data of another user.
