import SwiftUI

struct KeyPhraseMoreInfoView: View {
    
    var body: some View {
        VStack(spacing: 20) {
            DragIndicator()
            ScrollView(.vertical, showsIndicators: false) {
                content
            }
        }
        .padding(.horizontal, 24)
        .background(Color.Background.secondary)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(26)
            
            AnytypeText(Loc.Auth.JoinFlow.Key.ReadMore.title, style: .contentTitleSemibold)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            
            Spacer.fixedHeight(24)
            
            optionsRows
        }
    }
    
    private var optionsRows: some View {
        VStack(alignment: .leading, spacing: 24) {
            optionRow(icon: .Auth.joinFlowIcon1, title: Loc.Auth.JoinFlow.Key.ReadMore.Option1.title, description: Loc.Auth.JoinFlow.Key.ReadMore.Option1.description)
            optionRow(icon: .Auth.joinFlowIcon2, title: Loc.Auth.JoinFlow.Key.ReadMore.Option2.title, description: Loc.Auth.JoinFlow.Key.ReadMore.Option2.description)
            optionRow(icon: .Auth.joinFlowIcon3, title: Loc.Auth.JoinFlow.Key.ReadMore.Option3.title, description: Loc.Auth.JoinFlow.Key.ReadMore.Option3.description)
        }
    }
    
    private func optionRow(icon: ImageAsset, title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            IconView(asset: icon).frame(width: 56, height: 56)
            Spacer.fixedHeight(12)
            AnytypeText(title, style: .bodySemibold)
            Spacer.fixedHeight(4)
            AnytypeText(description, style: .bodyRegular)
                .foregroundColor(.Text.secondary)
        }
    }
}


struct KeyPhraseMoreInfoView_Previews : PreviewProvider {
    static var previews: some View {
        KeyPhraseMoreInfoView()
    }
}
