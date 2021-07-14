import BlocksModels
import UIKit
import Combine


struct TextBlockContentConfiguration {
    weak var viewModel: TextBlockViewModel?
    let information: BlockInformation
    let blockActionHandler: EditorActionHandlerProtocol
    let mentionsConfigurator: MentionsTextViewConfigurator
    let shouldDisplayPlaceholder: Bool
    
    private(set) weak var textViewDelegate: TextViewDelegate?
    private(set) var isSelected: Bool = false
    
    init(
        textViewDelegate: TextViewDelegate?,
        viewModel: TextBlockViewModel,
        blockActionHandler: EditorActionHandlerProtocol,
        mentionsConfigurator: MentionsTextViewConfigurator
    ) {
        self.textViewDelegate = textViewDelegate
        self.information = viewModel.information
        self.viewModel = viewModel
        self.blockActionHandler = blockActionHandler
        self.mentionsConfigurator = mentionsConfigurator
        shouldDisplayPlaceholder = viewModel.block.isToggled && viewModel.information.childrenIds.isEmpty
    }
    
    func setupMentionsInteraction(_ customTextView: CustomTextView) {
        mentionsConfigurator.configure(textView: customTextView.textView)
    }
}

extension TextBlockContentConfiguration: UIContentConfiguration {
    
    func makeContentView() -> UIView & UIContentView {
        let view = TextBlockContentView(configuration: self)
        return view
    }
    
    func updated(for state: UIConfigurationState) -> TextBlockContentConfiguration {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfig = self

        updatedConfig.isSelected = state.isSelected
        return updatedConfig
    }
}

extension TextBlockContentConfiguration: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.information == rhs.information &&
            lhs.isSelected == rhs.isSelected &&
            lhs.information.content == rhs.information.content &&
            lhs.shouldDisplayPlaceholder == rhs.shouldDisplayPlaceholder
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(information)
        hasher.combine(isSelected)
        hasher.combine(information.content)
        hasher.combine(shouldDisplayPlaceholder)
    }
    
}
