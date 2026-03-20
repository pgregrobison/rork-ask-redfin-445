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
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                tabPillContent
                    .padding(.horizontal, 8)
                    .glassEffect(.regular.interactive(), in: .capsule)

                Button(action: onFABTap) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 62, height: 62)
                }
                .glassEffect(.regular.interactive(), in: .circle)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 2)
        }
    }

    private var legacyTabBar: some View {
        HStack(spacing: 12) {
            tabPillContent
                .padding(.horizontal, 8)
                .background(.ultraThinMaterial, in: Capsule())
                .shadow(color: .black.opacity(0.15), radius: 12, y: 4)

            Button(action: onFABTap) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 62, height: 62)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)

                    Image(systemName: "sparkle")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 2)
    }

    private var tabPillContent: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.snappy(duration: 0.25)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 19, weight: .semibold))
                        Text(tab.title)
                            .font(.caption2)
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

struct ShimmerRingModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color.primary.opacity(0),
                                Color.primary.opacity(0.15),
                                Color.primary.opacity(0.25),
                                Color.primary.opacity(0)
                            ],
                            center: .center,
                            startAngle: .degrees(phase),
                            endAngle: .degrees(phase + 360)
                        ),
                        lineWidth: 2.5
                    )
                    .frame(width: 76, height: 76)
                    .blur(radius: 2)
            }
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    phase = 360
                }
            }
    }
}

extension View {
    func shimmerRing() -> some View {
        modifier(ShimmerRingModifier())
    }
}
