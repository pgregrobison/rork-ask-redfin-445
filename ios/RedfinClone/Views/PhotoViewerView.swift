import SwiftUI

struct PhotoViewerView: View {
    let photos: [String]
    @Binding var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var dragOffset: CGFloat = 0
    @State private var backgroundOpacity: Double = 1.0

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedIndex) {
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
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .background(Color.black.opacity(backgroundOpacity))
            .ignoresSafeArea()
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("\(selectedIndex + 1) of \(photos.count)")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .statusBarHidden()
    }
}
