import SwiftUI
import AnytypeCore

struct GradientIconsExamples: View {
    
    private let allColors = IconColorStorage.allColors
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: "Space Icons")
            content
        }
        .background(Color.Background.primary)
    }
    
    @ViewBuilder
    private var content: some View {
        VStack {
            HStack(spacing: 0) {
                AnytypeText("Space", style: .subheading)
                    .foregroundColor(.Text.primary)
                    .frame(maxWidth: .infinity)
            }
            ScrollView() {
                VStack {
                    ForEach(0..<allColors.count, id: \.self) { index in
                        AnytypeText("Color \(index + 1)", style: .bodyRegular)
                            .foregroundColor(.Text.primary)
                        HStack(spacing: 0) {
                            Spacer()
                            IconView(icon: .object(.space(.name(name: "Design system", iconOption: index + 1, circular: false))))
                                .frame(width: 96, height: 96)
                            Spacer()
                        }
                        .padding(.bottom, 12)
                        .newDivider()
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
