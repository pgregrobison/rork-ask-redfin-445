import SwiftUI
import MapKit

struct ListingDetailView: View {
    let listing: Listing
    let isSaved: Bool
    let onToggleSave: () -> Void
    @State private var showFullDescription: Bool = false
    @State private var focusedPhotoIndex: Int? = nil
    @State private var sheetOffset: CGFloat = 0
    @State private var sheetSnap: SheetSnap = .collapsed
    @State private var dragStartOffset: CGFloat = 0

    private let collapsedPeekHeight: CGFloat = 220
    private let sheetTopPadding: CGFloat = 100

    private var maxSheetTravel: CGFloat {
        UIScreen.main.bounds.height - sheetTopPadding - collapsedPeekHeight
    }

    private var currentSheetY: CGFloat {
        let screenH = UIScreen.main.bounds.height
        let collapsedY = screenH - collapsedPeekHeight
        return collapsedY - sheetOffset
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                photoScroll
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                detailSheet(in: geo)

                stickyFooter
            }
        }
        .ignoresSafeArea()
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button(action: onToggleSave) {
                        Image(systemName: isSaved ? "heart.fill" : "heart")
                            .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                            .foregroundStyle(isSaved ? .red : .primary)
                    }
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    }
                }
            }
        }
        .fullScreenCover(item: $focusedPhotoIndex) { index in
            FocusedPhotoViewer(
                photos: listing.photos,
                selectedIndex: index,
                isSaved: isSaved,
                onToggleSave: onToggleSave,
                listing: listing
            )
        }
    }

    // MARK: - Photo Scroll

    private var photoScroll: some View {
        ScrollView {
            VStack(spacing: 2) {
                ForEach(Array(listing.photos.enumerated()), id: \.offset) { index, url in
                    Button {
                        focusedPhotoIndex = index
                    } label: {
                        Color(.tertiarySystemBackground)
                            .frame(height: 300)
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
                }

                Color.clear.frame(height: collapsedPeekHeight + 80)
            }
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Detail Sheet

    private func detailSheet(in geo: GeometryProxy) -> some View {
        let screenH = geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom

        return VStack(spacing: 0) {
            sheetDragHandle
            sheetContent
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
        .offset(y: screenH - collapsedPeekHeight - sheetOffset)
        .gesture(sheetDrag)
    }

    private var sheetDragHandle: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color(.systemGray3))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }

    private var sheetDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = -value.translation.height
                let newOffset = dragStartOffset + translation
                sheetOffset = max(0, min(maxSheetTravel, newOffset))
            }
            .onEnded { value in
                let velocity = -value.predictedEndTranslation.height / max(1, abs(value.translation.height)) * abs(value.translation.height)
                let projected = sheetOffset + velocity * 0.2
                let midPoint = maxSheetTravel * 0.4

                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    if projected > midPoint {
                        sheetOffset = maxSheetTravel
                        sheetSnap = .expanded
                    } else {
                        sheetOffset = 0
                        sheetSnap = .collapsed
                    }
                }
                dragStartOffset = sheetSnap == .expanded ? maxSheetTravel : 0
            }
    }

    private var sheetContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                    .padding(.horizontal, 20)

                if sheetSnap == .expanded {
                    expandedContent
                }

                Color.clear.frame(height: 100)
            }
        }
        .scrollDisabled(sheetSnap == .collapsed)
        .scrollIndicators(.hidden)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(listing.formattedFullPrice)
                    .font(.largeTitle.bold())

                HStack(spacing: 8) {
                    Text("\(listing.beds) bd")
                    Text("\(listing.bathsFormatted) ba")
                    Text("\(listing.sqft.formatted()) sq ft")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Text(listing.fullAddress)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            miniMapThumbnail
        }
    }

    private var miniMapThumbnail: some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: listing.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))) {
            Annotation("", coordinate: listing.coordinate) {
                Circle()
                    .fill(Theme.redfinGreenColor)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .allowsHitTesting(false)
        .frame(width: 70, height: 70)
        .clipShape(.rect(cornerRadius: 12))
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider().padding(.vertical, 16)

            aboutSection
                .padding(.horizontal, 20)

            metaStatsRow
                .padding(.top, 20)
                .padding(.horizontal, 20)

            Divider().padding(.vertical, 16)

            keyFactsSection
                .padding(.horizontal, 20)

            if listing.isHotHome {
                hotHomeBadge
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
            }

            if !listing.tags.isEmpty {
                highlightsSection
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
            }

            Divider().padding(.vertical, 16)

            moreSections
                .padding(.horizontal, 20)
        }
        .transition(.opacity)
    }

    // MARK: - Footer

    private var stickyFooter: some View {
        VStack(spacing: 0) {
            Spacer()
            detailFooter
        }
    }

    private var detailFooter: some View {
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
        .padding(.bottom, max(safeAreaBottom, 12))
    }

    private var safeAreaBottom: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About this home")
                .font(.title3.bold())

            Text(listing.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(showFullDescription ? nil : 4)

            if listing.description.count > 120 {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showFullDescription.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(showFullDescription ? "Show less" : "Continue reading")
                        Image(systemName: showFullDescription ? "chevron.up" : "chevron.down")
                            .font(.caption.bold())
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(Color(red: 0.78, green: 0.13, blue: 0.13))
                }
            }
        }
    }

    // MARK: - Meta Stats

    private var metaStatsRow: some View {
        HStack(spacing: 0) {
            metaStat(value: "\(listing.daysOnMarket) days", label: "on Redfin")
            Divider().frame(height: 40)
            metaStat(value: "\(listing.viewsCount)", label: "views")
            Divider().frame(height: 40)
            metaStat(value: "\(listing.favoritesCount)", label: "favorites")
        }
    }

    private func metaStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Key Facts

    private var keyFactsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key facts")
                .font(.title3.bold())

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                keyFactRow(icon: "house", value: listing.propertyType, label: "Property type")
                keyFactRow(icon: "calendar", value: "\(listing.yearBuilt)", label: "Year built")
                keyFactRow(icon: "arrow.up.left.and.arrow.down.right", value: listing.lotSize, label: "Lot size")
                keyFactRow(icon: "dollarsign.circle", value: "$\(listing.pricePerSqFt)", label: "Per sq. ft.")
                keyFactRow(icon: "shield", value: listing.hoaDues, label: "HOA dues")
                keyFactRow(icon: "percent", value: listing.buyerAgentFee, label: "Buyer's agent fee")
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func keyFactRow(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.subheadline.bold())
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Hot Home

    private var hotHomeBadge: some View {
        HStack(spacing: 10) {
            Image(systemName: "flame")
                .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                .foregroundStyle(.primary)
            VStack(alignment: .leading, spacing: 2) {
                Text("Hot Home")
                    .font(.headline)
                Text("This home is likely to sell quickly.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    // MARK: - Highlights

    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Highlights")
                .font(.title3.bold())

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(listing.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - More Sections

    private var moreSections: some View {
        VStack(spacing: 0) {
            disclosureRow(icon: "building.2", title: "Neighborhood insights")
            Divider().padding(.leading, 42)
            disclosureRow(icon: "chart.line.uptrend.xyaxis", title: "Price history")
            Divider().padding(.leading, 42)
            disclosureRow(icon: "graduationcap", title: "Schools nearby")
        }
        .padding(4)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func disclosureRow(icon: String, title: String) -> some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 28)
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private enum SheetSnap {
    case collapsed
    case expanded
}

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}
