import SwiftUI

struct TourSchedulerWidget: View {
    let tourRequest: TourRequest

    @State private var currentStep: Int = 0
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 10
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    @State private var fullName: String = ""
    @State private var phone: String = ""
    @State private var isConfirmed: Bool = false

    nonisolated private enum Field { case name, phone }
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView

            if isConfirmed {
                confirmationView
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                stepsView
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal, 16)
        .animation(.snappy(duration: 0.35), value: currentStep)
        .animation(.snappy(duration: 0.35), value: isConfirmed)
    }

    private var headerView: some View {
        HStack(spacing: 10) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: Theme.IconSize.medium, weight: .semibold))
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

            Spacer()
        }
        .padding(16)
    }

    private var stepsView: some View {
        VStack(spacing: 8) {
            stepRow(
                index: 0,
                title: "Pick a day",
                summary: selectedDate.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()),
                content: { dayPickerContent }
            )

            Divider().padding(.leading, 48)

            stepRow(
                index: 1,
                title: "Pick a time",
                summary: selectedTime.formatted(date: .omitted, time: .shortened),
                content: { timePickerContent }
            )

            Divider().padding(.leading, 48)

            stepRow(
                index: 2,
                title: "Your info",
                summary: fullName,
                content: { contactContent }
            )
        }
    }

    private func stepRow<Content: View>(
        index: Int,
        title: String,
        summary: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                if index < currentStep {
                    currentStep = index
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            } label: {
                HStack(spacing: 12) {
                    stepIndicator(for: index)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline.weight(currentStep == index ? .semibold : .regular))
                            .foregroundStyle(index <= currentStep ? .primary : .tertiary)

                        if index < currentStep {
                            Text(summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    if index < currentStep {
                        Image(systemName: "chevron.down")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(index > currentStep)

            if currentStep == index {
                content()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func stepIndicator(for index: Int) -> some View {
        ZStack {
            if index < currentStep {
                Circle()
                    .fill(Theme.redfinGreenColor)
                    .frame(width: 24, height: 24)
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
            } else if index == currentStep {
                Circle()
                    .fill(Color.primary)
                    .frame(width: 24, height: 24)
                Text("\(index + 1)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(.systemBackground))
            } else {
                Circle()
                    .strokeBorder(Color(.tertiaryLabel), lineWidth: 1.5)
                    .frame(width: 24, height: 24)
                Text("\(index + 1)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var dayPickerContent: some View {
        VStack(spacing: 12) {
            DatePicker(
                "Select date",
                selection: $selectedDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()

            continueButton { advanceStep() }
        }
    }

    private var timePickerContent: some View {
        VStack(spacing: 12) {
            DatePicker(
                "Select time",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(height: 150)

            continueButton { advanceStep() }
        }
    }

    private var contactContent: some View {
        VStack(spacing: 12) {
            TextField("Full name", text: $fullName)
                .textFieldStyle(.roundedBorder)
                .font(.subheadline)
                .textContentType(.name)
                .submitLabel(.next)
                .focused($focusedField, equals: .name)
                .onSubmit { focusedField = .phone }
                .onChange(of: fullName) { oldValue, newValue in
                    if oldValue.isEmpty && newValue.count > 1 {
                        focusedField = .phone
                    }
                }

            TextField("Phone number", text: $phone)
                .textFieldStyle(.roundedBorder)
                .font(.subheadline)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .submitLabel(.done)
                .focused($focusedField, equals: .phone)
                .onSubmit { focusedField = nil }

            Button {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                isConfirmed = true
            } label: {
                Text("Request Tour")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color(.systemBackground))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(canSubmit ? Color.primary : Color.gray, in: Capsule())
            }
            .disabled(!canSubmit)
        }
    }

    private var confirmationView: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(Theme.redfinGreenColor)

            VStack(alignment: .leading, spacing: 3) {
                Text("Tour Requested")
                    .font(.subheadline.bold())
                Text("\(selectedDate.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())) at \(selectedTime.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("We'll confirm your tour shortly.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private func continueButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("Continue")
                .font(.subheadline.bold())
                .foregroundStyle(Color(.systemBackground))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.primary, in: Capsule())
        }
    }

    private func advanceStep() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        currentStep += 1
    }

    private var canSubmit: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phone.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
