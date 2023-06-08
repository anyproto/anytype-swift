import SwiftUI

struct JoinFlowView: View {
    
    @ObservedObject var model: JoinFlowViewModel
    @Environment(\.presentationMode) @Binding private var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            Spacer.fixedHeight(180)
            
            model.content()
                .transition(model.forward ? .moveAndFadeForward: .moveAndFadeBack)
            
            Spacer.fixedHeight(14)
        }
        .navigationBarHidden(true)
        .background(TransparentBackground())
        .padding(.horizontal, 16)
    }
    
    private var navigationBar : some View {
        HStack {
            backButton
            Spacer()
            counter
        }
    }
    
    private var backButton : some View {
        Button(action: {
            if model.step.first {
                presentationMode.dismiss()
            } else {
                model.onBack()
            }
        }) {
            Image(asset: .backArrow)
                .foregroundColor(.Text.tertiary)
        }
    }
    
    private var counter : some View {
        AnytypeText(model.counter, style: .authBoby, color: .Text.tertiary)
    }
}


struct JoinFlowView_Previews : PreviewProvider {
    static var previews: some View {
        JoinFlowView(model: JoinFlowViewModel(output: nil))
    }
}
