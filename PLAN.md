# Fix tab bar delay after dismissing map card

**Problem:** When you dismiss the map home card, the tab bar waits too long to slide back in because it's tied to a delayed property (`selectedListing` becoming nil) instead of the immediate card visibility state.

**Fix:** Change the tab bar visibility trigger in ContentView from watching `selectedListing` to watching `isCardVisible`, so the tab bar starts sliding back in at the same time the card starts sliding out.

This is a one-line change — swap `viewModel.selectedListing?.id` for `viewModel.isCardVisible` in the `.onChange` that controls `showTabBar`.