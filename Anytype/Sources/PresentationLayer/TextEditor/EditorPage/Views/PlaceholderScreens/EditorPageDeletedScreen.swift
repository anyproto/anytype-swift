import UIKit

final class EditorPageDeletedScreen: UIView {
    private lazy var text = buildText()
    private lazy var ghost = buildGhost()
    private lazy var backButton = buildBackButton()
    
    private let onBackTap: () -> ()
    
    init(onBackTap: @escaping () -> ()) {
        self.onBackTap = onBackTap
        super.init(frame: .zero)
        setup()
    }
    
    private func setup() {
        backgroundColor = .Background.primary
        
        addSubview(ghost) {
            $0.center(in: self)
        }
        addSubview(text) {
            $0.pinToSuperview(excluding: [.top, .bottom])
            $0.top.equal(to: ghost.bottomAnchor, constant: 40)
        }
        addSubview(backButton) {
            $0.centerX.equal(to: centerXAnchor)
            $0.top.equal(to: text.bottomAnchor, constant: 27)
        }
    }
    // MARK: - Views
    private func buildText() -> AnytypeLabel {
        let view = AnytypeLabel(style: .heading)
        view.setText(Loc.thisObjectDoesnTExist)
        view.textColor = .Text.primary
        view.textAlignment = .center
        return view
    }

    private func buildGhost() -> UIImageView {
        let view = UIImageView(asset: .TextEditor.bigGhost)
        view.addTapGesture { [weak view] _ in
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            view?.spookyShake()
        }
        return view
    }
    
    private func buildBackButton() -> UIButton {
        let button = UIButton(
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    UISelectionFeedbackGenerator().selectionChanged()
                    self?.onBackTap()
                }
            )
        )
        button.setTitle(Loc.goBack, for: .normal)
        button.setTitleColor(.Text.primary, for: .normal)
        button.titleLabel?.font = .uxBodyRegular
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        
        button.dynamicBorderColor = UIColor.Stroke.primary
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        
        return button
    }
    
    // MARK: - Unavailable
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
