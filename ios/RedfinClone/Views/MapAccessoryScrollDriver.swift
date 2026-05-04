import SwiftUI
import UIKit

/// A real UIKit-backed UIScrollView placed full-bleed over the Find map (accessory mode only).
///
/// Why: iOS 26's `tabBarMinimizeBehavior(.onScrollDown)` watches real scroll-view scroll events.
/// A SwiftUI ScrollView with `.scrollDisabled(true)` driven via `ScrollViewReader` doesn't
/// reliably produce those events. This view exposes a real `UIScrollView` whose
/// `contentOffset` we nudge in response to map pan/zoom gestures, so the tab bar minimizes
/// the way it would when scrolling a normal feed.
///
/// The scroll view itself is non-interactive (`isUserInteractionEnabled = false`) so it never
/// blocks map gestures; it exists purely to feed scroll deltas to the tab-bar machinery.
@available(iOS 26.0, *)
struct MapAccessoryScrollDriver: UIViewRepresentable {
    /// Bumped whenever the map reports a continuous camera change. Each bump triggers
    /// a tiny content-offset nudge to drive the tab-bar minimize behavior.
    var pulse: Int
    /// Drops back to zero offset when true (used to "restore" on tab/list switches).
    var reset: Bool

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> PassthroughContainerView {
        let container = PassthroughContainerView()

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.backgroundColor = .clear
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        scroll.contentInsetAdjustmentBehavior = .never
        // Critical: don't intercept touches — let gestures fall through to the map.
        scroll.isUserInteractionEnabled = false
        container.addSubview(scroll)

        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.backgroundColor = .clear
        scroll.addSubview(content)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: container.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            content.topAnchor.constraint(equalTo: scroll.topAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            content.widthAnchor.constraint(equalTo: scroll.widthAnchor),
            content.heightAnchor.constraint(equalTo: scroll.heightAnchor, multiplier: 3.0),
        ])

        context.coordinator.scrollView = scroll
        return container
    }

    func updateUIView(_ uiView: PassthroughContainerView, context: Context) {
        context.coordinator.apply(pulse: pulse, reset: reset)
    }

    final class Coordinator {
        weak var scrollView: UIScrollView?
        private var lastPulse: Int = 0
        private var lastReset: Bool = false
        // Step contentOffset down by this many points per pulse so each map nudge
        // counts as a fresh "scroll down" event for the tab bar.
        private let stepPerPulse: CGFloat = 12

        func apply(pulse: Int, reset: Bool) {
            guard let scroll = scrollView else { return }

            if reset && !lastReset {
                scroll.setContentOffset(.zero, animated: true)
                lastReset = true
                lastPulse = pulse
                return
            }
            if !reset { lastReset = false }

            if pulse != lastPulse {
                let maxY = max(0, scroll.contentSize.height - scroll.bounds.height)
                let target = min(maxY, scroll.contentOffset.y + stepPerPulse)
                scroll.setContentOffset(CGPoint(x: 0, y: target), animated: true)
                lastPulse = pulse
            }
        }
    }
}

/// Container that never intercepts touches — gestures pass through to whatever sits behind it.
@available(iOS 26.0, *)
final class PassthroughContainerView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
}
