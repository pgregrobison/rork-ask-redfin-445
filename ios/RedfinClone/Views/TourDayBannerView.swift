import SwiftUI

struct TourDayBannerView: View {
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Theme.Colors.brandRed)
                    .frame(width: 32, height: 32)
                Image(systemName: "car.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 6) {
                    Text("ASK REDFIN")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Text("now")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
                Text("Welcome to tour day!")
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text("I've created a new thread for all things tours.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, Theme.Spacing.sm + 2)
        .padding(.vertical, Theme.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.18), radius: 18, y: 6)
        .padding(.horizontal, Theme.Spacing.sm)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}
