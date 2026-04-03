import SwiftUI

nonisolated enum AppTab: Int, CaseIterable, Sendable {
    case find = 0
    case forYou = 1
    case saved = 2
    case myHome = 3

    var title: String {
        switch self {
        case .find: "Find"
        case .forYou: "For You"
        case .saved: "Saved"
        case .myHome: "My Home"
        }
    }

    var icon: String {
        switch self {
        case .find: "magnifyingglass"
        case .forYou: "square.stack"
        case .saved: "heart"
        case .myHome: "house"
        }
    }

    var selectedIcon: String {
        switch self {
        case .find: "magnifyingglass"
        case .forYou: "square.stack.fill"
        case .saved: "heart.fill"
        case .myHome: "house.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    let onFABTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if #available(iOS 26.0, *) {
            glassTabBar
        } else {
            legacyTabBar
        }
    }

    @available(iOS 26.0, *)
    private var glassTabBar: some View {
        GlassEffectContainer(spacing: Theme.Spacing.sm) {
            HStack(spacing: Theme.Spacing.sm) {
                tabPillContent
                    .padding(.horizontal, Theme.Spacing.xs)
                    .glassEffect(.regular.interactive(), in: .capsule)

                Button(action: onFABTap) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 62, height: 62)
                }
                .glassEffect(.regular.interactive(), in: .circle)
            }
            .padding(.horizontal, Theme.Spacing.md)
        }
    }

    private var legacyTabBar: some View {
        HStack(spacing: Theme.Spacing.sm) {
            tabPillContent
                .padding(.horizontal, Theme.Spacing.xs)
                .background(.ultraThinMaterial, in: Capsule())
                .shadow(color: Theme.Shadow.overlayColor, radius: Theme.Shadow.overlayRadius, y: Theme.Shadow.overlayY)

            Button(action: onFABTap) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 62, height: 62)
                        .shadow(color: Theme.Shadow.overlayColor, radius: Theme.Shadow.mediumRadius, y: Theme.Shadow.mediumY)

                    Image(systemName: "sparkle")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
    }

    private var tabPillContent: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.snappy(duration: 0.25)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: Theme.Spacing.xxs) {
                        Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                            .font(.system(size: 19, weight: .semibold))
                            .contentTransition(.symbolEffect(.replace))
                        Text(tab.title)
                            .font(Theme.Typography.micro)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                    }
                    .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                }
            }
        }
    }
}


