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
        case .fluidGrow: "Card grows into detail view"
        }
    }
}
