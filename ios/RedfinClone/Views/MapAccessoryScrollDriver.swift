import SwiftUI
import UIKit
import MapKit

/// Forwards real finger-driven pan gestures on the Find map into a hidden, real `UIScrollView`,
/// so iOS 26's `tabBarMinimizeBehavior(.onScrollDown)` reacts the same way it would when
/// scrolling a normal feed.
///
/// How it works:
/// 1. We host a real `UIScrollView` (off-screen, non-interactive on its own) in the view tree.
/// 2. We locate the underlying `MKMapView` in the SwiftUI hierarchy.
/// 3. We add the scroll view's `panGestureRecognizer` to the `MKMapView`. UIScrollView still
///    observes its own recognizer regardless of which view it's attached to, so when the user
///    pans the map the scroll view's `contentOffset` updates from a *real* user gesture —
///    exactly what the tab-bar minimize machinery needs.
/// 4. The recognizer's delegate allows simultaneous recognition with MKMapView's own gestures,
///    so the map continues to pan / zoom / rotate as normal.
///
/// Re-expansion of the accessory uses native behavior: the user taps the minimized tab bar.
/// We never reset the offset programmatically.
@available(iOS 26.0, *)
struct MapAccessoryScrollDriver: UIViewRepresentable {

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> PassthroughHostView {
        let host = PassthroughHostView()

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.backgroundColor = .clear
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        scroll.bounces = true
        scroll.contentInsetAdjustmentBehavior = .never
        // Scroll view itself never receives touches directly — its pan recognizer
        // gets reattached to the MKMapView below.
        scroll.isUserInteractionEnabled = false
        host.addSubview(scroll)

        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.backgroundColor = .clear
        scroll.addSubview(content)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: host.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: host.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: host.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: host.trailingAnchor),

            content.topAnchor.constraint(equalTo: scroll.topAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            content.widthAnchor.constraint(equalTo: scroll.widthAnchor),
            // Tall content so vertical pans always have room to scroll.
            content.heightAnchor.constraint(equalTo: scroll.heightAnchor, multiplier: 4.0),
        ])

        // Allow the scroll view's pan recognizer to fire alongside MKMapView's gestures.
        scroll.panGestureRecognizer.delegate = context.coordinator
        // Keep recognizer hot even when scrollView itself isn't user-interactive —
        // its target/action is wired internally by UIScrollView.
        scroll.panGestureRecognizer.cancelsTouchesInView = false

        context.coordinator.scrollView = scroll
        context.coordinator.host = host
        host.coordinator = context.coordinator

        return host
    }

    func updateUIView(_ uiView: PassthroughHostView, context: Context) {
        // Re-attempt attachment on every layout pass until we find the MKMapView.
        context.coordinator.attachIfNeeded()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        weak var scrollView: UIScrollView?
        weak var host: PassthroughHostView?
        weak var attachedMapView: MKMapView?

        /// Walks up to the nearest common ancestor and recursively searches for an `MKMapView`.
        /// Once found, the scroll view's `panGestureRecognizer` is attached to it so real
        /// finger pans drive the scroll view (and thus the tab-bar minimize behavior).
        func attachIfNeeded() {
            guard let host, let scrollView else { return }
            if let attached = attachedMapView,
               attached.gestureRecognizers?.contains(scrollView.panGestureRecognizer) == true {
                return
            }
            // Walk up to find a common ancestor that contains the map.
            var ancestor: UIView? = host.superview
            var foundMap: MKMapView?
            while ancestor != nil {
                if let map = Self.findMapView(in: ancestor!) {
                    foundMap = map
                    break
                }
                ancestor = ancestor?.superview
            }
            guard let map = foundMap else { return }
            // Attach. UIScrollView still observes the recognizer's state internally
            // and updates contentOffset accordingly, even though the recognizer now
            // lives on MKMapView's view tree.
            map.addGestureRecognizer(scrollView.panGestureRecognizer)
            attachedMapView = map
        }

        private static func findMapView(in view: UIView) -> MKMapView? {
            if let map = view as? MKMapView { return map }
            for sub in view.subviews {
                if let found = findMapView(in: sub) { return found }
            }
            return nil
        }

        // MARK: UIGestureRecognizerDelegate

        nonisolated func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            // Always allow simultaneous recognition with MKMapView's pan / pinch / rotate.
            return true
        }

        nonisolated func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            false
        }

        nonisolated func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            false
        }
    }
}

/// Host view for the hidden scroll view. Always passes touches through to whatever sits behind it
/// (the map). This guarantees the overlay can never block taps on pins, action buttons, or cards.
@available(iOS 26.0, *)
final class PassthroughHostView: UIView {
    weak var coordinator: MapAccessoryScrollDriver.Coordinator?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        coordinator?.attachIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        coordinator?.attachIfNeeded()
    }
}
