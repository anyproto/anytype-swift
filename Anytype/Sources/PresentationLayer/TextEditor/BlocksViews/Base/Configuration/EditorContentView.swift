import UIKit
import Services

final class EditorContentView<View: BlockContentView>: UIView & UIContentView, UIDragInteractionDelegate, ReusableContent {
    typealias Configuration = CellBlockConfiguration<View.Configuration>
    
    nonisolated static var reusableIdentifier: String { View.reusableIdentifier }

    var configuration: any UIContentConfiguration {
        get {
            Configuration(
                blockConfiguration: blockConfiguration,
                currentConfigurationState: currentConfigurationState,
                dragConfiguration: dragConfiguration,
                styleConfiguration: styleConfiguration
            )
        }
        set {
            contentConstraints?.update(with: blockConfiguration.contentInsets)
            
            guard let newConfiguration = newValue as? Configuration else { return }
            
            if newConfiguration.blockConfiguration != blockConfiguration {
                blockConfiguration = newConfiguration.blockConfiguration
            }
            
            if newConfiguration.currentConfigurationState != currentConfigurationState {
                currentConfigurationState = newConfiguration.currentConfigurationState
            }
    
            dragConfiguration = newConfiguration.dragConfiguration
            styleConfiguration = newConfiguration.styleConfiguration
            contentConstraints?.update(with: newConfiguration.blockConfiguration.contentInsets)
        }
    }
    
    private var blockConfiguration: View.Configuration {
        didSet {
            blockView.update(with: blockConfiguration)
        }
    }
   
    
    private var dragConfiguration: BlockDragConfiguration? {
        didSet {
            setupDragInteraction()
        }
    }
    
    private var styleConfiguration: CellStyleConfiguration? {
        didSet {
            backgroundColor = styleConfiguration?.backgroundColor
        }
    }
    
    private var currentConfigurationState: UICellConfigurationState? {
        didSet {
            currentConfigurationState.map {
                update(with: $0)
                blockView.update(with: $0)
            }
        }
    }
    
    private lazy var wrapperView = UIView()
    
    private lazy var contentStackView = UIView()
    private lazy var blockView = View(frame: .zero)
    private lazy var selectionView = EditorSelectionView()
    
    private var contentConstraints: InsetConstraints?
    
    private lazy var viewDragInteraction = UIDragInteraction(delegate: self)
    
    init(configuration: Configuration) {
        self.blockConfiguration = configuration.blockConfiguration
        self.currentConfigurationState = configuration.currentConfigurationState
        self.dragConfiguration = configuration.dragConfiguration
        self.styleConfiguration = configuration.styleConfiguration
        
        super.init(frame: .zero)
        
        setupSubviews()
        
        blockView.update(with: configuration.blockConfiguration)
        configuration.currentConfigurationState.map { 
            blockView.update(with: $0)
            update(with: $0)
        }
        
        setupDragInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UICollectionView configuration
    
    private func update(with state: UICellConfigurationState) {
        selectionView.updateStyle(isSelected: state.isSelected)
        
        isUserInteractionEnabled = state.isEditing
        viewDragInteraction.isEnabled = !state.isLocked
        if state.isMoving {
            backgroundColor = UIColor.VeryLight.blue
        } else {
            backgroundColor = .clear
        }
    }
    
    // MARK: - Drag&Drop
    
    private func setupDragInteraction() {
        guard dragConfiguration != nil, viewDragInteraction.view == nil else { return }
        
        viewDragInteraction.isEnabled = currentConfigurationState.map { $0.isLocked } ?? true
        blockView.addInteraction(viewDragInteraction)
    }
    

    // MARK: - Subviews setup
    private func setupSubviews() {
        addSubview(blockView) {
            let leadingConstraint = $0.leading.equal(to: leadingAnchor)
            let trailingConstraint = $0.trailing.equal(to: trailingAnchor)
            let topConstraint = $0.top.equal(to: topAnchor)
            let bottomConstraint = $0.bottom.greaterThanOrEqual(to: bottomAnchor, priority: .init(999))
            
            contentConstraints = .init(
                leadingConstraint: leadingConstraint,
                trailingConstraint: trailingConstraint,
                topConstraint: topConstraint,
                bottomConstraint: bottomConstraint
            )
        }        

        addSubview(selectionView) {
            $0.pin(to: self, excluding: [.bottom], insets: blockConfiguration.selectionInsets)
            $0.bottom.equal(to: bottomAnchor, constant: blockConfiguration.selectionInsets.bottom)
        }
        
        bringSubviewToFront(selectionView)
    }
    
    // MARK: - UIDragInteractionDelegate
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: any UIDragSession) -> [UIDragItem] {
        guard let dragConfiguration = dragConfiguration else {
            return []
        }
        
        let provider = NSItemProvider(object: dragConfiguration.id as any NSItemProviderWriting)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = dragConfiguration
        
        let dragPreview = UIDragPreview(view: self)
        item.previewProvider = { dragPreview }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        return [item]
    }
}
