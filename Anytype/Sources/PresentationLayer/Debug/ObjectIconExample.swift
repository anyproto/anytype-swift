import SwiftUI

struct ObjectIconExample: View {
    
    private let emojiExamples: [CGFloat] = [16, 18, 40, 48, 64, 80, 96]
    private let iconId = "bafybeiat4rk32gloscasl2pv5kevxl6zvlojw22aijxqj5tyqqr3l5vgii"
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: "Icons")
            ScrollView {
                VStack(spacing: 20) {
                    AnytypeText("Profile Icon", style: .subheading, color: .Text.primary)
                    demoBlock { CircleImageIdView(imageId: iconId) }
                    AnytypeText("Profile Char", style: .subheading, color: .Text.primary)
                    demoBlock { CircleCharIconView(text: "ABC") }
                    AnytypeText("Emoji", style: .subheading, color: .Text.primary)
                    demoBlock { EmojiIconView(text: "😀") }
                }
            }
        }
    }
    
    @ViewBuilder
    private func demoBlock(@ViewBuilder content: @escaping () -> some View) -> some View {
        ForEach(0..<emojiExamples.count, id: \.self) { index in
            let size = emojiExamples[index]
            AnytypeText("Size \(size)", style: .bodyRegular, color: .Text.primary)
            HStack(spacing: 0) {
                HStack {
                    Spacer()
                    content()
                        .frame(width: size, height: size)
                    Spacer()
                }
                .padding(10)
                .background(Color.white)
                .colorScheme(.light)
                HStack {
                    Spacer()
                    content()
                        .frame(width: size, height: size)
                    Spacer()
                }
                .padding(10)
                .background(Color.black)
                .colorScheme(.dark)
            }
            .padding(.bottom, 10)
            .newDivider()
        }
    }
}

struct ObjectIconExample_Previews: PreviewProvider {
    static var previews: some View {
        ColorsExample()
    }
}
