import SwiftUI
import AnytypeCore

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
            }
            ScrollView() {
                VStack {
                    ForEach(0..<gradients.count, id: \.self) { index in
                        if let gradientId = GradientId(index + 1) {
                            AnytypeText("Gradient \(gradientId.rawValue)", style: .bodyRegular, color: .Text.primary)
                            HStack(spacing: 0) {
                                Spacer()
                                IconView(icon: .object(.space(.gradient(gradientId))))
                                    .frame(width: 96, height: 96)
                                Spacer()
                            }
                            .padding(.bottom, 12)
                            .newDivider()
                        }
                    }
                }
            }
        }
        .background(.gray)
    }
}

struct GradientIconsExamples_Previews: PreviewProvider {
    static var previews: some View {
        GradientIconsExamples()
    }
}
