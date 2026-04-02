import SwiftUI

struct FilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: ListingsViewModel

    @State private var propertyType: String = "Any"

    private let propertyTypes = ["Any", "House", "Condo", "Townhouse", "Co-op", "Multi-family"]

    private let priceOptions: [(String, Int?)] = [
        ("No Min", nil),
        ("$200K", 200_000),
        ("$400K", 400_000),
        ("$600K", 600_000),
        ("$800K", 800_000),
        ("$1M", 1_000_000),
        ("$1.5M", 1_500_000),
        ("$2M", 2_000_000),
        ("$3M", 3_000_000),
        ("$5M", 5_000_000),
    ]

    private let maxPriceOptions: [(String, Int?)] = [
        ("No Max", nil),
        ("$500K", 500_000),
        ("$750K", 750_000),
        ("$1M", 1_000_000),
        ("$1.5M", 1_500_000),
        ("$2M", 2_000_000),
        ("$2.5M", 2_500_000),
        ("$3M", 3_000_000),
        ("$5M", 5_000_000),
        ("$10M", 10_000_000),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    priceSection
                    bedsSection
                    bathsSection
                    propertyTypeSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        viewModel.filterMinPrice = nil
                        viewModel.filterMaxPrice = nil
                        viewModel.filterMinBeds = 0
                        viewModel.filterMinBaths = 0
                        propertyType = "Any"
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Price")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                priceDropdown(
                    label: priceLabel(for: viewModel.filterMinPrice, fallback: "No Min"),
                    options: priceOptions,
                    selection: $viewModel.filterMinPrice
                )

                Text("–")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)

                priceDropdown(
                    label: priceLabel(for: viewModel.filterMaxPrice, fallback: "No Max"),
                    options: maxPriceOptions,
                    selection: $viewModel.filterMaxPrice
                )
            }
        }
    }

    private func priceDropdown(label: String, options: [(String, Int?)], selection: Binding<Int?>) -> some View {
        Menu {
            ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                Button {
                    selection.wrappedValue = option.1
                } label: {
                    HStack {
                        Text(option.0)
                        if selection.wrappedValue == option.1 {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(label)
                    .font(.subheadline.weight(.medium))
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 40)
            .background(Color(.tertiarySystemFill), in: Capsule())
        }
    }

    private func priceLabel(for value: Int?, fallback: String) -> String {
        guard let value else { return fallback }
        if value >= 1_000_000 {
            let m = Double(value) / 1_000_000.0
            if m == m.rounded() {
                return "$\(Int(m))M"
            }
            return "$\(String(format: "%.1f", m))M"
        }
        return "$\(value / 1000)K"
    }

    private var bedsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Beds")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            segmentedPills(
                options: [0, 1, 2, 3, 4, 5],
                selection: $viewModel.filterMinBeds,
                labelForValue: { $0 == 0 ? "Any" : "\($0)+" }
            )
        }
    }

    private var bathsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Baths")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            segmentedPills(
                options: [0, 1, 2, 3, 4],
                selection: $viewModel.filterMinBaths,
                labelForValue: { $0 == 0 ? "Any" : "\($0)+" }
            )
        }
    }

    private func segmentedPills(options: [Int], selection: Binding<Int>, labelForValue: @escaping (Int) -> String) -> some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { value in
                let isSelected = selection.wrappedValue == value
                Button {
                    selection.wrappedValue = value
                } label: {
                    Text(labelForValue(value))
                        .font(.subheadline.weight(isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? Color(.systemBackground) : .primary)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 40)
                        .background(
                            isSelected ? AnyShapeStyle(Color(.label)) : AnyShapeStyle(Color(.tertiarySystemFill)),
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var propertyTypeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Property Type")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], spacing: 8) {
                ForEach(propertyTypes, id: \.self) { type in
                    let isSelected = propertyType == type
                    Button {
                        propertyType = type
                    } label: {
                        Text(type)
                            .font(.subheadline.weight(isSelected ? .semibold : .regular))
                            .foregroundStyle(isSelected ? Color(.systemBackground) : .primary)
                            .padding(.horizontal, 14)
                            .frame(minHeight: 40)
                            .frame(maxWidth: .infinity)
                            .background(
                                isSelected ? AnyShapeStyle(Color.primary) : AnyShapeStyle(Color(.tertiarySystemFill)),
                                in: .rect(cornerRadius: 10)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
