# Rebuild Mortgage Prequalification as a Stepped Flow

Rebuild the existing mortgage prequalification widget to match the tour scheduler's stepped pattern, and wire it into the chat trigger system.

**Trigger**
- Typing anything containing "mortgage", "prequalified", "prequalify", "pre-qualified", "afford", "loan", or "financing" in Ask Redfin will launch the mortgage flow inline

**Steps (matching tour scheduler pattern)**
1. **Annual household income** — currency text field with dollar sign prefix
2. **Down payment** — currency text field with dollar sign prefix
3. **Loan details** — loan type picker (segmented: 30-yr fixed, 15-yr fixed, ARM 5/1, ARM 7/1) + credit score picker (menu dropdown)

Each step has:
- Numbered circle indicator (filled current, checked completed, outlined future)
- Tappable completed steps to go back and edit
- Summary text shown for completed steps
- Dividers between steps
- Capsule-shaped "Continue" / "Get Prequalified" buttons using the same dark/light adaptive style as tour scheduler

**Confirmation**
- Green checkmark with "Prequalification Complete!" header
- Summary of all entered values (income, down payment, loan type, credit score)
- Estimated budget calculation (income × 4 + down payment) highlighted in green
- "A Redfin loan officer will reach out to finalize your prequalification." note

**Design**
- Same card background, corner radius, header layout, and spacing as the tour scheduler
- Header icon: banknote symbol with "Mortgage Prequalification" title and "See what you can afford" subtitle
- Haptic feedback on step advance and submission
- Smooth spring animations between steps
