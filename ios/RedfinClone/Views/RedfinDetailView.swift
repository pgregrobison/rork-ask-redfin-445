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

    private let redfinRed = Color(red: 0.78, green: 0.13, blue: 0.13)

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

    private var photoCarouselHeight: CGFloat { 340 }

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
                .padding(.trailing, 16)
                .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
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

    private var heroPhotoCarousel: some View {
        TabView(selection: $currentPhotoIndex) {
            ForEach(Array(listing.photos.enumerated()), id: \.offset) { index, url in
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
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: photoCarouselHeight)
        .overlay(alignment: .topLeading) {
            if let badge = listing.primaryBadge {
                Text(badge.text)
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badge.color, in: .rect(cornerRadius: 6))
                    .padding(.top, 60)
                    .padding(.leading, 16)
            }
        }
        .overlay(alignment: .topTrailing) {
            Text("\(currentPhotoIndex + 1) / \(listing.photos.count)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.black.opacity(0.5), in: .rect(cornerRadius: 8))
                .padding(.top, 60)
                .padding(.trailing, 16)
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
        .padding(.horizontal, 20)
    }

    // MARK: - Price & Address

    private var priceAndAddressSection: some View {
        VStack(spacing: 6) {
            Text(listing.formattedFullPrice)
                .font(.system(size: 32, weight: .bold))
                .padding(.top, 20)

            HStack(spacing: 4) {
                Text("\(listing.beds) beds")
                Text("·")
                Text("\(listing.bathsFormatted) baths")
                Text("·")
                Text("\(listing.sqft.formatted()) sq ft")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(listing.fullAddress)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 16)
    }

    // MARK: - Rate & Estimate Row

    private var rateEstimateRow: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("$\(totalMonthly.formatted())/mo")
                    .font(.subheadline.bold())
                HStack(spacing: 4) {
                    Text("Rates dropped")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: "info.circle")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 10))

            Spacer()

            Button(action: {}) {
                Text("Estimate my rate")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(redfinRed, in: .rect(cornerRadius: 10))
            }
        }
        .padding(.bottom, 16)
    }

    // MARK: - Request Showing

    private var requestShowingSection: some View {
        Button(action: {}) {
            Text("Request showing")
                .font(.headline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.separator), lineWidth: 1)
                )
        }
        .padding(.bottom, 12)
    }

    // MARK: - Action Buttons

    private var actionButtonsRow: some View {
        HStack(spacing: 20) {
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
        .padding(.bottom, 8)
    }

    private func actionCircle(icon: String, tint: Color? = nil) -> some View {
        Image(systemName: icon)
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(tint ?? .primary)
            .frame(width: 44, height: 44)
            .overlay(
                Circle()
                    .stroke(Color(.separator), lineWidth: 1)
            )
    }

    // MARK: - Property Details Grid

    private var propertyDetailsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                propertyDetailItem(icon: "house", value: listing.propertyType, label: "Property type")
                propertyDetailItem(icon: "calendar", value: "\(listing.yearBuilt)", label: "Built")
                propertyDetailItem(icon: "arrow.up.left.and.arrow.down.right", value: listing.lotSize, label: "Lot size")
                propertyDetailItem(icon: "dollarsign.circle", value: "$\(listing.pricePerSqFt)", label: "per sq ft")
                propertyDetailItem(icon: "chart.line.uptrend.xyaxis", value: listing.formattedFullPrice, label: "Redfin Estimate")
                propertyDetailItem(icon: "banknote", value: listing.hoaDues == "N/A" ? "$0" : listing.hoaDues, label: "HOA dues")
            }
        }
        .padding(.vertical, 8)
    }

    private func propertyDetailItem(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Highlights

    private var highlightsSection: some View {
        Group {
            if !listing.tags.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 8)], alignment: .leading, spacing: 8) {
                        ForEach(listing.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(.separator), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(listing.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(showFullDescription ? nil : 3)

            if listing.description.count > 100 {
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
                    .foregroundStyle(redfinRed)
                }
            }

            Button(action: {}) {
                Text("Full property details")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Monthly Payment Breakdown

    private var monthlyPaymentBreakdown: some View {
        VStack(spacing: 20) {
            Text("$\(totalMonthly.formatted()) /mo")
                .font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)

            paymentBreakdownList

            paymentBar

            paymentInputs

            VStack(alignment: .leading, spacing: 4) {
                Text("Loan details")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("30-yr fixed, 6.67%")
                    .font(.subheadline.weight(.medium))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
    }

    private var paymentBreakdownList: some View {
        VStack(spacing: 12) {
            paymentLineItem(color: Color(red: 0.2, green: 0.4, blue: 0.8), label: "Principal and interest", amount: principalAndInterest, percent: totalMonthly > 0 ? Int(Double(principalAndInterest) / Double(totalMonthly) * 100) : 0)
            paymentLineItem(color: Color(red: 0.3, green: 0.7, blue: 0.4), label: "Property taxes", amount: propertyTaxes, percent: totalMonthly > 0 ? Int(Double(propertyTaxes) / Double(totalMonthly) * 100) : 0)
            paymentLineItem(color: Color(red: 0.95, green: 0.7, blue: 0.2), label: "Homeowners insurance", amount: homeInsurance, percent: totalMonthly > 0 ? Int(Double(homeInsurance) / Double(totalMonthly) * 100) : 0)
            if hoaDuesAmount > 0 {
                paymentLineItem(color: Color(red: 0.6, green: 0.4, blue: 0.8), label: "HOA dues", amount: hoaDuesAmount, percent: totalMonthly > 0 ? Int(Double(hoaDuesAmount) / Double(totalMonthly) * 100) : 0)
            }
        }
    }

    private func paymentLineItem(color: Color, label: String, amount: Int, percent: Int) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.subheadline)
            Spacer()
            Text("$\(amount.formatted()) (\(percent)%)")
                .font(.subheadline)
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
                    .fill(Color(red: 0.2, green: 0.4, blue: 0.8))
                    .frame(width: max(piWidth, 2))
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 0.3, green: 0.7, blue: 0.4))
                    .frame(width: max(taxWidth, 2))
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 0.95, green: 0.7, blue: 0.2))
                    .frame(width: max(insWidth, 2))
                if hoaDuesAmount > 0 {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 0.6, green: 0.4, blue: 0.8))
                        .frame(width: max(hoaWidth, 2))
                }
            }
        }
        .frame(height: 8)
    }

    private var paymentInputs: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Home price")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(listing.formattedFullPrice)
                    .font(.subheadline.weight(.medium))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text("Down payment")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(Int(downPaymentPercent))% ($\((Int(Double(listing.price) * downPaymentPercent / 100.0)).formatted()))")
                    .font(.subheadline.weight(.medium))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Estimate Payment Button

    private var estimatePaymentButton: some View {
        VStack(spacing: 12) {
            Button(action: {}) {
                Text("Estimate my payment & rate")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(redfinRed, in: .rect(cornerRadius: 10))
            }

            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(Theme.redfinGreenColor)
                    Text("Takes about 3 minutes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(Theme.redfinGreenColor)
                    Text("Won't affect your credit score")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Take a Tour

    private var takeTourSection: some View {
        VStack(spacing: 16) {
            Text("Take a tour")
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)

            Image(systemName: "house.fill")
                .font(.system(size: 48))
                .foregroundStyle(redfinRed.opacity(0.15))
                .padding(.bottom, 4)

            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "person.2")
                        .font(.subheadline.weight(.semibold))
                    Text("Tour in person")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(redfinRed.opacity(0.08), in: .rect(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(redfinRed.opacity(0.3), lineWidth: 1)
                )
            }

            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "video")
                        .font(.subheadline.weight(.semibold))
                    Text("Tour via video chat")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.separator), lineWidth: 1)
                )
            }

            Text("It's free, cancel anytime.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 8)
        }
    }

    // MARK: - Ask Redfin Section

    private var askRedfinSection: some View {
        VStack(spacing: 12) {
            Text("Ask Redfin")
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)

            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 40))
                .foregroundStyle(redfinRed.opacity(0.2))

            Text("I'm here to help answer your questions about this property or your services. I can also connect you with a licensed advisor. Let's dive in!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            Button(action: onAskRedfin) {
                HStack(spacing: 6) {
                    Image(systemName: "bubble.left")
                        .font(.subheadline.weight(.semibold))
                    Text("Let's chat")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .overlay(
                    Capsule()
                        .stroke(Color(.separator), lineWidth: 1)
                )
            }
            .padding(.bottom, 8)
        }
    }

    // MARK: - Lifestyle

    private var lifestyleSection: some View {
        VStack(spacing: 16) {
            Text("Lifestyle")
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)

            Image(systemName: "figure.walk")
                .font(.system(size: 36))
                .foregroundStyle(Theme.redfinGreenColor.opacity(0.3))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                lifestylePill(icon: "figure.walk", label: "Walker's paradise")
                lifestylePill(icon: "bicycle", label: "Some bike-ability")
                lifestylePill(icon: "moon.zzz", label: "Silent zone")
                lifestylePill(icon: "leaf", label: "Always calm")
            }

            Button(action: {}) {
                Text("How is this calculated?")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .underline()
            }

            Text("Provided by Walk Score and Local Logic")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 8)
        }
    }

    private func lifestylePill(icon: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(label)
                .font(.subheadline)
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }

    // MARK: - Sticky Ask Redfin FAB

    private var askRedfinFAB: some View {
        GlassActionButton(icon: "sparkle", action: onAskRedfin, size: 52)
    }

    // MARK: - Divider

    private var sectionDivider: some View {
        Divider()
            .padding(.vertical, 16)
    }
}

private struct RedfinScrollOffsetKey: PreferenceKey {
    nonisolated static let defaultValue: CGFloat = 0
    nonisolated static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
