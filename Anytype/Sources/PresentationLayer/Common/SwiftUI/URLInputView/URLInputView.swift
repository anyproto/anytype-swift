import SwiftUI

struct URLInputView: View {
    
    @State private var text = ""
    private let didCreateURL: (URL) -> Void
    var dismissAction: () -> Void = {}
    
    init(didCreateURL: @escaping (URL) -> Void) {
        self.didCreateURL = didCreateURL
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .center, spacing: 15) {
                TextField("Paste or type URL", text: $text)
                    .font(AnytypeFontBuilder.font(textStyle: .headline))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.URL)
                    .modifier(DividerModifier())
                HStack(spacing: 20, content: {
                    StandardButton(
                        text: "Cancel",
                        style: .secondary,
                        action: dismissAction
                    )
                    StandardButton(
                        disabled: !text.isValidURL(),
                        text: "Create",
                        style: .primary
                    ) {
                        guard let url = URL(string: text) else { return }
                        didCreateURL(url)
                        dismissAction()
                    }
                })
            }
            .padding(.bottom, 10)
            .padding(20)
            .background(Color.background)
            .cornerRadius(12, corners: [.topLeft, .topRight])
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct URLInputView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.pureAmber
            URLInputView(didCreateURL: { _ in })
        }
    }
}
