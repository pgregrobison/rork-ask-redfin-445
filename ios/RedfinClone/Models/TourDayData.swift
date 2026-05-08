import Foundation

nonisolated enum TourDayData {
    static let demoRoute = TourDayRoute(stops: [
        TourDayStop(id: 1, listingId: "9", time: "9:00 AM"),
        TourDayStop(id: 2, listingId: "5", time: "10:30 AM"),
        TourDayStop(id: 3, listingId: "2", time: "12:00 PM"),
        TourDayStop(id: 4, listingId: "1", time: "2:00 PM")
    ])

    static let voicePhrasesByStop: [Int: String] = [
        1: "I really like all the natural light and vaulted ceilings, but the kitchen is way too small.",
        2: "Beautiful finishes, but the second bedroom was way smaller than I expected.",
        3: "Honestly, this one was incredible. The view sold me.",
        4: "The space is great, but I'm not sure about the location."
    ]

    static let assistantAcksByStop: [Int: String] = [
        1: "Got it — light is a strong yes, kitchen size is a concern. Logging that.",
        2: "Noted — finishes loved, second bedroom too tight. I'll flag it.",
        3: "Adding this one to your top picks. Big yes on the view.",
        4: "Got it — space yes, location maybe. Saving that for later."
    ]
}
