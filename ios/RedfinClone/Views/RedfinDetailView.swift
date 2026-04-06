import SwiftUI
import MapKit

struct RedfinDetailView: View {
    let listing: Listing
    let isSaved: Bool
    let onToggleSave: () -> Void
    let onAskRedfin: () -> Void
    @State private var currentPhotoIndex: Int = 0
    @State private var showFullDescription: Bool = false
    @State private var scrollOffset: CGFloat = 0
    @State private var homePrice: String = ""
    @State private var downPaymentPercent: Double = 20
    @State private var selectedMediaTab: Int = 0

    private let redfinRed = Theme.Colors.brandRed

    private var monthlyPayment: Int {
        let principal = Double(listing.price) * (1.0 - downPaymentPercent / 100.0)
        let annualRate = 0.0667
        let monthlyRate = annualRate / 12.0
        let months = 360.0
        guard monthlyRate > 0 else { return 0 }
        let payment = principal * (monthlyRate * pow(1 + monthlyRate, months)) / (pow(1 + monthlyRate, months) - 1)
        return Int(payment)
    }

    private var principalAndInterest: Int { monthlyPayment }

    private var propertyTaxes: Int {
        Int(Double(listing.price) * 0.012 / 12.0)
    }

    private var homeInsurance: Int {
        Int(Double(listing.price) * 0.005 / 12.0)
    }

    private var hoaDuesAmount: Int {
        let cleaned = listing.hoaDues
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "/mo", with: "")
            .trimmingCharacters(in: .whitespaces)
        return Int(cleaned) ?? 0
    }

    private var totalMonthly: Int {
        principalAndInterest + propertyTaxes + homeInsurance + hoaDuesAmount
    }

    private var photoCarouselHeight: CGFloat {
        UIScreen.main.bounds.height * 0.5
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 0) {
                    heroPhotoCarousel
                    mainContent
                }
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: RedfinScrollOffsetKey.self,
                            value: geo.frame(in: .named("redfinScroll")).minY
                        )
                    }
                )
            }
            .coordinateSpace(name: "redfinScroll")
            .onPreferenceChange(RedfinScrollOffsetKey.self) { value in
                scrollOffset = value
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)

            askRedfinFAB
                .padding(.trailing, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.md)
        }
        .background(Theme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(scrollOffset < -(photoCarouselHeight - 100) ? .visible : .hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if scrollOffset < -(photoCarouselHeight - 100) {
                    Text(listing.address)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                        .transition(.opacity)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { onToggleSave() } label: {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        .contentTransition(.symbolEffect(.replace))
                        .foregroundStyle(isSaved ? .red : scrollOffset < -(photoCarouselHeight - 100) ? .primary : .white)
                }
                .sensoryFeedback(.selection, trigger: isSaved)
            }
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: listing.shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        .foregroundStyle(scrollOffset < -(photoCarouselHeight - 100) ? Color.primary : Color.white)
                }
            }
        }
        .toolbarColorScheme(scrollOffset < -(photoCarouselHeight - 100) ? nil : .dark, for: .navigationBar)
        .onAppear {
            homePrice = listing.formattedFullPrice
        }
    }

    // MARK: - Hero Photo Carousel

    private let segmentedControlBottomInset: CGFloat = 16
    private let dotsAboveSegmented: CGFloat = 8

    private var heroPhotoCarousel: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentPhotoIndex) {
                ForEach(Array(listing.photos.enumerated()), id: \.offset) { index, url in
                    Theme.Colors.tertiaryBackground
                        .overlay {
                            AsyncImage(url: URL(string: url)) { phase in
                                if let image = phase.image {
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } else if phase.error != nil {
                                    Theme.Colors.tertiaryBackground
                                } else {
                                    ProgressView()
                                }
                            }
                            .allowsHitTesting(false)
                        }
                        .clipped()
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: photoCarouselHeight)

            VStack(spacing: dotsAboveSegmented) {
                carouselDots
                mediaSegmentedControl
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.bottom, segmentedControlBottomInset)
        }
        .frame(height: photoCarouselHeight)
        .clipShape(.rect)
    }

    private var carouselDots: some View {
        HStack(spacing: Theme.Spacing.xxs + 2) {
            ForEach(0..<listing.photos.count, id: \.self) { index in
                Circle()
                    .fill(index == currentPhotoIndex ? Color.white : Color.white.opacity(0.5))
                    .frame(width: 7, height: 7)
            }
        }
    }

    private var mediaSegmentedControl: some View {
        Picker("", selection: $selectedMediaTab) {
            Text("Media").tag(0)
            Text("Map").tag(1)
            Text("3D").tag(2)
            Text("Street").tag(3)
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: Theme.Container.spacing) {
            priceAndAddressSection
            requestShowingSection

            sectionContainer {
                propertyDetailsContent
            }

            descriptionSection

            sectionContainer(accent: true) {
                ratePaymentContent
            }

            sectionContainer {
                takeTourContent
            }

            sectionContainer {
                askRedfinContent
            }

            sectionContainer {
                lifestyleContent
            }

            Color.clear.frame(height: 80)
        }
        .padding(.horizontal, Theme.Spacing.md)
    }

    // MARK: - Section Container

    private func sectionContainer<Content: View>(accent: Bool = false, @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(Theme.Container.padding)
            .background(
                RoundedRectangle(cornerRadius: Theme.Container.radius, style: .continuous)
                    .stroke(
                        accent ? Theme.Colors.separator.opacity(0.8) : Theme.Container.borderColor,
                        lineWidth: Theme.Container.borderWidth
                    )
            )
    }

    // MARK: - Price & Address

    private var priceAndAddressSection: some View {
        VStack(spacing: Theme.Spacing.xxs + 2) {
            Text(listing.formattedFullPrice)
                .font(Theme.Typography.heroNumber)
                .padding(.top, Theme.Spacing.lg)

            HStack(spacing: Theme.Spacing.xxs) {
                Text("\(listing.beds) beds")
                Text("·")
                Text("\(listing.bathsFormatted) baths")
                Text("·")
                Text("\(listing.sqft.formatted()) sq ft")
            }
            .font(Theme.Typography.secondary)
            .foregroundStyle(.secondary)

            Text(listing.fullAddress)
                .font(Theme.Typography.secondary)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, Theme.Spacing.xs)
    }

    // MARK: - Request Showing

    private var requestShowingSection: some View {
        Button(action: {}) {
            Text("Request showing")
        }
        .buttonStyle(.primary)
    }

    // MARK: - Property Details Container Content

    private var propertyDetailsContent: some View {
        VStack(spacing: Theme.Container.spacing) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Container.spacing) {
                iconTagCell(icon: "house", label: listing.propertyType, sublabel: "Property type")
                iconTagCell(icon: "calendar", label: "\(listing.yearBuilt)", sublabel: "Built")
                iconTagCell(icon: "arrow.up.left.and.arrow.down.right", label: listing.lotSize, sublabel: "Lot size")
                iconTagCell(icon: "dollarsign.circle", label: "$\(listing.pricePerSqFt)", sublabel: "per sq ft")
                iconTagCell(icon: "chart.line.uptrend.xyaxis", label: listing.formattedFullPrice, sublabel: "Redfin Estimate")
                iconTagCell(icon: "banknote", label: listing.hoaDues == "N/A" ? "$0" : listing.hoaDues, sublabel: "HOA dues")
            }

            if !listing.tags.isEmpty {
                Divider()

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Container.spacing) {
                    ForEach(listing.tags, id: \.self) { tag in
                        iconTagCell(icon: iconForTag(tag), label: tag)
                    }
                }
            }
        }
    }

    private func iconTagCell(icon: String, label: String, sublabel: String? = nil) -> some View {
        VStack(spacing: Theme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: Theme.IconTag.iconSize, weight: .medium))
                .foregroundStyle(Theme.IconTag.iconColor)

            TagView(text: label)

            if let sublabel {
                Text(sublabel)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func iconForTag(_ tag: String) -> String {
        let lowered = tag.lowercased()
        if lowered.contains("modern") || lowered.contains("fixture") { return "lightbulb" }
        if lowered.contains("island") || lowered.contains("kitchen") { return "frying.pan" }
        if lowered.contains("garage") { return "car" }
        if lowered.contains("patio") || lowered.contains("backyard") { return "tree" }
        if lowered.contains("bedroom") || lowered.contains("spacious") { return "bed.double" }
        if lowered.contains("closet") { return "door.left.hand.open" }
        if lowered.contains("pool") { return "figure.pool.swim" }
        if lowered.contains("view") { return "mountain.2" }
        if lowered.contains("fireplace") { return "fireplace" }
        if lowered.contains("solar") { return "sun.max" }
        if lowered.contains("smart") || lowered.contains("tech") { return "wifi" }
        if lowered.contains("hardwood") || lowered.contains("floor") { return "square.grid.3x3" }
        return "sparkle"
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(listing.description)
                .font(Theme.Typography.body)
                .foregroundStyle(.secondary)
                .lineLimit(showFullDescription ? nil : 3)

            if listing.description.count > 100 {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showFullDescription.toggle()
                    }
                } label: {
                    HStack(spacing: Theme.Spacing.xxs) {
                        Text(showFullDescription ? "Show less" : "Continue reading")
                        Image(systemName: showFullDescription ? "chevron.up" : "chevron.down")
                            .font(Theme.Typography.captionBold)
                    }
                }
                .buttonStyle(.textLink)
            }

            Button(action: {}) {
                Text("Full property details")
            }
            .buttonStyle(.secondary)
            .padding(.top, Theme.Spacing.xxs)
        }
        .padding(.vertical, Theme.Spacing.xs)
    }

    // MARK: - Rate/Payment Container Content

    private var ratePaymentContent: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Text("$\(totalMonthly.formatted()) /mo")
                .font(Theme.Typography.largeNumber)
                .frame(maxWidth: .infinity, alignment: .center)

            paymentBreakdownList

            paymentBar

            HStack(spacing: Theme.Container.spacing) {
                paymentInputCell(label: "Home price", value: listing.formattedFullPrice)
                paymentInputCell(label: "Down payment", value: "\(Int(downPaymentPercent))% ($\((Int(Double(listing.price) * downPaymentPercent / 100.0)).formatted()))")
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text("Loan details")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
                Text("30-yr fixed, 6.67%")
                    .font(.subheadline.weight(.medium))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: {}) {
                Text("Estimate my payment & rate")
            }
            .buttonStyle(.primary)

            VStack(spacing: Theme.Spacing.xxs + 2) {
                HStack(spacing: Theme.Spacing.xxs + 2) {
                    Image(systemName: "checkmark")
                        .font(Theme.Typography.captionBold)
                        .foregroundStyle(Theme.Colors.brandGreen)
                    Text("Takes about 3 minutes")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: Theme.Spacing.xxs + 2) {
                    Image(systemName: "checkmark")
                        .font(Theme.Typography.captionBold)
                        .foregroundStyle(Theme.Colors.brandGreen)
                    Text("Won't affect your credit score")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func paymentInputCell(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: Theme.Spacing.xxs) {
                Text(value)
                    .font(.subheadline.weight(.medium))
                Image(systemName: "pencil")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var paymentBreakdownList: some View {
        VStack(spacing: Theme.Spacing.sm) {
            paymentLineItem(color: Theme.Colors.Chart.blue, label: "Principal and interest", amount: principalAndInterest, percent: totalMonthly > 0 ? Int(Double(principalAndInterest) / Double(totalMonthly) * 100) : 0)
            paymentLineItem(color: Theme.Colors.Chart.green, label: "Property taxes", amount: propertyTaxes, percent: totalMonthly > 0 ? Int(Double(propertyTaxes) / Double(totalMonthly) * 100) : 0)
            paymentLineItem(color: Theme.Colors.Chart.amber, label: "Homeowners insurance", amount: homeInsurance, percent: totalMonthly > 0 ? Int(Double(homeInsurance) / Double(totalMonthly) * 100) : 0)
            if hoaDuesAmount > 0 {
                paymentLineItem(color: Theme.Colors.Chart.purple, label: "HOA dues", amount: hoaDuesAmount, percent: totalMonthly > 0 ? Int(Double(hoaDuesAmount) / Double(totalMonthly) * 100) : 0)
            }
        }
    }

    private func paymentLineItem(color: Color, label: String, amount: Int, percent: Int) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(Theme.Typography.secondary)
            Spacer()
            Text("$\(amount.formatted()) (\(percent)%)")
                .font(Theme.Typography.secondary)
                .foregroundStyle(.secondary)
        }
    }

    private var paymentBar: some View {
        GeometryReader { geo in
            let total = max(CGFloat(totalMonthly), 1)
            let piWidth = geo.size.width * CGFloat(principalAndInterest) / total
            let taxWidth = geo.size.width * CGFloat(propertyTaxes) / total
            let insWidth = geo.size.width * CGFloat(homeInsurance) / total
            let hoaWidth = geo.size.width * CGFloat(hoaDuesAmount) / total

            HStack(spacing: 2) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Theme.Colors.Chart.blue)
                    .frame(width: max(piWidth, 2))
                RoundedRectangle(cornerRadius: 3)
                    .fill(Theme.Colors.Chart.green)
                    .frame(width: max(taxWidth, 2))
                RoundedRectangle(cornerRadius: 3)
                    .fill(Theme.Colors.Chart.amber)
                    .frame(width: max(insWidth, 2))
                if hoaDuesAmount > 0 {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.Colors.Chart.purple)
                        .frame(width: max(hoaWidth, 2))
                }
            }
        }
        .frame(height: 8)
    }

    // MARK: - Take a Tour Container Content

    private var takeTourContent: some View {
        VStack(spacing: Theme.Spacing.md) {
            Text("Take a tour")
                .font(Theme.Typography.sectionTitle)
                .frame(maxWidth: .infinity, alignment: .center)

            Image(systemName: "house.fill")
                .font(Theme.Typography.decorativeXL)
                .foregroundStyle(redfinRed.opacity(0.15))
                .padding(.bottom, Theme.Spacing.xxs)

            Button(action: {}) {
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "person.2")
                    Text("Tour in person")
                }
            }
            .buttonStyle(.primary)

            Button(action: {}) {
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "video")
                    Text("Tour via video chat")
                }
            }
            .buttonStyle(.secondary)

            Text("It's free, cancel anytime.")
                .font(Theme.Typography.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Ask Redfin Container Content

    private var askRedfinContent: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text("Ask Redfin")
                .font(Theme.Typography.sectionTitle)
                .frame(maxWidth: .infinity, alignment: .center)

            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(Theme.Typography.decorativeLG)
                .foregroundStyle(redfinRed.opacity(0.2))

            Text("I'm here to help answer your questions about this property or your services. I can also connect you with a licensed advisor. Let's dive in!")
                .font(Theme.Typography.secondary)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: onAskRedfin) {
                HStack(spacing: Theme.Spacing.xxs + 2) {
                    Image(systemName: "bubble.left")
                        .font(.subheadline.weight(.semibold))
                    Text("Let's chat")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, Theme.Spacing.xxl)
                .padding(.vertical, Theme.ButtonSize.compactVerticalPadding)
                .overlay(
                    Capsule()
                        .stroke(Theme.Colors.separator, lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Lifestyle Container Content

    private var lifestyleContent: some View {
        VStack(spacing: Theme.Spacing.md) {
            Text("Lifestyle")
                .font(Theme.Typography.sectionTitle)
                .frame(maxWidth: .infinity, alignment: .center)

            Image(systemName: "figure.walk")
                .font(Theme.Typography.decorativeMD)
                .foregroundStyle(Theme.Colors.brandGreen.opacity(0.3))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Container.spacing) {
                iconTagCell(icon: "figure.walk", label: "Walker's paradise")
                iconTagCell(icon: "bicycle", label: "Some bike-ability")
                iconTagCell(icon: "speaker.slash", label: "Silent zone")
                iconTagCell(icon: "leaf", label: "Always calm")
            }

            Button(action: {}) {
                Text("How is this calculated?")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
                    .underline()
            }

            Text("Provided by Walk Score and Local Logic")
                .font(Theme.Typography.micro)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Sticky Ask Redfin FAB

    private var askRedfinFAB: some View {
        GlassActionButton(icon: "sparkle", action: onAskRedfin, size: 52)
    }
}

private struct RedfinScrollOffsetKey: PreferenceKey {
    nonisolated static let defaultValue: CGFloat = 0
    nonisolated static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
