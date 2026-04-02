import Foundation
import UserNotifications
import CoreLocation

@Observable
class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    var pendingCompassListingID: String?
    private var hasSentThisSession: Bool = false

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func scheduleCompassNotification(nearestListing: Listing) {
        guard !hasSentThisSession else { return }
        hasSentThisSession = true

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "Compass Coming Soon Nearby"
            content.body = "Stop by for a first look walkthrough until 5pm today."
            content.sound = .default
            content.userInfo = ["compassListingID": nearestListing.id]

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            let request = UNNotificationRequest(identifier: "compass-coming-soon", content: content, trigger: trigger)
            center.add(request)
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        if let listingID = userInfo["compassListingID"] as? String {
            await MainActor.run {
                pendingCompassListingID = listingID
            }
        }
    }
}
