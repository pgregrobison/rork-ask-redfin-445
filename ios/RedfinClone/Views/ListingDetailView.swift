import SwiftUI

struct ListingDetailView: View {
    let listing: Listing
    let isSaved: Bool
    let onToggleSave: () -> Void
    @State private var showFullDescription: Bool = false
    @State private var showPhotoViewer: Bool = false
    @State private var selectedPhotoIndex: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                photoGallery
                detailContent
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: listing.shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onToggleSave) {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        .contentTransition(.symbolEffect(.replace))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .sensoryFeedback(.selection, trigger: isSaved)
            }
        }
        .fullScreenCover(isPresented: $showPhotoViewer) {
            PhotoViewerView(
                photos: listing.photos,
                selectedIndex: $selectedPhotoIndex
            )
        }
    }

    private var photoGallery: some View {
        VStack(spacing: 2) {
            ForEach(Array(listing.photos.enumerated()), id: \.offset) { index, url in
                Button {
                    selectedPhotoIndex = index
                    showPhotoViewer = true
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
        }
    }

    private var detailContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule()
                .fill(Color(.systemGray3))
                .frame(width: 36, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
                .padding(.bottom, 16)

            headerSection
                .padding(.horizontal, 20)

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

            Color.clear.frame(height: 100)
        }
        .background(Color(.systemBackground))
        .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
        .offset(y: -16)
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(listing.formattedFullPrice)
                    .font(.largeTitle.bold())

                HStack(spacing: 8) {
                    Text("\(listing.beds) bd")
                    Text("·")
                    Text("\(listing.bathsFormatted) ba")
                    Text("·")
                    Text("\(listing.sqft.formatted()) sq ft")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Text(listing.fullAddress)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "mappin.circle")
                .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                .foregroundStyle(Theme.redfinGreenColor)
                .frame(width: 44, height: 44)
                .background(Color(.tertiarySystemBackground), in: Circle())
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About this home")
                .font(.title3.bold())

            Text(listing.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(showFullDescription ? nil : 3)

            if listing.description.count > 120 {
                Button(showFullDescription ? "Show less" : "Continue reading") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showFullDescription.toggle()
                    }
                }
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
            }
        }
    }

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

    private var bottomActionBar: some View {
        HStack(spacing: 12) {
            if #available(iOS 26.0, *) {
                Button(action: {}) {
                    Text("Request showing")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.primary, in: .rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button(action: {}) {
                    Image(systemName: "sparkle")
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                }
                .glassEffect(.regular.interactive(), in: .circle)
            } else {
                Button(action: {}) {
                    Text("Request showing")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.primary, in: .rect(cornerRadius: 12))
                }

                Button(action: {}) {
                    Image(systemName: "sparkle")
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .adaptiveGlassBar()
    }
}
