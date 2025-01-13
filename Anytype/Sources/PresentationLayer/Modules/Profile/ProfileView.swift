import SwiftUI

struct ProfileView: View {
    @StateObject private var model: ProfileViewModel
    
    init() {
        _model = StateObject(wrappedValue: ProfileViewModel())
    }
    
    var body: some View {
        content
            .task { await model.setupSubscriptions() }
    }
    
    private var content: some View {
        VStack {
            DragIndicator()
            Spacer.fixedHeight(35)
            Circle().frame(width: 112).foregroundStyle(Color.System.pink)
            AnytypeText("Vova Ignatov", style: .heading)
            AnytypeText("vova.any", style: .caption1Regular)
            AnytypeText("Web3 activist growing a digital garden of knowledge for decentralization and digital rights. Sharing insights on blockchain, transparency, and open data.", style: .previewTitle2Regular)
            Spacer.fixedHeight(35)
            StandardButton("Edit Profile", style: .secondaryLarge) { }
            Spacer.fixedHeight(24)
        }
        .padding(.horizontal, 32)
        .background(Color.Background.secondary)
    }

}

#Preview {
    ProfileView()
}
