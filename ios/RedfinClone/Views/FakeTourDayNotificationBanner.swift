import SwiftUI

struct FakeTourDayNotificationBanner: View {
    let onTap: () -> Void
    let onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var appeared: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image("RedfinLogo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 38, height: 38)
                .clipShape(.rect(cornerRadius: 9))

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("ASK REDFIN")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                    Spacer(minLength: 0)
                    Text("now")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                Text("Welcome to tour day!")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text("I've created a new thread for all things tours.")
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 8)
        .padding(.horizontal, 10)
        .offset(y: appeared ? min(dragOffset, 12) : -160)
        .opacity(appeared ? 1 : 0)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    if value.translation.height < -30 {
                        dismiss()
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            dragOffset = 0
                        }
                    }
                }
        )
        .onTapGesture {
            onTap()
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
                appeared = true
            }
            Task {
                try? await Task.sleep(for: .seconds(5))
                dismiss()
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeIn(duration: 0.25)) {
            appeared = false
        }
        Task {
            try? await Task.sleep(for: .milliseconds(260))
            onDismiss()
        }
    }
}
