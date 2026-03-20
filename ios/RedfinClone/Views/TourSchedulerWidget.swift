import SwiftUI

struct TourSchedulerWidget: View {
    let tourRequest: TourRequest
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 10
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phone: String = ""
    @State private var agreedToTerms: Bool = false
    @State private var isSubmitted: Bool = false
    @State private var showContact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView

            if isSubmitted {
                confirmationView
            } else {
                formContent
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

    private var headerView: some View {
        HStack(spacing: 10) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Schedule a Tour")
                    .font(.headline)
                if let address = tourRequest.address {
                    Text(address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
    }

    private var formContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Date & Time")
                    .font(.subheadline.bold())

                DatePicker("Date", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
            }

            if !showContact {
                Button {
                    withAnimation(.snappy(duration: 0.2)) { showContact = true }
                } label: {
                    Text("Continue")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                }
            }

            if showContact {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your info")
                        .font(.subheadline.bold())

                    TextField("First name", text: $firstName)
                        .textFieldStyle(.roundedBorder)
                        .font(.subheadline)

                    TextField("Last name", text: $lastName)
                        .textFieldStyle(.roundedBorder)
                        .font(.subheadline)

                    TextField("Phone number", text: $phone)
                        .textFieldStyle(.roundedBorder)
                        .font(.subheadline)
                        .keyboardType(.phonePad)

                    Toggle("I agree to be contacted about this tour", isOn: $agreedToTerms)
                        .font(.caption)

                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isSubmitted = true
                        }
                    } label: {
                        Text("Request Tour")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(canSubmit ? Color(white: 0.15) : Color.gray, in: .rect(cornerRadius: 10))
                    }
                    .disabled(!canSubmit)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
    }

    private var confirmationView: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Theme.redfinGreenColor)

            VStack(alignment: .leading, spacing: 4) {
                Text("Tour Requested!")
                    .font(.headline)
                Text("\(selectedDate.formatted(date: .abbreviated, time: .omitted)) at \(selectedTime.formatted(date: .omitted, time: .shortened))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("We'll confirm your tour shortly.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .transition(.scale.combined(with: .opacity))
    }

    private var canSubmit: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phone.trimmingCharacters(in: .whitespaces).isEmpty &&
        agreedToTerms
    }
}
