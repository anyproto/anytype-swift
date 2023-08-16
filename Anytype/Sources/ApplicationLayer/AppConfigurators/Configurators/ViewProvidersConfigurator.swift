import Foundation
import UIKit

final class ViewProvidersConfigurator: AppConfiguratorProtocol {

    func configure() {
        NSTextAttachment.registerViewProviderClass(IconTextAttachmentViewProvider.self, forFileType: "com.anytype.mention")
    }
}
