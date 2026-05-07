import SwiftUI
import UIKit

@MainActor
final class TourDayBannerWindow {
    static let shared = TourDayBannerWindow()

    private var window: UIWindow?

    private init() {}

    func present(onTap: @escaping () -> Void) {
        guard window == nil else { return }
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
            ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first
        else { return }

        let newWindow = PassthroughWindow(windowScene: scene)
        newWindow.windowLevel = .alert + 1
        newWindow.backgroundColor = .clear
        newWindow.isHidden = false

        let banner = FakeTourDayNotificationBanner(
            onTap: { [weak self] in
                onTap()
                self?.dismiss()
            },
            onDismiss: { [weak self] in
                self?.dismiss()
            }
        )

        let host = UIHostingController(rootView:
            ZStack(alignment: .top) { banner }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea()
        )
        host.view.backgroundColor = .clear
        newWindow.rootViewController = host
        self.window = newWindow
    }

    func dismiss() {
        window?.isHidden = true
        window = nil
    }
}

private final class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hit = super.hitTest(point, with: event) else { return nil }
        // Only catch taps on the banner content; let everything else pass through to the app below.
        return hit === rootViewController?.view ? nil : hit
    }
}
