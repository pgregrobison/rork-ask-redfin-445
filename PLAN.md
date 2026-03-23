# Fix AI Chat by using Config for environment variables

**Problem**
The AI chat always fails with "Toolkit URL not configured" because the chat service reads environment variables from the wrong place. The build system injects values through a `Config` file, but the chat service never looks there.

**Fix**
- Update the chat service to read the toolkit URL, project ID, team ID, and app key from the `Config` file instead of the system environment
- This is a one-line-per-variable fix — no UI changes, no restructuring

**Result**
The AI chat will connect to the backend and respond to messages as expected.