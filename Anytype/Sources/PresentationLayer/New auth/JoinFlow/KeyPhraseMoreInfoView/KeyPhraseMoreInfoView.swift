import SwiftUI

struct KeyPhraseMoreInfoView: View {
    
    var body: some View {
        VStack(spacing: 20) {
            DragIndicator()
            
            ScrollView(.vertical, showsIndicators: false) {
                AnytypeText(Loc.Auth.JoinFlow.Key.MoreInfo.description, style: .bodyRegular, color: .Auth.inputText)
                Spacer.fixedHeight(16)
            }
        }
        .padding(.horizontal, 22)
        .background(Color.Auth.input)
        .preferredColorScheme(.dark)
    }
}


struct KeyPhraseMoreInfoView_Previews : PreviewProvider {
    static var previews: some View {
        KeyPhraseMoreInfoView()
    }
}
