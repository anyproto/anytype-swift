import SwiftUI

struct GradientIconsExamples: View {
    
    private let gradients = IconGradientStorage().allGradients()
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: "Gradient Icons")
            content
        }
        .background(Color.Background.primary)
    }
    
    @ViewBuilder
    private var content: some View {
        VStack {
            HStack(spacing: 0) {
                AnytypeText("Space", style: .subheading, color: .Text.primary)
                    .frame(maxWidth: .infinity)
                AnytypeText("Profile", style: .subheading, color: .Text.primary)
                    .frame(maxWidth: .infinity)
            }
            ScrollView() {
                VStack {
                    ForEach(0..<gradients.count, id: \.self) { index in
                        if let gradientId = GradientId(index + 1) {
                            AnytypeText("Gradient \(gradientId.rawValue)", style: .bodyRegular, color: .Text.primary)
                            HStack(spacing: 0) {
                                IconView(icon: .object(.space(.gradient(gradientId))))
                                    .frame(width: 96, height: 96)
                                IconView(icon: .object(.profile(.gradient(gradientId))))
                                    .frame(width: 96, height: 96)
                            }
                            .padding(.bottom, 12)
                            .newDivider()
                        }
                    }
                }
            }
        }
    }
}

struct GradientIconsExamples_Previews: PreviewProvider {
    static var previews: some View {
        GradientIconsExamples()
    }
}
