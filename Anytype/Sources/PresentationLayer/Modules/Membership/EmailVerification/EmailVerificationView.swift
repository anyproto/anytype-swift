import SwiftUI


struct EmailVerificationView: View {
    @StateObject var model: EmailVerificationViewModel
    @State private var textFocused = true
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(118)
            AnytypeText(Loc.Membership.emailValidation, style: .bodySemibold, color: .Text.primary)
            Spacer.fixedHeight(44)
            textInput
            Spacer.fixedHeight(7)
            AnytypeText(model.error, style: .relation2Regular, color: .System.red)
            Spacer()
            
            if model.validating {
                DotsView()
                    .foregroundColor(.Text.secondary)
                    .frame(width: 50, height: 6)
            } else {
                Button {
                    // TODO
                } label: {
                    AnytypeText(Loc.resend, style: .previewTitle1Regular, color: .Text.secondary)
                }
            }
            
            
            
            Spacer.fixedHeight(30)
        }
        .padding(.horizontal, 20)
        .animation(.default, value: model.error)
        .animation(.default, value: model.validating)
        
        .onChange(of: model.text) { _ in
            model.onTextChange()
        }
    }
    
    var textInput: some View {
        ZStack {
            HStack (spacing: 8) {
                numberView(number: model.number1)
                numberView(number: model.number2)
                numberView(number: model.number3)
                numberView(number: model.number4)
            }
            .fixTappableArea()
            .onTapGesture {
                textFocused.toggle()
            }
            .overlay {
                TextField("", text: $model.text)
                    .focused($textFocused)
                    .textContentType(.oneTimeCode)
                    .keyboardType(.numberPad)
                
                    .foregroundColor(.clear)
                    .accentColor(.clear)
                    .background(Color.clear)
                    .frame(width: 0, height: 0)
            }
        }
    }
    
    private func numberView(number: String) -> some View {
        AnytypeText(number, style: .title, color: .Text.primary)
            .frame(width: 48, height: 64)
            .border(7, color: .Shape.primary, lineWidth: 1)
    }
}

#Preview {
    VStack {
        EmailVerificationView(
            model: EmailVerificationViewModel(
                membershipService: DI.preview.serviceLocator.membershipService()
            )
        )
    }
}
