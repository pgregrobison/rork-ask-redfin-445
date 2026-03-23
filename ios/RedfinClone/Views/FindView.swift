import SwiftUI
import MapKit

struct FindView: View {
    @Bindable var viewModel: ListingsViewModel
    let onListingTap: (Listing) -> Void

    var body: some View {
        Group {
            if viewModel.showListView {
                FindListView(viewModel: viewModel, onListingTap: onListingTap)
            } else {
                FindMapView(viewModel: viewModel, onListingTap: onListingTap)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 4) {
                    Button {
                        viewModel.showListView.toggle()
                    } label: {
                        Image(systemName: viewModel.showListView ? "map" : "list.bullet")
                            .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                            .contentTransition(.symbolEffect(.replace))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }

                    Button {} label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                }
            }

            ToolbarItem(placement: .principal) {
                if viewModel.showListView {
                    VStack(spacing: 0) {
                        Text("\(viewModel.listings.count) homes")
                            .font(.headline)
                        Text(viewModel.locationName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text(viewModel.locationName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 14)
                        .frame(height: 44)
                        .adaptiveGlass(in: .capsule)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
                    if viewModel.showListView {
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
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                    }

                    Button {} label: {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                }
            }
        }
    }
}
