import SwiftUI

struct DebugPanelView: View {
    @Bindable var settings: DebugSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(CardTransitionStyle.allCases, id: \.self) { style in
                        Button {
                            settings.cardTransition = style
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(style.rawValue)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    Text(style.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if settings.cardTransition == style {
                                    Image(systemName: "checkmark")
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.primary)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Card Transition")
                } footer: {
                    Text("Controls how tapping a listing card navigates to the detail page.")
                }

                Section {
                    ForEach(DetailPageStyle.allCases, id: \.self) { style in
                        Button {
                            settings.detailPageStyle = style
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(style.rawValue)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    Text(style.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if settings.detailPageStyle == style {
                                    Image(systemName: "checkmark")
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.primary)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("DP Style")
                } footer: {
                    Text("Controls the layout and design of the listing detail page.")
                }

                Section {
                    ForEach(SearchBehavior.allCases, id: \.self) { behavior in
                        Button {
                            settings.searchBehavior = behavior
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(behavior.rawValue)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    Text(behavior.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if settings.searchBehavior == behavior {
                                    Image(systemName: "checkmark")
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.primary)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Search Behavior")
                } footer: {
                    Text("Controls how chat interacts with the map when searching for homes.")
                }
            }
            .navigationTitle("Debug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

extension CardTransitionStyle {
    var subtitle: String {
        switch self {
        case .nativePush: "Standard navigation push"
        case .zoom: "Card zooms into detail view"
        }
    }
}

extension DetailPageStyle {
    var subtitle: String {
        switch self {
        case .current: "Bottom sheet over photos"
        case .james: "Full vertical scroll layout"
        }
    }
}

extension SearchBehavior {
    var subtitle: String {
        switch self {
        case .default: "Full sheet chat, manual show on map"
        case .mapFocus: "Chat drops to half-sheet on search, pins auto-fit"
        }
    }
}
