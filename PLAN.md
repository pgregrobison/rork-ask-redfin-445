# Restore smooth navigation bar transitions to detail page

**Problem**
The Find page completely hides the system navigation bar to make room for the custom location pill and glass action buttons. When you tap a listing and push to the detail page, the navigation bar can't smoothly slide in — it just appears, breaking the native iOS transition feel.

**Fix**
- On the Find page, instead of fully hiding the navigation bar, make it **transparent and invisible** — this keeps the navigation bar technically "present" so iOS can animate it smoothly during the push/pop transition
- The detail page's toolbar (back button, heart, share) will then slide in naturally as part of the standard navigation animation
- The custom glass toolbar and pill menu on the Find page will remain exactly where they are and look identical to how they do now