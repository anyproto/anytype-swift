import SwiftUI
import AnytypeCore

struct ObjectIconExample: View {
    
    private let emojiExamples: [CGFloat] = [16, 18, 40, 48, 64, 80, 96]
    private let iconId = "bafybeigly3yyhiyou5a2eb4kurd2l7kod6ex3ufvsin5snpqfevupztdam"
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: "Icons")
            ScrollView {
                VStack(spacing: 20) {
                    Group {
                        AnytypeText("Object Icon", style: .subheading, color: .Text.primary)
                        demoBlock { IconView(icon: .icon(.basic(iconId))) }
                        AnytypeText("Profile Icon", style: .subheading, color: .Text.primary)
                        demoBlock { IconView(icon: .icon(.profile(.imageId(iconId)))) }
                        AnytypeText("Profile Char", style: .subheading, color: .Text.primary)
                        demoBlock { IconView(icon: .icon(.profile(.character("AAAA".first!)))) }
                        AnytypeText("Profile Gradient", style: .subheading, color: .Text.primary)
                        demoBlock { IconView(icon: .icon(.profile(.gradient(GradientId(1)!)))) }
                    }
                    Group {
                        AnytypeText("Emoji", style: .subheading, color: .Text.primary)
                        demoBlock { IconView(icon: .icon(.emoji(Emoji("😀")!))) }
                        AnytypeText("Todo done", style: .subheading, color: .Text.primary)
                        demoBlock { IconView(icon: .todo(true)) }
                        AnytypeText("Todo empty", style: .subheading, color: .Text.primary)
                        demoBlock { IconView(icon: .todo(false)) }
                        AnytypeText("Space gradient", style: .subheading, color: .Text.primary)
                        demoBlock { IconView(icon: .icon(.space(.gradient(GradientId(2)!)))) }
                        AnytypeText("Space char", style: .subheading, color: .Text.primary)
                        demoBlock { IconView(icon: .icon(.space(.character("A".first!)))) }
                    }
                    
                    Group {
                        AnytypeText("Assets - active (copy example)", style: .subheading, color: .Text.primary)
                        demoBlock { IconView(icon: .imageAsset(.X32.copy)) }
                        AnytypeText("Assets - inactive (copy example)", style: .subheading, color: .Text.primary)
                        demoBlock { IconView(icon: .imageAsset(.X32.copy)).disabled(true) }
                    }
//                    Group {
//                        AnytypeText("Object Icon", style: .subheading, color: .Text.primary)
//                        demoBlock { SquareImageIdView(imageId: iconId) }
//                        AnytypeText("Profile Icon", style: .subheading, color: .Text.primary)
//                        demoBlock { CircleImageIdView(imageId: iconId) }
//                        AnytypeText("Profile Char", style: .subheading, color: .Text.primary)
//                        demoBlock { CircleCharIconView(text: "ABC") }
//                        AnytypeText("Profile Gradient", style: .subheading, color: .Text.primary)
//                        demoBlock { CircleGradientIconView(gradientId: GradientId(2)!) }
//                    }
//                    Group {
//                        AnytypeText("Emoji", style: .subheading, color: .Text.primary)
//                        demoBlock { EmojiIconView(text: "😀") }
//                        AnytypeText("Todo done", style: .subheading, color: .Text.primary)
//                        demoBlock { TodoIconView(checked: true) }
//                        AnytypeText("Todo empty", style: .subheading, color: .Text.primary)
//                        demoBlock { TodoIconView(checked: false) }
//                        AnytypeText("Space gradient", style: .subheading, color: .Text.primary)
//                        demoBlock { SquareGradientIconView(gradientId: GradientId(1)!) }
//                    }
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
