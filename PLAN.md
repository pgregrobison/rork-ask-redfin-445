# Persist map viewport when switching tabs

**Problem**
Switching away from the Find tab and back resets the map to its default position, because the map view is destroyed and recreated each time.

**Solution**
Keep all tab views alive in the background by rendering them all simultaneously and only showing the active one. This way the map is never destroyed and its viewport is preserved naturally.

**What changes**
- The tab content area will render all tabs at once but only show the currently selected one
- No visual or behavioral difference — the app looks and works exactly the same
- The map remembers its zoom level, center position, and any selected listing when you navigate away and come back