# Only animate map home card when going from no selection to a selection

**Problem**
When tapping a new pin while a card is already showing, the card slides out and back in (the full enter/exit animation replays). It should only slide up when going from no pin selected → pin selected.

**Fix**
- Remove the `.id(listing.id)` on the card overlay — this is what causes SwiftUI to treat each pin switch as a brand-new view, triggering the slide-in/slide-out transition every time
- Without the forced identity swap, SwiftUI will keep the same card view and just update its content in place when switching between pins
- The slide-up transition will still fire when going from nothing selected → a pin selected, and the slide-down will fire when dismissing