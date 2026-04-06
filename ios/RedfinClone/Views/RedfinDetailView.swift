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
        UIScreen.main.bounds.height * 0.4
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

    private let segmentedControlHeight: CGFloat = 40
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
        .overlay(alignment: .topLeading) {
            if let badge = listing.primaryBadge {
                Text(badge.text)
                    .font(Theme.Typography.micro.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, Theme.Spacing.xs)
                    .padding(.vertical, Theme.Spacing.xxs)
                    .background(badge.color, in: .rect(cornerRadius: Theme.Radius.xs))
                    .padding(.top, Theme.Spacing.xxl + 28)
                    .padding(.leading, Theme.Spacing.md)
            }
        }
        .overlay(alignment: .topTrailing) {
            Text("\(currentPhotoIndex + 1) / \(listing.photos.count)")
                .font(Theme.Typography.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, Theme.Spacing.xs + 2)
                .padding(.vertical, Theme.Spacing.xxs + 1)
                .background(.black.opacity(0.5), in: .rect(cornerRadius: Theme.Radius.small))
                .padding(.top, Theme.Spacing.xxl + 28)
                .padding(.trailing, Theme.Spacing.md)
        }
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
        Group {
            if #available(iOS 26.0, *) {
                Picker("", selection: $selectedMediaTab) {
                    Text("Media").tag(0)
                    Text("Map").tag(1)
                    Text("3D").tag(2)
                    Text("Street").tag(3)
                }
                .pickerStyle(.segmented)
                .frame(height: segmentedControlHeight)
                .glassEffect(in: .capsule)
            } else {
                Picker("", selection: $selectedMediaTab) {
                    Text("Media").tag(0)
                    Text("Map").tag(1)
                    Text("3D").tag(2)
                    Text("Street").tag(3)
                }
                .pickerStyle(.segmented)
                .frame(height: segmentedControlHeight)
            }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            priceAndAddressSection
            rateEstimateRow
            requestShowingSection
            actionButtonsRow

            sectionDivider

            propertyDetailsGrid

            sectionDivider

            highlightsSection

            descriptionSection

            sectionDivider

            monthlyPaymentBreakdown

            estimatePaymentButton

            sectionDivider

            takeTourSection

            sectionDivider

            askRedfinSection

            sectionDivider

            lifestyleSection

            Color.clear.frame(height: 80)
        }
        .padding(.horizontal, Theme.Spacing.lg)
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
        .padding(.bottom, Theme.Spacing.md)
    }

    // MARK: - Rate & Estimate Row

    private var rateEstimateRow: some View {
        HStack(spacing: Theme.Spacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text("$\(totalMonthly.formatted())/mo")
                    .font(Theme.Typography.secondaryBold)
                HStack(spacing: Theme.Spacing.xxs) {
                    Text("Rates dropped")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: "info.circle")
                        .font(Theme.Typography.micro)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, Theme.Spacing.sm + 2)
            .padding(.vertical, Theme.Spacing.xs + 2)
            .background(Theme.Colors.secondaryBackground, in: .rect(cornerRadius: Theme.Radius.medium))

            Spacer()

            Button(action: {}) {
                Text("Estimate my rate")
            }
            .buttonStyle(.smallPill)
        }
        .padding(.bottom, Theme.Spacing.md)
    }

    // MARK: - Request Showing

    private var requestShowingSection: some View {
        Button(action: {}) {
            Text("Request showing")
        }
        .buttonStyle(.primary)
        .padding(.bottom, Theme.Spacing.sm)
    }

    // MARK: - Action Buttons

    private var actionButtonsRow: some View {
        HStack(spacing: Theme.Spacing.lg) {
            Spacer()

            ShareLink(item: listing.shareText) {
                actionCircle(icon: "square.and.arrow.up")
            }

            Button { onToggleSave() } label: {
                actionCircle(icon: isSaved ? "heart.fill" : "heart", tint: isSaved ? .red : nil)
            }
            .sensoryFeedback(.selection, trigger: isSaved)

            Button(action: {}) {
                actionCircle(icon: "ellipsis")
            }

            Spacer()
        }
        .padding(.bottom, Theme.Spacing.xs)
    }

    private func actionCircle(icon: String, tint: Color? = nil) -> some View {
        Image(systemName: icon)
            .font(.system(size: Theme.ButtonSize.iconSize, weight: .medium))
            .foregroundStyle(tint ?? .primary)
            .frame(width: Theme.ButtonSize.circleSize, height: Theme.ButtonSize.circleSize)
            .overlay(
                Circle()
                    .stroke(Theme.Colors.separator, lineWidth: 1)
            )
    }

    // MARK: - Property Details Grid

    private var propertyDetailsGrid: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
                propertyDetailItem(icon: "house", value: listing.propertyType, label: "Property type")
                propertyDetailItem(icon: "calendar", value: "\(listing.yearBuilt)", label: "Built")
                propertyDetailItem(icon: "arrow.up.left.and.arrow.down.right", value: listing.lotSize, label: "Lot size")
                propertyDetailItem(icon: "dollarsign.circle", value: "$\(listing.pricePerSqFt)", label: "per sq ft")
                propertyDetailItem(icon: "chart.line.uptrend.xyaxis", value: listing.formattedFullPrice, label: "Redfin Estimate")
                propertyDetailItem(icon: "banknote", value: listing.hoaDues == "N/A" ? "$0" : listing.hoaDues, label: "HOA dues")
            }
        }
        .padding(.vertical, Theme.Spacing.xs)
    }

    private func propertyDetailItem(icon: String, value: String, label: String) -> some View {
        HStack(spacing: Theme.Spacing.xs + 2) {
            Image(systemName: icon)
                .font(.system(size: Theme.ButtonSize.iconSize, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(Theme.Typography.secondaryBold)
                    .lineLimit(1)
                Text(label)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Highlights

    private var highlightsSection: some View {
        Group {
            if !listing.tags.isEmpty {
                TagGrid(tags: listing.tags)
                    .padding(.vertical, Theme.Spacing.xs)
            }
        }
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

    // MARK: - Monthly Payment Breakdown

    private var monthlyPaymentBreakdown: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Text("$\(totalMonthly.formatted()) /mo")
                .font(Theme.Typography.largeNumber)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, Theme.Spacing.xs)

            paymentBreakdownList

            paymentBar

            paymentInputs

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text("Loan details")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
                Text("30-yr fixed, 6.67%")
                    .font(.subheadline.weight(.medium))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, Theme.Spacing.xs)
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

    private var paymentInputs: some View {
        HStack(spacing: Theme.Spacing.md) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text("Home price")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
                Text(listing.formattedFullPrice)
                    .font(.subheadline.weight(.medium))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text("Down payment")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
                Text("\(Int(downPaymentPercent))% ($\((Int(Double(listing.price) * downPaymentPercent / 100.0)).formatted()))")
                    .font(.subheadline.weight(.medium))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Estimate Payment Button

    private var estimatePaymentButton: some View {
        VStack(spacing: Theme.Spacing.sm) {
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
        .padding(.vertical, Theme.Spacing.xs)
    }

    // MARK: - Take a Tour

    private var takeTourSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            Text("Take a tour")
                .font(Theme.Typography.sectionTitle)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, Theme.Spacing.xs)

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
                .padding(.bottom, Theme.Spacing.xs)
        }
    }

    // MARK: - Ask Redfin Section

    private var askRedfinSection: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text("Ask Redfin")
                .font(Theme.Typography.sectionTitle)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, Theme.Spacing.xs)

            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(Theme.Typography.decorativeLG)
                .foregroundStyle(redfinRed.opacity(0.2))

            Text("I'm here to help answer your questions about this property or your services. I can also connect you with a licensed advisor. Let's dive in!")
                .font(Theme.Typography.secondary)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.md)

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
            .padding(.bottom, Theme.Spacing.xs)
        }
    }

    // MARK: - Lifestyle

    private var lifestyleSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            Text("Lifestyle")
                .font(Theme.Typography.sectionTitle)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, Theme.Spacing.xs)

            Image(systemName: "figure.walk")
                .font(Theme.Typography.decorativeMD)
                .foregroundStyle(Theme.Colors.brandGreen.opacity(0.3))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.xs + 2) {
                lifestylePill(icon: "figure.walk", label: "Walker's paradise")
                lifestylePill(icon: "bicycle", label: "Some bike-ability")
                lifestylePill(icon: "moon.zzz", label: "Silent zone")
                lifestylePill(icon: "leaf", label: "Always calm")
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
                .padding(.bottom, Theme.Spacing.xs)
        }
    }

    private func lifestylePill(icon: String, label: String) -> some View {
        HStack(spacing: Theme.Spacing.xxs + 2) {
            Image(systemName: icon)
                .font(Theme.Typography.caption)
                .foregroundStyle(.secondary)
            Text(label)
                .font(Theme.Typography.secondary)
                .lineLimit(1)
        }
        .padding(.horizontal, Theme.Spacing.sm + 2)
        .padding(.vertical, Theme.Spacing.xs + 2)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.xl)
                .stroke(Theme.Colors.separator, lineWidth: 1)
        )
    }

    // MARK: - Sticky Ask Redfin FAB

    private var askRedfinFAB: some View {
        GlassActionButton(icon: "sparkle", action: onAskRedfin, size: 52)
    }

    // MARK: - Divider

    private var sectionDivider: some View {
        Divider()
            .padding(.vertical, Theme.Spacing.md)
    }
}

private struct RedfinScrollOffsetKey: PreferenceKey {
    nonisolated static let defaultValue: CGFloat = 0
    nonisolated static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
