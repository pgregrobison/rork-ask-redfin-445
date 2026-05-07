import SwiftUI
import UIKit

@MainActor
final class TourDayBannerWindow {
    static let shared = TourDayBannerWindow()

    private var window: PassthroughWindow?

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
            },
            onFrameChange: { [weak newWindow] frame in
                newWindow?.bannerFrame = frame
            }
        )

        let host = UIHostingController(rootView:
            VStack(spacing: 0) { banner; Spacer(minLength: 0) }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 4)
        )
        host.view.backgroundColor = .clear
        host.view.isOpaque = false
        newWindow.rootViewController = host
        self.window = newWindow
    }

    func dismiss() {
        window?.isHidden = true
        window = nil
    }
}

final class PassthroughWindow: UIWindow {
    var bannerFrame: CGRect = .zero

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Only intercept touches that land within the banner pill;
        // everything else passes through to the app below.
        guard bannerFrame.contains(point) else { return nil }
        return super.hitTest(point, with: event)
    }
}
