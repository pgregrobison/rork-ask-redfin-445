# Remove extra top padding from Find list view

**What's happening:** The list view has a hardcoded 52pt top padding that was originally added to make room for the location/homes pill. Since the pill now floats as an overlay, this padding is unnecessary and creates a visible gap.

**Change:** Remove the 52pt top padding from the list view so content starts at the natural position below the navigation toolbar.