import SwiftUI

struct MyHomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    let debugSettings: DebugSettings
    @State private var showDebugPanel: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                addHomeCard
                featureTiles

                Spacer().frame(height: 16)

                debugButton
            }
            .padding(.bottom, 100)
        }
        .background(Theme.Colors.background)
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
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "house")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("What's your home worth?")
                .font(Theme.Typography.cardTitle)

            Text("Add your address to track your home's estimated value, compare with nearby sales, and see market trends.")
                .font(Theme.Typography.secondary)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: {}) {
                Text("Add address")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Theme.Spacing.xxl)
                    .padding(.vertical, 14)
                    .background(Color(white: 0.15), in: .rect(cornerRadius: 10))
            }
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(.rect(cornerRadius: Theme.Radius.large))
        .padding(.horizontal, Theme.Spacing.lg)
    }

    private var featureTiles: some View {
        HStack(spacing: Theme.Spacing.sm) {
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
        .padding(.horizontal, Theme.Spacing.lg)
    }

    private func featureTile(icon: String, title: String, description: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                .foregroundStyle(.primary)

            Text(title)
                .font(Theme.Typography.captionBold)

            Text(description)
                .font(Theme.Typography.micro)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(Theme.Spacing.sm)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 130)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(.rect(cornerRadius: Theme.Radius.medium))
    }

    private var debugButton: some View {
        Button { showDebugPanel = true } label: {
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "wrench.and.screwdriver")
                    .font(Theme.Typography.secondary.weight(.medium))
                Text("Debug Panel")
                    .font(Theme.Typography.secondary.weight(.medium))
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.sm)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDebugPanel) {
            DebugPanelView(settings: debugSettings)
                .presentationDetents([.medium])
        }
    }
}
