import SwiftUI
import MapKit

struct FindView: View {
    @Bindable var viewModel: ListingsViewModel
    var zoomNamespace: Namespace.ID
    let isActive: Bool
    let onListingTap: (Listing) -> Void

    var body: some View {
        Group {
            if viewModel.showListView {
                FindListView(viewModel: viewModel, zoomNamespace: zoomNamespace, onListingTap: onListingTap)
            } else {
                FindMapView(viewModel: viewModel, zoomNamespace: zoomNamespace, onListingTap: onListingTap)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isActive {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.dismissOverlay()
                        viewModel.showListView.toggle()
                    } label: {
                        Image(systemName: viewModel.showListView ? "map" : "list.bullet")
                            .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    }
                }
                if viewModel.showListView {
                    ToolbarItem(placement: .topBarTrailing) {
                        sortMenu
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    }
                }
            }
        }
    }

    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    viewModel.sortOption = option
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if viewModel.sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: Theme.IconSize.medium, weight: .semibold))
        }
    }

}
