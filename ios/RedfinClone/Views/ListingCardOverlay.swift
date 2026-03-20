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
            infoSection
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.3), radius: 20, y: -5)
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
        .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
        .overlay(alignment: .topTrailing) {
            GlassActionButton(icon: "xmark", action: onDismiss, foregroundColor: .white)
                .padding(12)
        }
        .overlay(alignment: .topLeading) {
            if listing.isHotHome {
                Text("HOT HOME")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(white: 0.15), in: Capsule())
                    .padding(12)
            }
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(listing.formattedFullPrice)
                .font(.title2.bold())

            HStack(spacing: 8) {
                Text("\(listing.beds) beds")
                Text("•")
                Text("\(listing.bathsFormatted) baths")
                Text("•")
                Text("\(listing.sqft.formatted()) sq. ft.")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(listing.fullAddress)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 4) {
                ShareLink(item: listing.shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }

                Button(action: onToggleSave) {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .font(.system(size: 20, weight: .semibold))
                        .contentTransition(.symbolEffect(.replace))
                        .foregroundStyle(isSaved ? .primary : .secondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .sensoryFeedback(.selection, trigger: isSaved)
            }
            .padding(.top, 4)
            .padding(.trailing, 4)
        }
    }
}
