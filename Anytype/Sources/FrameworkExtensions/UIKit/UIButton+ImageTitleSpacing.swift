import UIKit

extension UIButton {

    func setImageAndTitleSpacing(_ spacing: CGFloat) {
        var configuration = self.configuration
        let isRTL = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        
        configuration?.imagePadding = spacing
        configuration?.contentInsets = .init(
            top: 0,
            leading: spacing / 2,
            bottom: 0,
            trailing: spacing / 2
        )
        
        if isRTL {
            configuration?.imagePlacement = .trailing
        } else {
            configuration?.imagePlacement = .leading
        }
        
        self.configuration = configuration
    }
}
