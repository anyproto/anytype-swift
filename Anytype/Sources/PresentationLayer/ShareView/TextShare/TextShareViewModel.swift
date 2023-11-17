import AnytypeCore
import Services
import SwiftUI


final class TextShareViewModel: ObservableObject {
    @Published var destinationObject: ObjectDetails?
    @Published var textOption: TextShareView.Option = .newObject
    @Published var selectedSpace: SpaceView?
    
    var onSaveOptionSave: ((SharedContentSaveOption) -> Void)? {
        didSet {
            updateSelection(option: textOption, destinationObject: destinationObject, objectName: nil)
        }
    }
    private let attributedText: AttributedString
    private let onDocumentSelection: RoutingAction<SearchModuleModel>
    private let onSpaceSelection: RoutingAction<(SpaceView) -> Void>
    
    init(
        attributedText: AttributedString,
        onDocumentSelection: @escaping RoutingAction<SearchModuleModel>,
        onSpaceSelection: @escaping RoutingAction<(SpaceView) -> Void>
    ) {
        self.attributedText = attributedText
        self.onDocumentSelection = onDocumentSelection
        self.onSpaceSelection = onSpaceSelection
    }
    
    func didSelectTextOption(option: TextShareView.Option) {
        self.destinationObject = nil
        
        withAnimation {
            self.textOption = option
        }
        updateSelection(option: option, destinationObject: destinationObject, objectName: nil)
    }
    
    func tapSelectDestination() {
        guard let selectedSpace else { return }
        let searchModuleModel = SearchModuleModel(
            spaceId: selectedSpace.targetSpaceId,
            title: textOption.destinationText,
            layoutLimits: textOption.supportedLayouts,
            onSelect: { [weak self] searchData  in
                guard let self = self else { return }
                self.destinationObject = searchData.details
                self.updateSelection(option: textOption, destinationObject: searchData.details, objectName: nil)
            }
        )
        onDocumentSelection(searchModuleModel)
    }
    
    func tapSelectSpace() {
        onSpaceSelection { [weak self] space in
            guard let self else { return }
            selectedSpace = space
            updateSelection(option: textOption, destinationObject: destinationObject, objectName: nil)
        }
    }
    
    private func updateSelection(option: TextShareView.Option, destinationObject: ObjectDetails?, objectName: String?) {
        let selectedOption: SharedContentSaveOption
        
        guard let selectedSpace else {
            onSaveOptionSave?(.unavailable)
            return
        }

        switch option {
        case .newObject:
            selectedOption = .text(
                string: NSAttributedString(attributedText),
                destination: .space(
                    space: selectedSpace,
                    destination: .object(named: "", linkedTo: destinationObject)
                )
            )
        case .textBlock:
            guard let destinationObject = destinationObject else {
                onSaveOptionSave?(.unavailable)
                return
            }
        
            selectedOption = .text(
                string: NSAttributedString(attributedText),
                destination: .space(space: selectedSpace, destination: .textBlock(destinationObject))
            )
        }

        onSaveOptionSave?(selectedOption)
    }
}

extension TextShareViewModel: ShareViewModelProtocol {
    func didSelectDestination(searchData: ObjectSearchData) {
        destinationObject = searchData.details
    }
    
    var showingView: AnyView {
        TextShareView(viewModel: self).eraseToAnyView()
    }
}

private extension TextShareView.Option {
    var supportedLayouts: [DetailsLayout] {
        switch self {
        case .newObject:
            return DetailsLayout.editorLayouts + [.collection]
        case .textBlock:
            return DetailsLayout.editorLayouts
        }
    }
}
