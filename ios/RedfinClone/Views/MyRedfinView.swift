import SwiftUI

struct MyRedfinView: View {
    let isActive: Bool
    let onProfileTap: () -> Void
    var ownsNavStack: Bool = false

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
        .navigationTitle(ownsNavStack || isActive ? "My Redfin" : "")
        .navigationBarTitleDisplayMode(ownsNavStack || isActive ? .large : .inline)
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
            avatar

            VStack(spacing: 4) {
                Text("Alex Morgan")
                    .font(Theme.Typography.cardTitle)

                Text("alex.morgan@example.com")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
            }

            Button(action: {}) {
                Text("Edit profile")
                    .padding(.horizontal, Theme.Spacing.lg)
            }
            .buttonStyle(.smallPillOutline)
            .padding(.top, 4)
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(.rect(cornerRadius: Theme.Radius.large))
    }

    private var avatar: some View {
        let url = URL(string: "https://i.pravatar.cc/300?img=49")
        return AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.secondary)
            case .empty:
                ZStack {
                    Color(.tertiarySystemFill)
                    ProgressView()
                }
            @unknown default:
                Color(.tertiarySystemFill)
            }
        }
        .frame(width: 88, height: 88)
        .clipShape(Circle())
        .overlay(
            Circle().stroke(Color.white.opacity(0.6), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
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
