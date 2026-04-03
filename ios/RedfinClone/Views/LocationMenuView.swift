import SwiftUI
import MapKit

struct LocationMenuView: View {
    @Bindable var viewModel: ListingsViewModel
    @Bindable var searchService: LocationSearchService
    let onClose: () -> Void
    let onOpenFilter: () -> Void

    @FocusState private var isSearchFocused: Bool

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
        VStack(spacing: 0) {
            searchField

            if !searchService.suggestions.isEmpty {
                Divider().padding(.leading, Theme.Spacing.sm + 2)
                suggestionslist
            }

            Divider().padding(.leading, Theme.Spacing.sm + 2)
            priceFilterRow
            bedsFilterRow
            bathsFilterRow
            Divider().padding(.leading, Theme.Spacing.sm + 2)
            actionButtons
        }
        .onAppear {
            searchService.searchText = viewModel.locationName
        }
    }

    private var searchField: some View {
        HStack(spacing: Theme.Spacing.xs + 2) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: Theme.IconSize.small, weight: .medium))
                .foregroundStyle(.secondary)

            TextField("Search location...", text: Binding(
                get: { searchService.searchText },
                set: { searchService.updateQuery($0) }
            ))
            .font(Theme.Typography.body)
            .focused($isSearchFocused)
            .submitLabel(.search)

            if !searchService.searchText.isEmpty {
                Button {
                    searchService.clear()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: Theme.ButtonSize.iconSize))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.sm + 2)
        .padding(.vertical, Theme.Spacing.sm)
    }

    private var suggestionslist: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(searchService.suggestions, id: \.self) { suggestion in
                    Button {
                        selectSuggestion(suggestion)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: Theme.Spacing.lg))
                                .foregroundStyle(.red.opacity(0.8))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(suggestion.title)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                if !suggestion.subtitle.isEmpty {
                                    Text(suggestion.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }

                            Spacer()
                        }
                        .padding(.horizontal, Theme.Spacing.sm + 2)
                        .padding(.vertical, Theme.Spacing.xs + 2)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxHeight: 240)
    }

    private var priceFilterRow: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs + 2) {
            Text("Price")
                .font(Theme.Typography.captionBold)
                .foregroundStyle(.secondary)

            HStack(spacing: Theme.Spacing.xs) {
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
        .padding(.horizontal, Theme.Spacing.sm + 2)
        .padding(.vertical, Theme.Spacing.xs + 2)
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
                    .font(.system(size: Theme.Spacing.xs + 1, weight: .bold))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, Theme.Spacing.sm)
            .frame(maxWidth: .infinity)
            .frame(minHeight: Theme.ButtonSize.minHeight - 4)
            .background(Theme.Colors.fill, in: Capsule())
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

    private var bedsFilterRow: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs + 2) {
            Text("Beds")
                .font(Theme.Typography.captionBold)
                .foregroundStyle(.secondary)

            segmentedPills(
                options: [0, 1, 2, 3, 4, 5],
                selection: $viewModel.filterMinBeds,
                labelForValue: { $0 == 0 ? "Any" : "\($0)+" }
            )
        }
        .padding(.horizontal, Theme.Spacing.sm + 2)
        .padding(.vertical, Theme.Spacing.xs + 2)
    }

    private var bathsFilterRow: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs + 2) {
            Text("Baths")
                .font(Theme.Typography.captionBold)
                .foregroundStyle(.secondary)

            segmentedPills(
                options: [0, 1, 2, 3, 4],
                selection: $viewModel.filterMinBaths,
                labelForValue: { $0 == 0 ? "Any" : "\($0)+" }
            )
        }
        .padding(.horizontal, Theme.Spacing.sm + 2)
        .padding(.vertical, Theme.Spacing.xs + 2)
    }

    private func segmentedPills(options: [Int], selection: Binding<Int>, labelForValue: @escaping (Int) -> String) -> some View {
        HStack(spacing: Theme.Spacing.xxs) {
            ForEach(options, id: \.self) { value in
                let isSelected = selection.wrappedValue == value
                Button {
                    selection.wrappedValue = value
                } label: {
                    Text(labelForValue(value))
                        .font(.subheadline.weight(isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? Theme.Colors.invertedPrimary : .primary)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: Theme.ButtonSize.minHeight - 4)
                        .background(
                            isSelected ? AnyShapeStyle(Color(.label)) : AnyShapeStyle(Theme.Colors.fill),
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Button {
                onOpenFilter()
            } label: {
                HStack(spacing: Theme.Spacing.xxs + 2) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: Theme.IconSize.mapPin, weight: .semibold))
                    Text("Filter")
                        .font(.subheadline.weight(.medium))
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: Theme.ButtonSize.minHeight - 4)
                .background(Theme.Colors.fill, in: .rect(cornerRadius: Theme.Radius.pill))
            }
            .buttonStyle(.plain)

            Button {} label: {
                HStack(spacing: Theme.Spacing.xxs + 2) {
                    Image(systemName: "bookmark")
                        .font(.system(size: Theme.IconSize.mapPin, weight: .semibold))
                    Text("Save Search")
                        .font(.subheadline.weight(.medium))
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: Theme.ButtonSize.minHeight - 4)
                .background(Theme.Colors.fill, in: .rect(cornerRadius: Theme.Radius.pill))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Theme.Spacing.xs + 2)
        .padding(.vertical, Theme.Spacing.xs + 2)
    }

    private func selectSuggestion(_ suggestion: MKLocalSearchCompletion) {
        isSearchFocused = false
        Task {
            if let region = await searchService.search(for: suggestion) {
                viewModel.locationName = suggestion.title
                withAnimation(.easeInOut(duration: 0.5)) {
                    viewModel.mapPosition = .region(region)
                }
                searchService.clear()
                searchService.searchText = suggestion.title
                onClose()
            }
        }
    }
}
