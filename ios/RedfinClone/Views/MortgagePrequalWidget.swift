import SwiftUI

struct MortgagePrequalWidget: View {
    let mortgageRequest: MortgageRequest

    @State private var currentStep: Int = 0
    @State private var annualIncome: String = ""
    @State private var downPayment: String = ""
    @State private var loanType: String = "30-year fixed"
    @State private var creditScore: String = "740+"
    @State private var isSubmitted: Bool = false

    nonisolated private enum Field { case income, downPayment }
    @FocusState private var focusedField: Field?
    @Environment(\.chatWidgetMessageID) private var messageID

    private let loanTypes = ["30-year fixed", "15-year fixed", "ARM 5/1", "ARM 7/1"]
    private let creditRanges = ["740+", "700-739", "660-699", "620-659", "Below 620"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView

            if isSubmitted {
                confirmationView
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                stepsView
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal, 16)
        .animation(.snappy(duration: 0.35), value: currentStep)
        .animation(.snappy(duration: 0.35), value: isSubmitted)
        .onChange(of: focusedField) { _, newField in
            guard newField != nil, let messageID else { return }
            NotificationCenter.default.post(name: .chatWidgetFieldFocused, object: nil, userInfo: ["messageID": messageID])
        }
    }

    private var headerView: some View {
        HStack(spacing: 10) {
            Image(systemName: "banknote")
                .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Mortgage Prequalification")
                    .font(.headline)
                Text("See what you can afford")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
    }

    private var stepsView: some View {
        VStack(spacing: 12) {
            stepRow(
                index: 0,
                title: "Annual household income",
                summary: "$\(annualIncome)",
                content: { incomeContent }
            )

            Divider().padding(.leading, 48)

            stepRow(
                index: 1,
                title: "Down payment",
                summary: "$\(downPayment)",
                content: { downPaymentContent }
            )

            Divider().padding(.leading, 48)

            stepRow(
                index: 2,
                title: "Loan details",
                summary: "\(loanType) · \(creditScore)",
                content: { loanDetailsContent }
            )
        }
    }

    private func stepRow<Content: View>(
        index: Int,
        title: String,
        summary: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                if index < currentStep {
                    currentStep = index
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            } label: {
                HStack(spacing: 12) {
                    stepIndicator(for: index)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline.weight(currentStep == index ? .semibold : .regular))
                            .foregroundStyle(index <= currentStep ? .primary : .tertiary)

                        if index < currentStep {
                            Text(summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    if index < currentStep {
                        Image(systemName: "chevron.down")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(index > currentStep)

            if currentStep == index {
                content()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func stepIndicator(for index: Int) -> some View {
        ZStack {
            if index < currentStep {
                Circle()
                    .fill(Theme.redfinGreenColor)
                    .frame(width: 24, height: 24)
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
            } else if index == currentStep {
                Circle()
                    .fill(Color.primary)
                    .frame(width: 24, height: 24)
                Text("\(index + 1)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(.systemBackground))
            } else {
                Circle()
                    .strokeBorder(Color(.tertiaryLabel), lineWidth: 1.5)
                    .frame(width: 24, height: 24)
                Text("\(index + 1)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var incomeContent: some View {
        VStack(spacing: 12) {
            HStack {
                Text("$")
                    .foregroundStyle(.secondary)
                TextField("e.g. 250,000", text: $annualIncome)
                    .keyboardType(.numberPad)
                    .font(.subheadline)
                    .focused($focusedField, equals: .income)
            }
            .frame(minHeight: 44)
            .padding(.horizontal, 12)
            .background(Color(.tertiarySystemBackground))
            .clipShape(.rect(cornerRadius: 10))

            continueButton(enabled: !annualIncome.trimmingCharacters(in: .whitespaces).isEmpty) {
                advanceStep()
            }
        }
    }

    private var downPaymentContent: some View {
        VStack(spacing: 12) {
            HStack {
                Text("$")
                    .foregroundStyle(.secondary)
                TextField("e.g. 100,000", text: $downPayment)
                    .keyboardType(.numberPad)
                    .font(.subheadline)
                    .focused($focusedField, equals: .downPayment)
            }
            .frame(minHeight: 44)
            .padding(.horizontal, 12)
            .background(Color(.tertiarySystemBackground))
            .clipShape(.rect(cornerRadius: 10))

            continueButton(enabled: !downPayment.trimmingCharacters(in: .whitespaces).isEmpty) {
                advanceStep()
            }
        }
    }

    private var loanDetailsContent: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Loan type")
                    .font(.subheadline.bold())

                Picker("Loan type", selection: $loanType) {
                    ForEach(loanTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Credit score")
                    .font(.subheadline.bold())

                Picker("Credit score", selection: $creditScore) {
                    ForEach(creditRanges, id: \.self) { range in
                        Text(range).tag(range)
                    }
                }
                .pickerStyle(.menu)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.tertiarySystemBackground))
                .clipShape(.rect(cornerRadius: 10))
            }

            Button {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                isSubmitted = true
            } label: {
                Text("Get Prequalified")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color(.systemBackground))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(canSubmit ? Color.primary : Color.gray, in: Capsule())
            }
            .disabled(!canSubmit)
        }
    }

    private var confirmationView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(Theme.redfinGreenColor)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Prequalification Complete!")
                        .font(.subheadline.bold())
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                summaryRow(label: "Income", value: "$\(annualIncome)")
                summaryRow(label: "Down payment", value: "$\(downPayment)")
                summaryRow(label: "Loan type", value: loanType)
                summaryRow(label: "Credit score", value: creditScore)

                let estimated = estimatedBudget
                if estimated > 0 {
                    Divider().padding(.vertical, 4)
                    HStack {
                        Text("Estimated budget")
                            .font(.subheadline.bold())
                        Spacer()
                        Text(formatCurrency(estimated))
                            .font(.subheadline.bold())
                            .foregroundStyle(Theme.redfinGreenColor)
                    }
                }
            }

            Text("A Redfin loan officer will reach out to finalize your prequalification.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption.bold())
        }
    }

    private func continueButton(enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("Continue")
                .font(.subheadline.bold())
                .foregroundStyle(Color(.systemBackground))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(enabled ? Color.primary : Color.gray, in: Capsule())
        }
        .disabled(!enabled)
    }

    private func advanceStep() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        currentStep += 1
    }

    private var estimatedBudget: Int {
        guard let income = Int(annualIncome.replacingOccurrences(of: ",", with: "")),
              let down = Int(downPayment.replacingOccurrences(of: ",", with: "")) else { return 0 }
        return income * 4 + down
    }

    private func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }

    private var canSubmit: Bool {
        !annualIncome.trimmingCharacters(in: .whitespaces).isEmpty &&
        !downPayment.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
