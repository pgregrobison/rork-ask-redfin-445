import SwiftUI

struct MyRedfinView: View {
    let isActive: Bool
    let onProfileTap: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                profileCard
                rowGroup
                Spacer().frame(height: Theme.Spacing.md)
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.top, Theme.Spacing.md)
            .padding(.bottom, Theme.Spacing.tabBarClearance)
        }
        .background(Theme.Colors.background)
        .navigationTitle(isActive ? "My Redfin" : "")
        .navigationBarTitleDisplayMode(isActive ? .large : .inline)
        .toolbar {
            if isActive {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { onProfileTap() } label: {
                        Image(systemName: "gear")
                            .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    }
                }
            }
        }
    }

    private var profileCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.secondary)

            Text("Sign in to Redfin")
                .font(Theme.Typography.cardTitle)

            Text("Save searches, get instant alerts, and chat with Ask Redfin from any device.")
                .font(Theme.Typography.secondary)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: {}) {
                Text("Sign in")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Theme.Spacing.xxl)
                    .padding(.vertical, Theme.ButtonSize.verticalPadding)
                    .background(Theme.Colors.stepIndicator, in: Capsule())
            }
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(.rect(cornerRadius: Theme.Radius.large))
    }

    private var rowGroup: some View {
        VStack(spacing: 0) {
            row(icon: "bell", label: "Notifications")
            Divider().padding(.leading, 52)
            row(icon: "envelope", label: "Email preferences")
            Divider().padding(.leading, 52)
            row(icon: "lock", label: "Privacy")
            Divider().padding(.leading, 52)
            row(icon: "questionmark.circle", label: "Help & support")
        }
        .background(Theme.Colors.secondaryBackground)
        .clipShape(.rect(cornerRadius: Theme.Radius.large))
    }

    private func row(icon: String, label: String) -> some View {
        Button(action: {}) {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 28)
                Text(label)
                    .font(Theme.Typography.body)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
