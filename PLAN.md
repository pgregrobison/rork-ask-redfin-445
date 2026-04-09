# Prevent chat scrolling in smaller sheet detent

**What changes:**

- In the smaller (70%) sheet position, swiping up on the chat will pull the sheet up to full height instead of scrolling the messages
- Once the sheet reaches full height, scrolling works normally as it does today
- If the user drags the sheet back down to the smaller position, scrolling is disabled again

**How it works:**

- The sheet dynamically switches between "resize first" and "scroll first" behavior based on the current detent position
- At the 70% detent → swipe gestures resize the sheet
- At the full-height detent → swipe gestures scroll the chat content

