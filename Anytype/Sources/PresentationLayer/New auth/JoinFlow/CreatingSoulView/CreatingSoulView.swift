import SwiftUI

struct CreatingSoulView: View {
    
    @ObservedObject var model: CreatingSoulViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            AnytypeText(Loc.Auth.JoinFlow.Creating.Soul.title, style: .uxTitle1Semibold, color: .Text.primary)
                .opacity(0.9)
            
            Spacer.fixedHeight(64)

            HStack {
                soul
                space
            }
        }
    }
    
    private var soul: some View {
        VStack(spacing: 8) {
            AnytypeText(model.state.soul, style: .previewTitle2Medium, color: .Text.primary)
        }
    }
    
    private var space: some View {
        VStack(spacing: 8) {
            AnytypeText(Loc.Auth.JoinFlow.Personal.Space.title, style: .previewTitle2Medium, color: .Text.primary)
        }
    }
}


struct CreatingSoulView_Previews : PreviewProvider {
    static var previews: some View {
        CreatingSoulView(model: CreatingSoulViewModel(state: JoinFlowState(), output: nil))
    }
}
