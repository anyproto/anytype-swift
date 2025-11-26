import UIKit
import SwiftUI
import AnytypeCore

final class TemplateEditingViewController: UIViewController {
    private let titleLabel = UILabel()
    private let settingsButton = UIButton()
    private let editorViewController: UIViewController
    private let onSettingsTap: () -> Void
    private let onSelectTemplateTap: (() -> Void)?
    private let objectId: String
    private let spaceId: String
    private weak var output: (any ObjectSettingsCoordinatorOutput)?
    private var settingsMenuView: UIView?
    
    private lazy var keyboardHelper = KeyboardEventsListnerHelper(
        didShowAction: { [weak selectTemplateButton] _ in
            selectTemplateButton?.isHidden = true
        }, willHideAction: { [weak selectTemplateButton] _ in
            selectTemplateButton?.isHidden = false
        }
    )
    private lazy var selectTemplateButton: UIView = {
        StandardButton(
            Loc.TemplateSelection.selectTemplate,
            style: .primaryLarge,
            action: { [weak self] in
                self?.onSelectTemplateTap?()
            }
        ).asUIView()
    }()
    
    private lazy var settingsNavigationButton = UIBarButtonItem(
        image: .init(asset: .X24.more),
        style: .plain,
        target: self,
        action: #selector(didTapSettingButton)
    )
    
    init(
        editorViewController: UIViewController,
        objectId: String,
        spaceId: String,
        output: any ObjectSettingsCoordinatorOutput,
        onSettingsTap: @escaping () -> Void,
        onSelectTemplateTap: (() -> Void)?
    ) {
        self.editorViewController = editorViewController
        self.objectId = objectId
        self.spaceId = spaceId
        self.output = output
        self.onSettingsTap = onSettingsTap
        self.onSelectTemplateTap = onSelectTemplateTap
        
        super.init(nibName: nil, bundle: nil)
        
        _ = keyboardHelper
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupView()
        setupLayout()
    }
    
    @objc
    private func didTapSettingButton() {
        onSettingsTap()
    }
    
    private func setupView() {
        view.backgroundColor = .Background.primary
        
        titleLabel.text = Loc.TemplateEditing.title
        titleLabel.font = .uxTitle2Medium
        titleLabel.textColor = .Text.primary
        
        settingsButton.setImage(UIImage(asset: .X24.more), for: .normal)
        settingsButton.addTarget(self, action: #selector(didTapSettingButton), for: .touchUpInside)
        settingsButton.tintColor = .Control.secondary

        if FeatureFlags.newObjectSettings, let output {
            let menuContainer = ObjectSettingsMenuContainer(objectId: objectId, spaceId: spaceId, output: output)
            let hostingController = UIHostingController(rootView: menuContainer)
            hostingController.view.backgroundColor = .clear
            self.settingsMenuView = hostingController.view
        }
    }
    
    private func setupLayout() {
        let fakeNavigationView = UIView()
        fakeNavigationView.backgroundColor = .Background.primary
        view.addSubview(fakeNavigationView) {
            $0.pin(to: view, excluding: [.bottom, .top])
            $0.top.equal(to: view.topAnchor, constant: 8)
            $0.height.equal(to: 48)
        }
        
        fakeNavigationView.addSubview(titleLabel) {
            $0.centerX.equal(to: fakeNavigationView.centerXAnchor)
            $0.centerY.equal(to: fakeNavigationView.centerYAnchor)
        }
        
        if FeatureFlags.newObjectSettings, let settingsMenuView {
            fakeNavigationView.addSubview(settingsMenuView) {
                $0.trailing.equal(to: fakeNavigationView.trailingAnchor, constant: -20)
                $0.centerY.equal(to: fakeNavigationView.centerYAnchor)
            }
        } else {
            fakeNavigationView.addSubview(settingsButton) {
                $0.trailing.equal(to: fakeNavigationView.trailingAnchor, constant: -20)
                $0.centerY.equal(to: fakeNavigationView.centerYAnchor)
            }
        }

        embedChild(editorViewController, into: view)
        editorViewController.view.layoutUsing.anchors {
            $0.pinToSuperview(excluding: [.top, .bottom])
            $0.bottom.equal(to: view.bottomAnchor)
            $0.top.equal(to: fakeNavigationView.bottomAnchor)
        }
        
        if onSelectTemplateTap.isNotNil {
            view.addSubview(selectTemplateButton) {
                $0.pinToSuperview(
                    excluding: [.top],
                    insets: .init(
                        top: 0,
                        left: 20,
                        bottom: view.safeAreaInsets.bottom + 35,
                        right: 20
                    )
                )
                $0.height.equal(to: StandardButtonStyle.primaryLarge.config.height)
            }
        }
    }
}
