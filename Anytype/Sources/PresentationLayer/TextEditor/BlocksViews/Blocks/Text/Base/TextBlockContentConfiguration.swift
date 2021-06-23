import BlocksModels
import UIKit
import Combine


struct TextBlockContentConfiguration {
    
    let toolbarActionSubject: PassthroughSubject<BlockToolbarAction, Never>
    let viewModel: TextBlockViewModel
    let information: BlockInformation
    weak var blockActionHandler: NewBlockActionHandler?
    let mentionsConfigurator: MentionsTextViewConfigurator
    
    private(set) weak var textViewDelegate: TextViewDelegate?
    private(set) var isSelected: Bool = false
    
    init(
        textViewDelegate: TextViewDelegate?,
        viewModel: TextBlockViewModel,
        toolbarActionSubject: PassthroughSubject<BlockToolbarAction, Never>,
        blockActionHandler: NewBlockActionHandler?,
        mentionsConfigurator: MentionsTextViewConfigurator
    ) {
        self.toolbarActionSubject = toolbarActionSubject
        self.textViewDelegate = textViewDelegate
        self.information = viewModel.information
        self.viewModel = viewModel
        self.blockActionHandler = blockActionHandler
        self.mentionsConfigurator = mentionsConfigurator
    }
    
    func setupMentionsInteraction(_ customTextView: CustomTextView) {
        mentionsConfigurator.configure(textView: customTextView)
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
        lhs.information == rhs.information && lhs.isSelected == rhs.isSelected
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(information)
        hasher.combine(isSelected)
    }
    
}
