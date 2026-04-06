import SwiftUI

extension View {
    @ViewBuilder
    func adaptiveGlass(in shape: some Shape = .capsule) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(in: AnyShape(shape))
        } else {
            self.background(shape.fill(.ultraThinMaterial))
        }
    }

    @ViewBuilder
    func adaptiveGlassInteractive(in shape: some Shape = .capsule) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive(), in: AnyShape(shape))
        } else {
            self.background(shape.fill(.ultraThinMaterial))
        }
    }

    @ViewBuilder
    func adaptiveGlassCircle() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(in: .circle)
        } else {
            self.background(.ultraThinMaterial, in: Circle())
        }
    }

    @ViewBuilder
    func adaptiveGlassCircleInteractive() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive(), in: .circle)
        } else {
            self.background(.ultraThinMaterial, in: Circle())
        }
    }

    @ViewBuilder
    func adaptiveGlassBar() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(in: .rect(cornerRadius: 0))
        } else {
            self.background(.ultraThinMaterial)
        }
    }

    @ViewBuilder
    func adaptiveGlassSegment() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(in: .capsule)
        } else {
            self.background(.ultraThinMaterial, in: .capsule)
        }
    }
}
