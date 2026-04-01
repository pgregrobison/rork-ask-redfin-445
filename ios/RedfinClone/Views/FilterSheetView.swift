import SwiftUI

struct FilterSheetView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var minBeds: Int = 0
    @State private var minBaths: Int = 0
    @State private var priceRange: ClosedRange<Double> = 0...5_000_000
    @State private var propertyType: String = "Any"

    private let propertyTypes = ["Any", "House", "Condo", "Townhouse", "Co-op", "Multi-family"]

    var body: some View {
        NavigationStack {
            List {
                Section("Bedrooms") {
                    Picker("Minimum Beds", selection: $minBeds) {
                        Text("Any").tag(0)
                        ForEach(1...5, id: \.self) { n in
                            Text("\(n)+").tag(n)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Bathrooms") {
                    Picker("Minimum Baths", selection: $minBaths) {
                        Text("Any").tag(0)
                        ForEach(1...4, id: \.self) { n in
                            Text("\(n)+").tag(n)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Price Range") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Up to")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(priceRange.upperBound, format: .currency(code: "USD").precision(.fractionLength(0)))
                                .fontWeight(.medium)
                        }
                        Slider(value: Binding(
                            get: { priceRange.upperBound },
                            set: { priceRange = priceRange.lowerBound...$0 }
                        ), in: 100_000...10_000_000, step: 100_000)
                    }
                }

                Section("Property Type") {
                    Picker("Type", selection: $propertyType) {
                        ForEach(propertyTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        minBeds = 0
                        minBaths = 0
                        priceRange = 0...5_000_000
                        propertyType = "Any"
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
