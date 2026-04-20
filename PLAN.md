# Lower chat sheet to mid detent when home search starts in map focus mode

**Behavior change**

- When Realistic Mode is on and the search behavior is set to "Map focus," the chat sheet will automatically drop down to the mid detent (70%) the moment the bot transitions into the "Searching for homes…" state.
- This gives the user a clear view of the map's shimmer loader during the 8-second thinking window.
- The sheet stays at mid detent as results settle in (matching the existing post-results behavior).
- If the user isn't in map focus mode, or Realistic Mode is off, nothing changes.
- Manually dragging the sheet afterwards still works normally.