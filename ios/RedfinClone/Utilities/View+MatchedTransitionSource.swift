import SwiftUI

extension View {
    @ViewBuilder
    func matchedTransitionSourceIfAvailable(id: some Hashable, in namespace: Namespace.ID?) -> some View {
        if let namespace {
            self.matchedTransitionSource(id: id, in: namespace)
        } else {
            self
        }
    }
}
