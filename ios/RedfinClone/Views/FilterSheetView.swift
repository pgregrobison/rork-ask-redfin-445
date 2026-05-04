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

    private let controlHeight: CGFloat = 44
    private let tileHeight: CGFloat = 48
    private let controlRadius: CGFloat = 12

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    statusSegmentedControl
                    priceSection
                    bedsSection
                    bathsSection
                    propertyTypeSection
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xl)
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

    // MARK: - Status

    private var statusSegmentedControl: some View {
        Picker("Listing status", selection: $viewModel.listingStatus) {
            ForEach(ListingStatus.allCases) { status in
                Text(status.rawValue).tag(status)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }

    // MARK: - Price

    private var priceSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            sectionLabel("Price")

            HStack(spacing: Theme.Spacing.xs) {
                priceDropdown(
                    label: priceLabel(for: viewModel.filterMinPrice, fallback: "Enter min"),
                    isPlaceholder: viewModel.filterMinPrice == nil,
                    options: priceOptions,
                    selection: $viewModel.filterMinPrice
                )

                Text("–")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)

                priceDropdown(
                    label: priceLabel(for: viewModel.filterMaxPrice, fallback: "Enter max"),
                    isPlaceholder: viewModel.filterMaxPrice == nil,
                    options: maxPriceOptions,
                    selection: $viewModel.filterMaxPrice
                )
            }
        }
    }

    private func priceDropdown(label: String, isPlaceholder: Bool, options: [(String, Int?)], selection: Binding<Int?>) -> some View {
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
            HStack {
                Text(label)
                    .font(Theme.Typography.body)
                    .foregroundStyle(isPlaceholder ? Color.secondary : Color.primary)
                Spacer(minLength: Theme.Spacing.xs)
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, Theme.Spacing.sm)
            .frame(maxWidth: .infinity)
            .frame(height: controlHeight)
            .background(Theme.Colors.fill, in: .rect(cornerRadius: controlRadius))
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

    // MARK: - Beds & Baths

    private var bedsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            sectionLabel("Beds")
            optionTiles(
                options: [0, 1, 2, 3, 4, 5],
                selection: $viewModel.filterMinBeds,
                labelForValue: { $0 == 0 ? "Any" : "\($0)+" }
            )
        }
    }

    private var bathsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            sectionLabel("Baths")
            optionTiles(
                options: [0, 1, 2, 3, 4],
                selection: $viewModel.filterMinBaths,
                labelForValue: { $0 == 0 ? "Any" : "\($0)+" }
            )
        }
    }

    private func optionTiles(options: [Int], selection: Binding<Int>, labelForValue: @escaping (Int) -> String) -> some View {
        HStack(spacing: Theme.Spacing.xs) {
            ForEach(options, id: \.self) { value in
                let isSelected = selection.wrappedValue == value
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                        selection.wrappedValue = value
                    }
                } label: {
                    Text(labelForValue(value))
                        .font(.subheadline.weight(isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? Color(.systemBackground) : .primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: tileHeight)
                        .background(
                            isSelected ? AnyShapeStyle(Color(.label)) : AnyShapeStyle(Theme.Colors.fill),
                            in: .rect(cornerRadius: controlRadius)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Property type

    private var propertyTypeSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            sectionLabel("Home type")

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 100), spacing: Theme.Spacing.xs)],
                spacing: Theme.Spacing.xs
            ) {
                ForEach(propertyTypes, id: \.self) { type in
                    let isSelected = propertyType == type
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                            propertyType = type
                        }
                    } label: {
                        Text(type)
                            .font(.subheadline.weight(isSelected ? .semibold : .regular))
                            .foregroundStyle(isSelected ? Color(.systemBackground) : .primary)
                            .padding(.horizontal, Theme.Spacing.sm)
                            .frame(maxWidth: .infinity)
                            .frame(height: tileHeight)
                            .background(
                                isSelected ? AnyShapeStyle(Color(.label)) : AnyShapeStyle(Theme.Colors.fill),
                                in: .rect(cornerRadius: controlRadius)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.primary)
    }
}
