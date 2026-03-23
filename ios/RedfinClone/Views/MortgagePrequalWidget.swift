import SwiftUI

struct MortgagePrequalWidget: View {
    let mortgageRequest: MortgageRequest
    @State private var step: Int = 0
    @State private var annualIncome: String = ""
    @State private var downPayment: String = ""
    @State private var loanType: String = "30-year fixed"
    @State private var creditScore: String = "740+"
    @State private var isSubmitted: Bool = false

    private let loanTypes = ["30-year fixed", "15-year fixed", "ARM 5/1", "ARM 7/1"]
    private let creditRanges = ["740+", "700-739", "660-699", "620-659", "Below 620"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView

            if isSubmitted {
                confirmationView
            } else {
                formContent
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal, 16)
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
        }
        .padding(16)
    }

    private var formContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            incomeSection

            if step >= 1 {
                downPaymentSection
            }

            if step >= 2 {
                loanDetailsSection
            }
        }
        .padding(16)
    }

    private var incomeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Annual household income")
                .font(.subheadline.bold())

            HStack {
                Text("$")
                    .foregroundStyle(.secondary)
                TextField("e.g. 250,000", text: $annualIncome)
                    .keyboardType(.numberPad)
                    .font(.subheadline)
            }
            .padding(12)
            .background(Color(.tertiarySystemBackground))
            .clipShape(.rect(cornerRadius: 10))

            if !annualIncome.isEmpty && step < 1 {
                Button {
                    withAnimation(.snappy(duration: 0.2)) { step = 1 }
                } label: {
                    Text("Continue")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    private var downPaymentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Down payment")
                .font(.subheadline.bold())

            HStack {
                Text("$")
                    .foregroundStyle(.secondary)
                TextField("e.g. 100,000", text: $downPayment)
                    .keyboardType(.numberPad)
                    .font(.subheadline)
            }
            .padding(12)
            .background(Color(.tertiarySystemBackground))
            .clipShape(.rect(cornerRadius: 10))

            if !downPayment.isEmpty && step < 2 {
                Button {
                    withAnimation(.snappy(duration: 0.2)) { step = 2 }
                } label: {
                    Text("Continue")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                }
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var loanDetailsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
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
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isSubmitted = true
                }
            } label: {
                Text("Get Prequalified")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(canSubmit ? Color(white: 0.15) : Color.gray, in: .rect(cornerRadius: 10))
            }
            .disabled(!canSubmit)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var confirmationView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    .foregroundStyle(Theme.redfinGreenColor)
                Text("Prequalification Complete!")
                    .font(.headline)
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
        .padding(16)
        .transition(.scale.combined(with: .opacity))
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
