import SwiftUI
import AnytypeCore

struct FramedTextField<LeadingView: View>: View {

    private let title: String?
    private let placeholder: String
    private let axis: Axis
    private let shouldFocus: Bool
    private let leadingView: () -> LeadingView

    @Binding private var text: String

    init(
        title: String? = nil,
        placeholder: String,
        axis: Axis = .horizontal,
        shouldFocus: Bool = true,
        text: Binding<String>,
        leadingView: @escaping () -> LeadingView = { EmptyView() }
    ) {
        self.title = title
        self.placeholder = placeholder
        self.axis = axis
        self.shouldFocus = shouldFocus
        self._text = text
        self.leadingView = leadingView
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title {
                AnytypeText(title, style: .uxCalloutRegular)
                    .foregroundColor(.Text.secondary)
            }

            HStack(alignment: .center, spacing: 8) {
                leadingView()

                if shouldFocus {
                    AutofocusedTextField(
                        placeholder: placeholder,
                        font: .bodyRegular,
                        axis: axis,
                        text: $text
                    )
                    .autocorrectionDisabled()
                } else {
                    AnytypeTextField(
                        placeholder: placeholder,
                        font: .bodyRegular,
                        axis: axis,
                        text: $text
                    )
                    .autocorrectionDisabled()
                }

                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.Shape.transperentSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(Color.Shape.transperentSecondary, lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        FramedTextField(
            title: "Name",
            placeholder: "Untitled",
            text: .constant("My name")
        )

        FramedTextField(
            placeholder: "Enter value...",
            text: .constant("")
        )

        FramedTextField(
            title: "Name",
            placeholder: "eg. Project",
            text: .constant(""),
            leadingView: {
                IconView(icon: .object(.emoji(Emoji("🍆")!)))
                    .frame(width: 32, height: 32)
            }
        )
    }
    .padding()
}
