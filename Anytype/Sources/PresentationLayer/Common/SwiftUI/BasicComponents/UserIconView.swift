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
    
    @Environment(\.redactionReasons) private var reasons
    
    let icon: IconType
    
    var body: some View {
        Group {
            if reasons.isEmpty {
                iconView
            } else {
                placeholderIcon(nil)
            }
        }
        .frame(width: Constants.size.width, height: Constants.size.height)
        
    }
    
    var iconView: some View {
        Group {
            switch icon {
            case let .image(id):
                imageIcon(id)
            case let .placeholder(character):
                placeholderIcon(character)
            }
        }
    }
    
    private func imageIcon(_ imageId: String) -> some View {
        KFImage
            .url(
                ImageMetadata(id: imageId, width: Constants.size.width)
                    .contentUrl
            )
            .setProcessors(
                [
                    KFProcessorBuilder(
                        imageGuideline: ImageGuideline(size: Constants.size, radius: .widthFraction(0.5)),
                        scalingType: .resizing(.aspectFill)
                    ).build()
                ]
            )
            .placeholder({
                placeholderIcon(nil)
            })
    }
    
    private func placeholderIcon(_ character: Character?) -> some View {
        AnytypeText(
            character.flatMap { String($0) } ?? "",
            name: .inter,
            size: 45,
            weight: .regular
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.Text.primary)
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
            
            UserIconView(
                icon: .placeholder("A")
            )
            .frame(width: 100, height: 100)
            .redacted(reason: .placeholder)
        }
        .previewLayout(.sizeThatFits)
    }
}
