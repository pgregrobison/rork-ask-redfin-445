import SwiftUI
import MapKit

struct LocationMenuView: View {
    @Bindable var viewModel: ListingsViewModel
    @Bindable var searchService: LocationSearchService
    let onClose: () -> Void
    let onOpenFilter: () -> Void

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)

                TextField("Search location...", text: Binding(
                    get: { searchService.searchText },
                    set: { searchService.updateQuery($0) }
                ))
                .font(.body)
                .focused($isSearchFocused)
                .submitLabel(.search)

                if !searchService.searchText.isEmpty {
                    Button {
                        searchService.clear()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            if !searchService.suggestions.isEmpty {
                Divider().padding(.leading, 14)

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(searchService.suggestions, id: \.self) { suggestion in
                            Button {
                                selectSuggestion(suggestion)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.system(size: 20))
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
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxHeight: 240)
            }

            Divider().padding(.leading, 14)

            HStack(spacing: 0) {
                menuAction(icon: "slider.horizontal.3", label: "Filter") {
                    onOpenFilter()
                }

                menuAction(icon: "bookmark", label: "Save Search") {}

                Spacer()

                sortMenu
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
        }
        .onAppear {
            searchService.searchText = viewModel.locationName
            isSearchFocused = true
        }
    }

    private func menuAction(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(label)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    viewModel.sortOption = option
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if viewModel.sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 13, weight: .semibold))
                Text("Sort")
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Capsule())
        }
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
