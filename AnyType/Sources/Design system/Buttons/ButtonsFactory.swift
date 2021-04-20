
import UIKit

struct ButtonsFactory {
    
    private enum Constants {
        static let backButtonImageToTitlePadding: CGFloat = 10
    }
    
    func makeBackButton(action: @escaping() -> Void) -> UIButton {
        let backButton = UIButton(type: .system, primaryAction: UIAction { _ in
            action()
        })
        backButton.setAttributedTitle(NSAttributedString(string: "Back".localized,
                                                         attributes: [.font: UIFont.smallBodyFont]),
                                      for: .normal)
        backButton.setImage(.back, for: .normal)
        backButton.setImageAndTitleSpacing(Constants.backButtonImageToTitlePadding)
        backButton.tintColor = .secondaryTextColor
        return backButton
    }
}
