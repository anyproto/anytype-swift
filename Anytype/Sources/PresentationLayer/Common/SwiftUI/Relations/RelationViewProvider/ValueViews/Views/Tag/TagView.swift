import SwiftUI

struct TagView: View {
    let config: TagView.Config
    
    var body: some View {
        AnytypeText(config.text, style: config.textFont)
            .foregroundColor(config.textColor)
            .lineLimit(1)
            .padding(.horizontal, config.guidlines.textPadding)
            .background(config.backgroundColor)
            .cornerRadius(config.guidlines.cornerRadius)
            .if(config.backgroundColor == Color.VeryLight.default) {
                $0.overlay(
                    RoundedRectangle(cornerRadius: config.guidlines.cornerRadius)
                        .stroke(Color.Shape.primary, lineWidth: 1)
                )
            }
            .frame(height: config.guidlines.tagHeight)
    }
}

extension TagView {
    
    struct Config {
        let text: String
        let textColor: Color
        let backgroundColor: Color
        let textFont: AnytypeFont
        let guidlines: TagView.Guidlines
        
        static let `default` = TagView.Config(
            text: "Tag",
            textColor: Color.Dark.pink,
            backgroundColor: Color.VeryLight.pink,
            textFont: .bodyRegular,
            guidlines: TagView.Guidlines(textPadding: 5, cornerRadius: 6, tagHeight: 20)
        )
    }
    
    struct Guidlines: Hashable {
        let textPadding: CGFloat
        let cornerRadius: CGFloat
        let tagHeight: CGFloat
    }
}

#Preview {
    TagView(config: TagView.Config.default)
}
