import SwiftUI

struct ColorsExample: View {
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: "Colors")
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(UIColor.anytypeAssetsInfo.reversed(), id: \.name) { asset in
                        ForEach(asset.collections, id: \.name) { collection in
                            AnytypeText(collection.name, style: .subheading)
                                .foregroundStyle(Color.Text.primary)
                            colors(collection: collection)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func colors(collection: ColorCollectionInfo) -> some View {
        ForEach(collection.colors, id: \.name) { colorInfo in
            AnytypeText(colorInfo.name, style: .bodyRegular)
                .foregroundStyle(Color.Text.primary)
            HStack(spacing: 0) {
                HStack {
                    Spacer()
                    VStack {
                        Circle()
                            .strokeBorder(Color.Shape.primary, lineWidth: 1)
                            .background(Circle().foregroundStyle(Color(colorInfo.color.suColor)))
                            .frame(width: 100, height: 100)
                        AnytypeText(colorCode(color: colorInfo.color.light), style: .caption2Medium)
                            .foregroundStyle(Color.Text.primary)
                    }
                    Spacer()
                }
                .padding(20)
                .background(Color.white)
                .colorScheme(.light)
                HStack {
                    Spacer()
                    VStack {
                        Circle()
                            .strokeBorder(Color.Shape.primary, lineWidth: 1)
                            .background(Circle().foregroundStyle(Color(colorInfo.color.suColor)))
                            .frame(width: 100, height: 100)
                        AnytypeText(colorCode(color: colorInfo.color.dark), style: .caption2Medium)
                            .foregroundStyle(Color.Text.primary)
                    }
                    Spacer()
                }
                .padding(20)
                .background(Color.black)
                .colorScheme(.dark)
            }
            .padding(.bottom, 10)
            .newDivider()
        }
    }
    
    private func colorCode(color: UIColor) -> String {
        if color.cgColor.alpha < 1 {
            return "\(color.hexString) \(Int((color.cgColor.alpha*100).rounded()))%"
        } else {
            return color.hexString
        }
    }
}

struct ColorsExample_Previews: PreviewProvider {
    static var previews: some View {
        ColorsExample()
    }
}
