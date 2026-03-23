import SwiftUI

struct FocusedPhotoViewer: View {
    let photos: [String]
    let selectedIndex: Int
    let isSaved: Bool
    let onToggleSave: () -> Void
    let listing: Listing
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int
    @State private var dragOffset: CGFloat = 0
    @State private var backgroundOpacity: Double = 1.0

    init(photos: [String], selectedIndex: Int, isSaved: Bool, onToggleSave: @escaping () -> Void, listing: Listing) {
        self.photos = photos
        self.selectedIndex = selectedIndex
        self.isSaved = isSaved
        self.onToggleSave = onToggleSave
        self.listing = listing
        _currentIndex = State(initialValue: selectedIndex)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(backgroundOpacity)
                .ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(Array(photos.enumerated()), id: \.offset) { index, url in
                    AsyncImage(url: URL(string: url)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else if phase.error != nil {
                            Color.clear
                        } else {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(y: dragOffset)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .gesture(
                DragGesture(minimumDistance: 40)
                    .onChanged { value in
                        if abs(value.translation.height) > abs(value.translation.width) {
                            dragOffset = value.translation.height
                            let progress = min(abs(value.translation.height) / 300, 1.0)
                            backgroundOpacity = 1.0 - progress * 0.5
                        }
                    }
                    .onEnded { value in
                        if abs(value.translation.height) > 120 {
                            dismiss()
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = 0
                                backgroundOpacity = 1.0
                            }
                        }
                    }
            )

            VStack(spacing: 0) {
                navHeader
                Spacer()
                footer
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(false)
    }

    private var navHeader: some View {
        HStack {
            GlassActionButton(icon: "chevron.left", action: { dismiss() })

            Spacer()

            GlassActionButtonRow(items: [
                GlassActionButtonItem(icon: isSaved ? "heart.fill" : "heart", action: onToggleSave),
                GlassActionButtonItem(icon: "square.and.arrow.up", action: {})
            ])
        }
        .padding(.horizontal, 16)
        .padding(.top, safeAreaTop + 4)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                Text("Request showing")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.78, green: 0.13, blue: 0.13), in: .rect(cornerRadius: 30))
            }
            .buttonStyle(.plain)

            GlassActionButton(icon: "sparkle") {}
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, max(safeAreaBottom, 12))
    }

    private var safeAreaTop: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 0
    }

    private var safeAreaBottom: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0
    }
}
