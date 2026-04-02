import SwiftUI

struct MyHomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    let debugSettings: DebugSettings
    @State private var showDebugPanel: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                addHomeCard
                featureTiles

                Spacer().frame(height: 16)

                debugButton
            }
            .padding(.bottom, 100)
        }
        .background(Color(.systemBackground))
        .navigationTitle("My Home")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {} label: {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                }
            }
        }
    }

    private var addHomeCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "house")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("What's your home worth?")
                .font(.title3.bold())

            Text("Add your address to track your home's estimated value, compare with nearby sales, and see market trends.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: {}) {
                Text("Add address")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color(white: 0.15), in: .rect(cornerRadius: 10))
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal, 20)
    }

    private var featureTiles: some View {
        HStack(spacing: 12) {
            featureTile(
                icon: "chart.line.uptrend.xyaxis",
                title: "Value trends",
                description: "See how your home's value has changed"
            )
            featureTile(
                icon: "dollarsign.circle",
                title: "Estimate",
                description: "Get your Redfin Estimate"
            )
            featureTile(
                icon: "building.2",
                title: "Comps",
                description: "Compare with nearby sales"
            )
        }
        .padding(.horizontal, 20)
    }

    private func featureTile(icon: String, title: String, description: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption.bold())

            Text(description)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 130)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var debugButton: some View {
        Button { showDebugPanel = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "wrench.and.screwdriver")
                    .font(.subheadline.weight(.medium))
                Text("Debug Panel")
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDebugPanel) {
            DebugPanelView(settings: debugSettings)
                .presentationDetents([.medium])
        }
    }
}
