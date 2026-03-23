import SwiftUI

struct ListingCardOverlay: View {
    let listing: Listing
    let isSaved: Bool
    let onDismiss: () -> Void
    let onToggleSave: () -> Void
    let onTap: () -> Void
    @State private var currentPhotoIndex: Int = 0

    var body: some View {
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
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: .black.opacity(0.25), radius: 16, y: 4)
        .padding(.horizontal, 16)
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
        .clipShape(.rect(topLeadingRadius: 20, topTrailingRadius: 20))
        .overlay(alignment: .topTrailing) {
            GlassActionButton(icon: "xmark", action: onDismiss, foregroundColor: .white)
                .padding(12)
        }
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 6) {
                if listing.isListedByRedfin {
                    badgeView(.listedByRedfin)
                }
                if listing.isHotHome {
                    badgeView(.hot)
                }
            }
            .padding(12)
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
