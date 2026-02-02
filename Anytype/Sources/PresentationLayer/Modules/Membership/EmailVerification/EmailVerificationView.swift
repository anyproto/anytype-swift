import SwiftUI
import Services


struct EmailVerificationView: View {
    @StateObject var model: EmailVerificationViewModel
    
    @State private var textFocused = true
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(email: Binding<String>, onSuccessfulValidation: @escaping () -> ()) {
        _model = StateObject(
            wrappedValue: EmailVerificationViewModel(email: email, onSuccessfulValidation: onSuccessfulValidation)
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(118)
            AnytypeText(Loc.Membership.emailValidation, style: .bodySemibold)
                .foregroundStyle(Color.Text.primary)
            Spacer.fixedHeight(44)
            textInput
            Spacer.fixedHeight(7)
            AnytypeText(model.error, style: .relation2Regular)
                .foregroundStyle(Color.Pure.red)
            Spacer()
            resend
            Spacer.fixedHeight(30)
        }
        .padding(.horizontal, 20)
        .animation(.default, value: model.error)
        .animation(.default, value: model.loading)
        
        .onChange(of: model.text) {
            model.onTextChange()
        }
        .onReceive(timer) { time in
            if model.timeRemaining > 0 {
                model.timeRemaining -= 1
            }
        }
    }
    
    var resend: some View {
        StandardButton(
            model.timeRemaining > 0 ?   Loc.resendIn(model.timeRemaining) : Loc.resend,
            inProgress: model.loading,
            style: .borderlessLarge
        ) {
            model.resendEmail()
        }.disabled(model.timeRemaining > 0)
    }
    
    var textInput: some View {
        ZStack {
            Button {
                textFocused.toggle()
            } label: {
                HStack(spacing: 8) {
                    numberView(number: model.number1)
                    numberView(number: model.number2)
                    numberView(number: model.number3)
                    numberView(number: model.number4)
                }
                .fixTappableArea()
            }
            .buttonStyle(.plain)
            .overlay {
                TextField("", text: $model.text)
                    .focused($textFocused)
                    .textContentType(.oneTimeCode)
                    .keyboardType(.numberPad)
                    .foregroundStyle(Color.clear)
                    .accentColor(.clear)
                    .background(Color.clear)
                    .frame(width: 0, height: 0)
            }
        }
    }
    
    private func numberView(number: String) -> some View {
        AnytypeText(number, style: .title)
            .foregroundStyle(Color.Text.primary)
            .frame(width: 48, height: 64)
            .border(7, color: .Shape.primary, lineWidth: 1)
    }
}

#Preview {
    VStack {
        EmailVerificationView(email: .constant(""), onSuccessfulValidation: {})
    }
}
