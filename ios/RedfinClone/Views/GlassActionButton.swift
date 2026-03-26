import SwiftUI

struct GlassActionButton: View {
    let icon: String
    let action: () -> Void
    var foregroundColor: Color = .primary

    var body: some View {
        if #available(iOS 26.0, *) {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    .foregroundStyle(foregroundColor)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .fixedSize()
            .glassEffect(.regular.interactive(), in: .circle)
        } else {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    .foregroundStyle(foregroundColor)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .fixedSize()
        }
    }
}

struct GlassActionMenuButton<MenuContent: View>: View {
    let icon: String
    @ViewBuilder let menuContent: () -> MenuContent
    var foregroundColor: Color = .primary

    var body: some View {
        if #available(iOS 26.0, *) {
            Menu {
                menuContent()
            } label: {
                Image(systemName: icon)
                    .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    .foregroundStyle(foregroundColor)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .glassEffect(in: .circle)
        } else {
            Menu {
                menuContent()
            } label: {
                Image(systemName: icon)
                    .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    .foregroundStyle(foregroundColor)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
    }
}

struct GlassActionButtonItem: Identifiable {
    let id = UUID()
    let icon: String
    let action: () -> Void
}

struct GlassActionButtonStack: View {
    let items: [GlassActionButtonItem]

    var body: some View {
        if #available(iOS 26.0, *) {
            GlassActionButtonStackIOS26(items: items)
        } else {
            legacyStack
        }
    }

    private var legacyStack: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                Button(action: item.action) {
                    Image(systemName: item.icon)
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                }
                if index < items.count - 1 {
                    Divider().frame(width: 32)
                }
            }
        }
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 25))
    }
}

@available(iOS 26.0, *)
private struct GlassActionButtonStackIOS26: View {
    let items: [GlassActionButtonItem]
    @Namespace private var unionNamespace

    var body: some View {
        GlassEffectContainer {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    Button(action: item.action) {
                        Image(systemName: item.icon)
                            .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 44, height: 44)
                    }
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 25))
                    .glassEffectUnion(id: "stack", namespace: unionNamespace)
                    if index < items.count - 1 {
                        Divider().frame(width: 32)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}

struct GlassActionButtonRow: View {
    let items: [GlassActionButtonItem]

    var body: some View {
        if #available(iOS 26.0, *) {
            GlassActionButtonRowIOS26(items: items)
        } else {
            legacyRow
        }
    }

    private var legacyRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                Button(action: item.action) {
                    Image(systemName: item.icon)
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                }
                if index < items.count - 1 {
                    Divider().frame(height: 32)
                }
            }
        }
        .background(.ultraThinMaterial, in: Capsule())
    }
}

@available(iOS 26.0, *)
private struct GlassActionButtonRowIOS26: View {
    let items: [GlassActionButtonItem]
    @Namespace private var unionNamespace

    var body: some View {
        GlassEffectContainer {
            HStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    Button(action: item.action) {
                        Image(systemName: item.icon)
                            .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 44, height: 44)
                    }
                    .glassEffect(.regular.interactive(), in: .capsule)
                    .glassEffectUnion(id: "row", namespace: unionNamespace)
                    if index < items.count - 1 {
                        Divider().frame(height: 32)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}
