import SwiftUI

struct FluidGrowDetailView: View {
    let listing: Listing
    let isVisible: Bool
    let isSaved: Bool
    let onToggleSave: () -> Void
    let onAskRedfin: () -> Void
    let onDismiss: () -> Void

    private var safeAreaTop: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 0
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(.systemBackground)
                .ignoresSafeArea()

            NavigationStack {
                ListingDetailView(
                    listing: listing,
                    isSaved: isSaved,
                    onToggleSave: onToggleSave,
                    onAskRedfin: onAskRedfin
                )
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button { onDismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { onToggleSave() } label: {
                            Image(systemName: isSaved ? "heart.fill" : "heart")
                                .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                                .contentTransition(.symbolEffect(.replace))
                                .foregroundStyle(isSaved ? .red : .primary)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        ShareLink(item: listing.shareText) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        }
                    }
                }
            }
            .tint(.primary)
        }
        .scaleEffect(isVisible ? 1.0 : 0.92)
        .opacity(isVisible ? 1.0 : 0)
        .ignoresSafeArea()
    }
}
