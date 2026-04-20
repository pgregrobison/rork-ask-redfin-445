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

                Section {
                    Toggle("Realistic Mode", isOn: $settings.realisticModeEnabled)

                    if settings.realisticModeEnabled {
                        ForEach(RealisticSyncMode.allCases, id: \.self) { mode in
                            Button {
                                settings.realisticSyncMode = mode
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(mode.rawValue)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                        Text(mode.subtitle)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if settings.realisticSyncMode == mode {
                                        Image(systemName: "checkmark")
                                            .font(.body.weight(.semibold))
                                            .foregroundStyle(.primary)
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Realistic Mode")
                } footer: {
                    Text("Stretches home-search thinking to 8 seconds and lets you test how chat syncs with the Find surface.")
                }

                Section {
                    Toggle("Use Spring", isOn: $settings.panUseSpring)

                    if settings.panUseSpring {
                        AnimationSliderRow(label: "Response", value: $settings.panSpringResponse, range: 0.1...2.0)
                        AnimationSliderRow(label: "Damping", value: $settings.panSpringDamping, range: 0.1...1.0)
                    } else {
                        AnimationSliderRow(label: "Duration", value: $settings.panDuration, range: 0.1...2.0)
                    }
                } header: {
                    Text("Camera Pan")
                } footer: {
                    Text("Animation when the map pans to a selected pin.")
                }

                Section {
                    AnimationSliderRow(label: "Response", value: $settings.overlaySpringResponse, range: 0.1...2.0)
                    AnimationSliderRow(label: "Damping", value: $settings.overlaySpringDamping, range: 0.1...1.0)
                } header: {
                    Text("Card Overlay Entrance")
                } footer: {
                    Text("Spring animation when the listing card slides up.")
                }

                Section {
                    AnimationSliderRow(label: "Response", value: $settings.dismissSpringResponse, range: 0.1...2.0)
                    AnimationSliderRow(label: "Damping", value: $settings.dismissSpringDamping, range: 0.1...1.0)
                } header: {
                    Text("Card Overlay Dismiss")
                } footer: {
                    Text("Spring animation when the listing card slides away.")
                }

                Section {
                    Button("Reset Animation Defaults") {
                        settings.resetAnimationDefaults()
                    }
                    .foregroundStyle(.red)
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

private struct AnimationSliderRow: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(.body)
                Spacer()
                Text(String(format: "%.2f", value))
                    .font(.body.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range, step: 0.01)
        }
        .padding(.vertical, 2)
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

extension RealisticSyncMode {
    var subtitle: String {
        switch self {
        case .bidirectional: "Chat updates the map and list live as results arrive"
        case .oneWay: "Chat only updates Find when you tap Show on map"
        }
    }
}
