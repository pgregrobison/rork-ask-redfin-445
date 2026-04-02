# Fix toolbar fly-in during zoom transition on Find page

**Problem**
When using the zoom transition from the "Find" tab, the native navigation toolbar slides in from the right because "Find" completely hides the navigation bar. Pages like "For You" that already show the native toolbar don't have this issue.

**Fix**
On the "Find" page, instead of fully hiding the navigation bar, keep it technically visible but with a hidden background and no visible content. This way, during the zoom transition, the toolbar smoothly fades in place rather than flying in from the side.

- The Find page will use `.toolbarVisibility(.visible)` with `.toolbarBackgroundVisibility(.hidden)` instead of `.toolbar(.hidden)`
- The custom overlay toolbar (map/list toggle, sort, profile buttons) will continue to work exactly as before
- The native nav bar will be invisible but "present," so the zoom transition treats it as a crossfade rather than a push-in
- No visual change to the Find page itself — the custom toolbar overlay remains identical