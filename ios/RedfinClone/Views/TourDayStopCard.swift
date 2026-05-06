import SwiftUI

struct TourDayStopCard: View {
    let listing: Listing
    let stopNumber: Int
    let totalStops: Int
    let time: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.sm) {
                photoView
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption2.bold())
                            .foregroundStyle(.primary)
                        Text("Stop \(stopNumber) of \(totalStops) • \(time)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    Text(listing.address)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text("\(listing.beds) bd • \(listing.bathsFormatted) ba • \(listing.formattedPrice)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(Theme.Spacing.sm)
            .background(Theme.Colors.secondaryBackground)
            .clipShape(.rect(cornerRadius: Theme.Radius.medium))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Theme.Spacing.md)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.92).combined(with: .opacity),
            removal: .opacity
        ))
    }

    private var photoView: some View {
        Color(.tertiarySystemBackground)
            .frame(width: 64, height: 64)
            .overlay {
                if let urlStr = listing.photos.first, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill).allowsHitTesting(false)
                        default:
                            Image(systemName: "house.fill")
                                .font(.title3)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
            .clipShape(.rect(cornerRadius: Theme.Radius.small))
            .overlay(alignment: .topLeading) {
                ZStack {
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 22, height: 22)
                    Text("\(stopNumber)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.Colors.invertedPrimary)
                }
                .padding(4)
            }
    }
}
