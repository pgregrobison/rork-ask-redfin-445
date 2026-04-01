# Match filter sheet styles to the upper menu

**Changes**

- **Price filter**: Replace the current slider with the same min/max dropdown style used in the upper menu (two capsule buttons with "No Min" / "No Max" defaults and the same price options)
- **Beds filter**: Replace the segmented picker with the same pill selector style from the upper menu (capsule pills: Any, 1+, 2+, 3+, 4+, 5+)
- **Baths filter**: Replace the segmented picker with the same pill selector style from the upper menu (capsule pills: Any, 1+, 2+, 3+, 4+)
- **Order**: Reorder to match the upper menu — Price → Beds → Baths → Property Type
- **Data binding**: Connect the filter sheet to the shared filter state so changes apply to listings (currently it uses local state that doesn't persist)
- **Visual consistency**: Same 40pt minimum height, 4pt spacing between pills, accent color selected state with inverted text color matching the upper menu
