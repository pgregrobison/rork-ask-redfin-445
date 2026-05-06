import SwiftUI
import MapKit

struct MyHomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    let isActive: Bool
    let onProfileTap: () -> Void
    var hideProfileButton: Bool = false
    var ownsNavStack: Bool = false
    var debugSettings: DebugSettings
    @Bindable var setupDraft: OTOSetupDraft

    @State private var heroIndex = 0
    @State private var animationKey = UUID()
    @State private var showOTOSetup = false
    @State private var showOTONextSteps = false
    @State private var showOTOSetupFlow = false
    @State private var isOTOButtonLoading = false
    @State private var showOffersSheet = false

    private let pageBg = Color(red: 250/255, green: 249/255, blue: 248/255)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                homeAddressRow
                heroCarousel
                marketInsightsSection
                openToOffersSection
                guideForYourHomeSection
                Spacer().frame(height: Theme.Spacing.md)
            }
            .padding(.top, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.tabBarClearance)
        }
        .background(pageBg)
        .onChange(of: isActive) { _, active in
            if active { animationKey = UUID() }
        }
        .onChange(of: debugSettings.resetDraftTrigger) { _, _ in
            setupDraft.clear()
        }
        .sheet(isPresented: $showOTOSetup) {
            OTOSetupView { debugSettings.otoIsActive = true }
        }
        .sheet(isPresented: $showOTOSetupFlow) {
            OTOSetupFlowView(draft: setupDraft) { debugSettings.otoIsActive = true }
        }
        .sheet(isPresented: $showOTONextSteps) {
            OTONextStepsView()
        }
        .sheet(isPresented: $showOffersSheet) {
            OTOOffersSheetView(isOwnerB: debugSettings.openToOffersVariant == .aggressive)
                .presentationDetents([.large])
        }
        .navigationTitle(ownsNavStack || isActive ? "My Home" : "")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if debugSettings.otoIsActive || setupDraft.hasActiveDraft {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        debugSettings.otoIsActive = false
                        setupDraft.clear()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Reset")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
            if isActive && !hideProfileButton {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { onProfileTap() } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    }
                }
            }
        }
    }

    // MARK: - Address row

    private var homeAddressRow: some View {
        HStack(spacing: 10) {
            AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=200&h=200&fit=crop&auto=format")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(red: 180/255, green: 195/255, blue: 175/255))
                    .overlay(
                        Image(systemName: "house.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.8))
                    )
            }
            .frame(width: 32, height: 32)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            Text("1223 Smith St")
                .font(.system(size: 16))
                .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Hero carousel

    private var heroCarousel: some View {
        VStack(spacing: 16) {
            TabView(selection: $heroIndex) {
                HeroCard(
                    background: Color(red: 3/255,  green: 62/255, blue: 30/255),
                    border:     Color(red: 1/255,  green: 32/255, blue: 15/255),
                    label:      "Home value",
                    labelBg:    Color(red: 1/255,  green: 32/255, blue: 15/255),
                    miniIconBg: Color(red: 0/255,  green: 37/255, blue: 17/255),
                    miniIcon:   "chart.line.uptrend.xyaxis",
                    value:      "$346,500",
                    trend:      "$3K this month",
                    headline:   "Rising due to nearby sales",
                    bodyText:   "Local demand is rising. With two of the three recently sold homes selling above the average price, your property is benefiting from a competitive market.",
                    buttonLabel: "See graph",
                    buttonIcon:  "chart.xyaxis.line"
                ).tag(0)

                HeroCard(
                    background: Color(red: 2/255,  green: 59/255, blue: 64/255),
                    border:     Color(red: 1/255,  green: 21/255, blue: 32/255),
                    label:      "Estimated home equity",
                    labelBg:    Color(red: 1/255,  green: 21/255, blue: 32/255),
                    miniIconBg: Color(red: 0/255,  green: 28/255, blue: 28/255),
                    miniIcon:   "chart.bar.fill",
                    value:      "$43,200",
                    trend:      "$1K this month",
                    headline:   "Positive movement",
                    bodyText:   "Your estimated equity increased slightly since last month, based on your home's value and estimated payments. Add mortgage details for more accuracy.",
                    buttonLabel: "Add mortgage details",
                    buttonIcon:  "plus"
                ).tag(1)

                HeroCard(
                    background: Color(red: 68/255, green: 23/255, blue: 135/255),
                    border:     Color(red: 33/255, green: 11/255, blue: 67/255),
                    label:      "Seasonal reminder",
                    labelBg:    Color(red: 34/255, green: 11/255, blue: 68/255),
                    miniIconBg: Color(red: 50/255, green: 20/255, blue: 90/255),
                    miniIcon:   "sun.max.fill",
                    value:      "Your home,\nfresh for spring.",
                    trend:      nil,
                    headline:   nil,
                    bodyText:   "See what homeowners are tackling this season and find something that works for you.",
                    buttonLabel: "See spring tasks",
                    buttonIcon:  "leaf"
                ).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 380)

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 30)
                        .fill(i == heroIndex
                              ? Color(red: 17/255, green: 17/255, blue: 17/255)
                              : Color(red: 84/255, green: 84/255, blue: 84/255).opacity(0.6))
                        .frame(width: i == heroIndex ? 26 : 12, height: 12)
                        .animation(.easeInOut(duration: 0.2), value: heroIndex)
                }
            }
        }
    }

    // MARK: - Market insights

    private var marketInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Neighborhood market")
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Seattle is a balanced market")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(red: 34/255, green: 34/255, blue: 34/255))
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Supply and demand are about equal. Homes are selling for a fair market value.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 19/255, green: 19/255, blue: 19/255))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)
                }

                MarketGaugePlaceholder()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        StatChip(label: "Median list price",   value: "$639K", change: nil,        mom: "MoM")
                        StatChip(label: "Median sale price",   value: "$645K", change: nil,        mom: "MoM")
                        StatChip(label: "Avg. days on market", value: "12d",   change: "+5 days",  mom: "MoM")
                        StatChip(label: "Recently sold homes", value: "48",    change: "+5",       mom: "MoM")
                    }
                    .padding(.horizontal, 2)
                }
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 221/255, green: 221/255, blue: 221/255), lineWidth: 0.5))

            HStack(spacing: 12) {
                MarketPhotoCard(
                    title: "Sold homes",
                    bg: Color(red: 40/255, green: 32/255, blue: 26/255),
                    imageURL: "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=400&h=400&fit=crop&auto=format",
                    badgeLabel: "SOLD",
                    primaryText: "$411,000",
                    secondaryText: "103 Bird's Cove Dr."
                )
                MarketPhotoCard(
                    title: "Listed homes",
                    bg: Color(red: 26/255, green: 36/255, blue: 28/255),
                    imageURL: "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400&h=400&fit=crop&auto=format",
                    badgeLabel: nil,
                    primaryText: "11 nearby",
                    secondaryText: "This month"
                )
            }
        }
        .padding(.horizontal, 12)
    }

    // MARK: - Open to Offers

    private var openToOffersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if debugSettings.otoIsActive {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Open to Offers")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))
                    Text("34 buyers have reacted to your price.")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(red: 34/255, green: 34/255, blue: 34/255))
                }
                otoDashboardCard
            } else if debugSettings.openToOffersVariant == .conservative {
                openToOffersConservative
            } else {
                Text("See what your home is worth to real buyers")
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))
                    .fixedSize(horizontal: false, vertical: true)
                openToOffersAggressive
            }
        }
        .padding(.horizontal, 12)
    }

    private var otoDashboardCard: some View {
        let teal   = Color(red: 21/255,  green: 114/255, blue: 122/255)
        let green  = Color(red: 1/255,   green: 120/255, blue: 62/255)
        let dark   = Color(red: 17/255,  green: 17/255,  blue: 17/255)
        let mid    = Color(red: 104/255, green: 104/255, blue: 104/255)
        let inset  = Color(red: 56/255,  green: 52/255,  blue: 48/255).opacity(0.06)
        let border = Color(red: 221/255, green: 221/255, blue: 221/255)

        return VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(teal)
                (Text("Listed Apr 16  ·  Expires Jun 16")
                    .foregroundColor(dark) +
                 Text("  (24 days left)")
                    .foregroundColor(mid))
                    .font(.system(size: 14))
                Spacer()
            }
            .padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 12) {
                sentimentRow(label: "5 Great deal", percent: "15%", fg: green, bgOpacity: 0.1, borderColor: green, bold: false)
                sentimentRow(label: "16 Fair price", percent: "47%", fg: teal, bgOpacity: 0.1, borderColor: teal, bold: true)
                sentimentRow(label: "13 Too high", percent: "38%", fg: dark, bgOpacity: 0.0, borderColor: border, bold: false, insetColor: inset, percentColor: mid)
                Text("Based on reactions from 34 interested buyers")
                    .font(.system(size: 12))
                    .foregroundStyle(mid)
            }
            .padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 5) {
                Text("What buyers are saying")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(mid)
                Text("Above comp prices (8), Needs updating (5), Great location (4), Move-in ready (3)")
                    .font(.system(size: 14))
                    .foregroundStyle(dark)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 16)

            HStack(spacing: 12) {
                Button(action: { showOffersSheet = true }) {
                    statTile(value: "3", label: "Offers submitted", inset: inset, dark: dark)
                }
                .buttonStyle(.plain)
                statTile(value: "12", label: "Views", inset: inset, dark: dark)
            }
            .padding(.horizontal, 16)

            VStack(spacing: 10) {
                Button(action: { showOTONextSteps = true }) {
                    Text("Take the next step")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(red: 34/255, green: 34/255, blue: 34/255))
                        .clipShape(Capsule())
                }
                Button(action: { showOTOSetupFlow = true }) {
                    Text("Edit listing")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(teal)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(border, lineWidth: 0.5))
    }

    private func sentimentRow(label: String, percent: String, fg: Color, bgOpacity: Double, borderColor: Color, bold: Bool, insetColor: Color? = nil, percentColor: Color? = nil) -> some View {
        HStack {
            HStack {
                Text(label)
                    .font(.system(size: 16, weight: bold ? .bold : .regular))
                    .foregroundStyle(fg)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 32)
            .padding(.horizontal, 12)
            .background(insetColor ?? fg.opacity(bgOpacity))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(percent)
                .font(.system(size: 16, weight: bold ? .bold : .regular))
                .foregroundStyle(percentColor ?? fg)
                .frame(width: 44, alignment: .trailing)
        }
        .padding(2)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderColor, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func statTile(value: String, label: String, inset: Color, dark: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(dark)
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(dark)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(inset)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var openToOffersConservative: some View {
        let red    = Color(red: 222/255, green: 51/255,  blue: 65/255)
        let dark   = Color(red: 34/255,  green: 34/255,  blue: 34/255)
        let mid    = Color(red: 102/255, green: 102/255, blue: 102/255)
        let border = Color(red: 221/255, green: 221/255, blue: 221/255)

        return VStack(alignment: .leading, spacing: 16) {
            Text("OPEN TO OFFERS")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color(red: 3/255, green: 62/255, blue: 30/255))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(red: 201/255, green: 243/255, blue: 215/255))
                .clipShape(Capsule())

            Text("Not ready to list?\nYou don't have to be.")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(dark)
                .fixedSize(horizontal: false, vertical: true)

            Text("Hear from buyers before you decide anything.\nNo commitment, no listing, no clock running.")
                .font(.system(size: 15))
                .foregroundStyle(mid)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 14) {
                Button(action: { showOTOSetup = true }) {
                    Text("See who's interested")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(red)
                        .clipShape(Capsule())
                }
                Button(action: {}) {
                    Text("How does it work?")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color(red: 21/255, green: 114/255, blue: 122/255))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(border, lineWidth: 0.5))
    }

    private var openToOffersAggressive: some View {
        OpenToOffersMapPreview()
            .frame(height: 380)
            .overlay(alignment: .bottom) {
                VStack(spacing: 18) {
                    VStack(spacing: 8) {
                        Button {
                            guard !isOTOButtonLoading else { return }
                            isOTOButtonLoading = true
                            Task {
                                try? await Task.sleep(for: .seconds(0.75))
                                isOTOButtonLoading = false
                                showOTOSetupFlow = true
                            }
                        } label: {
                            ZStack {
                                if isOTOButtonLoading {
                                    ThreeDotsLoading()
                                } else {
                                    Text(setupDraft.hasActiveDraft ? "Continue drafting" : "Open my home to offers")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(Color.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(red: 222/255, green: 51/255, blue: 65/255))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .disabled(isOTOButtonLoading)
                        Text("No listing. No commitment. No sense of urgency.")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(red: 102/255, green: 102/255, blue: 102/255))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    Button(action: {}) {
                        Text("How does this compare to selling?")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color(red: 21/255, green: 114/255, blue: 122/255))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
                .padding(.top, 48)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [.clear, Color(.systemBackground).opacity(0.9), Color(.systemBackground)],
                        startPoint: .top,
                        endPoint: UnitPoint(x: 0.5, y: 0.5)
                    )
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 221/255, green: 221/255, blue: 221/255), lineWidth: 0.5))
    }

    // MARK: - Guide for your home

    private var guideForYourHomeSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("A guide for your home")
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))
                Text("What to do, what's worth it, and who can help.")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    HomeGuideTipCard(title: "Clean dryer vent duct", cost: "$0–$25 avg.")
                    HomeGuideTipCard(title: "Service HVAC filter", cost: "$20–$40 avg.")
                    HomeGuideTipCard(title: "Inspect roof for damage", cost: "$150–$300 avg.")
                    HomeGuideTipCard(title: "Seal window gaps", cost: "$10–$50 avg.")
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Reimagine your space")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))

                ReimagineSpacePlaceholder()

                Button(action: {}) {
                    Text("Get started")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(red: 19/255, green: 19/255, blue: 19/255))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                }
                .background(Color.white)
                .overlay(Capsule().stroke(Color(red: 34/255, green: 34/255, blue: 34/255), lineWidth: 1))
                .clipShape(Capsule())
                .padding(.top, 8)
            }

            VStack(alignment: .leading, spacing: 16) {
                Text("Work with a local pro")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.top, 12)
                    .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))

                VStack(spacing: 12) {
                    HomeGuideProRow(title: "Lawn care",       imageURL: "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=120&h=120&fit=crop&auto=format")
                    HomeGuideProRow(title: "Tree trimming",   imageURL: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=120&h=120&fit=crop&auto=format")
                    HomeGuideProRow(title: "Gutter cleaning", imageURL: "https://images.unsplash.com/photo-1605146769289-440113cc3d00?w=120&h=120&fit=crop&auto=format")
                }
            }

            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Search projects")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(Color(red: 19/255, green: 19/255, blue: 19/255))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
            }
            .background(Color.white)
            .overlay(Capsule().stroke(Color(red: 34/255, green: 34/255, blue: 34/255), lineWidth: 1))
            .clipShape(Capsule())
            .padding(.top, 8)
        }
        .padding(.horizontal, 12)
    }
}

// MARK: - HeroCard

private struct HeroCard: View {
    let background:  Color
    let border:      Color
    let label:       String
    let labelBg:     Color
    let miniIconBg:  Color
    let miniIcon:    String
    let value:       String
    let trend:       String?
    let headline:    String?
    let bodyText:    String
    let buttonLabel: String
    let buttonIcon:  String

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(background)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(border, lineWidth: 6)
                )

            VStack(alignment: .leading, spacing: 32) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(value)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(Color.white)
                            .monospacedDigit()

                        if let trend {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 11, weight: .bold))
                                Text(trend)
                                    .font(.system(size: 14))
                                    .monospacedDigit()
                            }
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                        }
                    }

                    Spacer()

                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(miniIconBg)
                            .frame(width: 59, height: 59)
                        Image(systemName: miniIcon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.7))
                    }
                    .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
                }

                VStack(alignment: .leading, spacing: 8) {
                    if let headline {
                        Text(headline)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Text(bodyText)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button(action: {}) {
                    HStack(spacing: 8) {
                        Image(systemName: buttonIcon)
                            .font(.system(size: 15, weight: .semibold))
                        Text(buttonLabel)
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(Color(red: 19/255, green: 19/255, blue: 19/255))
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(Capsule().stroke(Color(red: 34/255, green: 34/255, blue: 34/255), lineWidth: 1))
                    .clipShape(Capsule())
                }
            }
            .padding(.top, 66)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(labelBg)
                .clipShape(.rect(bottomTrailingRadius: 30))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 8)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - StatChip

private struct StatChip: View {
    let label: String
    let value: String
    let change: String?
    let mom: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Color(red: 19/255, green: 19/255, blue: 19/255))
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(red: 19/255, green: 19/255, blue: 19/255))
                .monospacedDigit()
            if let change {
                HStack(spacing: 2) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color(red: 1/255, green: 120/255, blue: 62/255))
                    Text(change)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(red: 1/255, green: 120/255, blue: 62/255))
                        .monospacedDigit()
                    + Text(" \(mom)")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(red: 104/255, green: 104/255, blue: 104/255))
                }
            }
        }
        .padding(16)
        .frame(width: 163, alignment: .leading)
        .background(Color(red: 249/255, green: 249/255, blue: 249/255))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 221/255, green: 221/255, blue: 221/255), lineWidth: 0.5))
    }
}

// MARK: - MarketPhotoCard

private struct MarketPhotoCard: View {
    let title: String
    let bg: Color
    let imageURL: String
    let badgeLabel: String?
    let primaryText: String
    let secondaryText: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            AsyncImage(url: URL(string: imageURL)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                bg
            }
            LinearGradient(
                colors: [Color.black.opacity(0.65), Color.clear, Color.black.opacity(0.5)],
                startPoint: .top, endPoint: .bottom
            )

            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.white)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    if let badge = badgeLabel {
                        Text(badge)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(red: 21/255, green: 114/255, blue: 122/255))
                            .clipShape(Capsule())
                    }
                    Text(primaryText)
                        .font(.system(size: 23, weight: .bold))
                        .foregroundStyle(Color.white)
                        .monospacedDigit()
                        .lineLimit(1)
                    Text(secondaryText)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                }
            }
            .padding(16)
        }
        .frame(height: 185)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - HomeGuideTipCard

private struct HomeGuideTipCard: View {
    let title: String
    let cost: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 19/255, green: 19/255, blue: 19/255))
                    .lineLimit(2)
                Spacer()
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color(red: 104/255, green: 104/255, blue: 104/255))
                    .padding(.top, 3)
            }

            HStack(spacing: 0) {
                Text(cost)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 104/255, green: 104/255, blue: 104/255))
                    .monospacedDigit()
                Spacer()
                Button(action: {}) {
                    Text("View tips")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(red: 21/255, green: 114/255, blue: 122/255))
                }
            }
        }
        .padding(20)
        .frame(width: 220, height: 108, alignment: .topLeading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 209/255, green: 209/255, blue: 209/255), lineWidth: 0.5))
    }
}

// MARK: - HomeGuideProRow

private struct HomeGuideProRow: View {
    let title: String
    let imageURL: String

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: imageURL)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color(.systemGray5)
            }
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text("TRENDING")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(red: 17/255, green: 17/255, blue: 17/255))
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 209/255, green: 209/255, blue: 209/255), lineWidth: 0.5))
    }
}

// MARK: - Open to Offers Map preview

private struct OpenToOffersMapPreview: View {
    private let region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 47.6202, longitude: -122.3208),
        span: MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
    )
    private let pins: [PinData] = [
        PinData(id: 0, coordinate: CLLocationCoordinate2D(latitude: 47.6221, longitude: -122.3208), isUserHome: true,  price: "$925K"),
        PinData(id: 1, coordinate: CLLocationCoordinate2D(latitude: 47.6228, longitude: -122.3252), isUserHome: false, price: "$892K"),
        PinData(id: 2, coordinate: CLLocationCoordinate2D(latitude: 47.6224, longitude: -122.3168), isUserHome: false, price: "$1.01M"),
        PinData(id: 3, coordinate: CLLocationCoordinate2D(latitude: 47.6232, longitude: -122.3190), isUserHome: false, price: "$938K"),
        PinData(id: 4, coordinate: CLLocationCoordinate2D(latitude: 47.6213, longitude: -122.3228), isUserHome: false, price: "$905K"),
    ]

    private struct PinData: Identifiable {
        let id: Int
        let coordinate: CLLocationCoordinate2D
        let isUserHome: Bool
        let price: String
    }

    private let teal  = Color(red: 21/255, green: 114/255, blue: 122/255)
    private let green = Color(red: 1/255, green: 120/255, blue: 62/255)

    var body: some View {
        Map(initialPosition: .region(region)) {
            ForEach(pins) { pin in
                Annotation("", coordinate: pin.coordinate, anchor: .center) {
                    pinView(for: pin)
                }
            }
        }
        .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .excludingAll))
        .saturation(0.6)
        .disabled(true)
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [.clear, Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 160)
            .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private func pinView(for pin: PinData) -> some View {
        VStack(spacing: 4) {
            if pin.isUserHome {
                Text("Est. \(pin.price)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(teal)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.18), radius: 4, y: 2)
                ZStack {
                    Circle()
                        .fill(green)
                        .frame(width: 24, height: 24)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
                    Image(systemName: "house.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white)
                }
            } else {
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color(.systemGray4))
                        .frame(width: 18, height: 18)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundStyle(.white)
                        )
                    Text(pin.price)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color(red: 34/255, green: 34/255, blue: 34/255))
                }
                .padding(.leading, 5)
                .padding(.trailing, 8)
                .padding(.vertical, 5)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.18), radius: 4, y: 2)
            }
        }
    }
}
