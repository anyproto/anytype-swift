import SwiftUI

struct TitleView: View {
    
    let title: String?
    
    var body: some View {
        if let title = title {
            AnytypeText(title, style: .uxTitle1Semibold, color: .TextNew.primary)
                .frame(height: 48)
        }
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView(title: "title")
    }
}
