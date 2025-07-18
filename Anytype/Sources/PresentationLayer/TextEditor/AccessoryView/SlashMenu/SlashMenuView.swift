import UIKit
import Services
import Combine

final class SlashMenuView: DismissableInputAccessoryView {
    private let viewModel: SlashMenuViewModel

    private var cancellables = [AnyCancellable]()
    
    init(frame: CGRect, viewModel: SlashMenuViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        
        setup()
    }
    
    private func setup() {
        addSubview(navigationController.view) {
            $0.pinToSuperview(excluding: [.top])
            $0.top.equal(to: topSeparator?.bottomAnchor ?? topAnchor)
        }
        
        viewModel.popToRootSubject.sink { [weak self] _ in
            self?.popTooRoot()
        }.store(in: &cancellables)
        
        viewModel.$detailsMenuItems.sink { [weak self] values in
            self?.controller.cellData = values
        }.store(in: &cancellables)
    }
    
    private func popTooRoot() {
        if controller.navigationController?.topViewController != controller {
            controller.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    // MARK: - Controllers
    private lazy var navigationController: UINavigationController = {
        let navigationController = BaseNavigationController(rootViewController: controller)
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.font: AnytypeFont.uxTitle2Medium.uiKitFont
        ]
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.shadowColor = .Background.primary
        navBarAppearance.backgroundColor = .Background.primary
        navBarAppearance.setBackIndicatorImage(UIImage(asset: .X18.slashMenuArrow), transitionMaskImage: UIImage(asset: .X18.slashMenuArrow))
        navigationController.modifyBarAppearance(navBarAppearance)
        navigationController.navigationBar.tintColor = .Control.secondary
        
        return navigationController
    }()
    
    private lazy var controller = SlashMenuAssembly
        .menuController(viewModel: viewModel, dismissHandler: dismissHandler)
}
