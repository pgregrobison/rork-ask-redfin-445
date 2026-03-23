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
                    Text("LISTED BY REDFIN")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.78, green: 0.13, blue: 0.13), in: .rect(cornerRadius: 4))
                }
                if listing.isHotHome {
                    Text("HOT HOME")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(white: 0.15), in: Capsule())
                }
            }
            .padding(12)
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                Text(listing.formattedFullPrice)
                    .font(.title2.bold())

                Spacer()

                HStack(spacing: 4) {
                    ShareLink(item: listing.shareText) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: Theme.IconSize.small, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: Theme.IconSize.smallTap, height: Theme.IconSize.smallTap)
                            .contentShape(Rectangle())
                    }

                    Button(action: onToggleSave) {
                        Image(systemName: isSaved ? "heart.fill" : "heart")
                            .font(.system(size: Theme.IconSize.small, weight: .semibold))
                            .contentTransition(.symbolEffect(.replace))
                            .foregroundStyle(isSaved ? .primary : .secondary)
                            .frame(width: Theme.IconSize.smallTap, height: Theme.IconSize.smallTap)
                            .contentShape(Rectangle())
                    }
                    .sensoryFeedback(.selection, trigger: isSaved)
                }
            }

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
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 14)
    }
}
