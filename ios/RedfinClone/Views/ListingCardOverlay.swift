import SwiftUI
import UIKit

struct ListingCardOverlay: View {
    let listing: Listing
    let isSaved: Bool
    var zoomNamespace: Namespace.ID
    let onDismiss: () -> Void
    let onToggleSave: () -> Void
    let onTap: () -> Void
    @State private var currentPhotoIndex: Int = 0

    private let cardInset: CGFloat = 8
    private let deviceEdgeInset: CGFloat = 8

    private var cardCornerRadius: CGFloat {
        let screenRadius = UIScreen.main.value(forKey: ["Radius", "Corner", "display", "_"].reversed().joined()) as? CGFloat ?? 44
        return max(screenRadius - deviceEdgeInset, 12)
    }

    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                VStack(spacing: 0) {
                    photoCarousel
                    HomeCardInfoSection(
                        listing: listing,
                        size: .large,
                        isSaved: isSaved,
                        onToggleSave: onToggleSave
                    )
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: cardCornerRadius, style: .continuous))
                .shadow(color: .black.opacity(0.25), radius: 16, y: 4)
                .matchedTransitionSource(id: listing.id, in: zoomNamespace)
                .padding(.horizontal, cardInset)
                .padding(.bottom, max(deviceEdgeInset - geo.safeAreaInsets.bottom, 0))
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var photoCarousel: some View {
        TabView(selection: $currentPhotoIndex) {
            ForEach(Array(listing.photos.prefix(5).enumerated()), id: \.offset) { index, url in
                Button(action: onTap) {
                    Color(.tertiarySystemBackground)
                        .overlay {
                            AsyncImage(url: URL(string: url)) { phase in
                                if let image = phase.image {
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } else if phase.error != nil {
                                    Color(.tertiarySystemBackground)
                                } else {
                                    ProgressView()
                                }
                            }
                            .allowsHitTesting(false)
                        }
                        .clipped()
                }
                .buttonStyle(.plain)
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 220)
        .clipShape(.rect(topLeadingRadius: cardCornerRadius, topTrailingRadius: cardCornerRadius, style: .continuous))
        .overlay(alignment: .topTrailing) {
            GlassActionButton(icon: "xmark", action: onDismiss)
                .padding(12)
        }
        .overlay(alignment: .topLeading) {
            if let badge = listing.primaryBadge {
                badgeView(badge)
                    .padding(.top, 20)
                    .padding(.leading, 20)
            }
        }
    }

    private func badgeView(_ badge: HomeCardBadge) -> some View {
        Text(badge.text)
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badge.color, in: .rect(cornerRadius: 6))
    }
}
