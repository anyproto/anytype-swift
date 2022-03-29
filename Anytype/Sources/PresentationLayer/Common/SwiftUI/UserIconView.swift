import SwiftUI
import UIKit
import Kingfisher
import SwiftUIVisualEffects

extension UserIconView {
    
    enum IconType {
        case image(id: String)
        case placeholder(Character?)
    }
}

struct UserIconView: View {
    
    let icon: IconType
    
    var body: some View {
        Group {
            switch icon {
            case let .image(id):
                imageIcon(id)
            case let .placeholder(character):
                placeholderIcon(character)
            }
        }
        .frame(width: Constants.size.width, height: Constants.size.height)
        
    }
    
    private func imageIcon(_ imageId: String) -> some View {
        KFImage
            .url(
                ImageMetadata(id: imageId, width: Constants.size.width.asImageWidth)
                    .downloadingUrl
            )
            .setProcessors(
                [
                    KFProcessorBuilder(
                        scalingType: .resizing(.aspectFill),
                        targetSize: Constants.size,
                        cornerRadius: .widthFraction(0.5)
                    ).processor
                ]
            )
            .placeholder({
                placeholderIcon(nil)
            })
            .fade(duration: 0.25)
    }
    
    private func placeholderIcon(_ character: Character?) -> some View {
        AnytypeText(
            character.flatMap { String($0) } ?? "",
            name: .inter,
            size: 45,
            weight: .regular
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.textPrimary)
        .padding(.top, 2)
        .vibrancyEffect()
        .vibrancyEffectStyle(.separator)
        .background(BlurEffect())
        .blurEffectStyle(.systemMaterial)
        .clipShape(Circle())
            
    }
    
}

extension UserIconView {
    
    enum Constants {
        static let size = CGSize(width: 80, height: 80)
    }
    
}


struct SimpleViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            UserIconView(
                icon: .placeholder("A")
            )
            .frame(width: 100, height: 100)
        }
        .previewLayout(.sizeThatFits)
    }
}
