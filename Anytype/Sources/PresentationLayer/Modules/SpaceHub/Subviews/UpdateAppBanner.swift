import SwiftUI
import DesignKit

struct UpdateAppBanner: View {
    
    @StateObject private var model = UpdateAppBannerModel()
    
    var body: some View {
        VStack(spacing: 12) {
            Text(model.text)
        }
        .padding(16)
        .background {
            LinearGradient(
                colors: [
                    Color(light: Color(hex: "#FEE7E0"), dark: Color(hex: "#74321E")),
                    Color(light: Color(hex: "#FFF6F3"), dark: Color(hex: "#4B251A"))
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
}

final class UpdateAppBannerModel: ObservableObject {
    
    let text: AttributedString
    
    init() {
        var title = AttributedString("iOS 16 Support Ends Soon\n")
        title.font = AnytypeFontBuilder.font(anytypeFont: .uxTitle2Regular).bold()
        
        var description = AttributedString("We’re ending iOS 16 support to improve performance & features. Update to iOS 17+ to keep getting updates. Can’t upgrade and have a membership? ")
        description.font = AnytypeFontBuilder.font(anytypeFont: .uxTitle2Regular)
        
        var link = AttributedString("Request a refund.")
        link.link = URL(string: "mailto:care@anytype.io")
        link.underlineStyle = .single
        link.font = AnytypeFontBuilder.font(anytypeFont: .uxTitle2Regular)
        
        var text = title + description + link
        text.foregroundColor = .Text.primary
        self.text = text
    }
}
