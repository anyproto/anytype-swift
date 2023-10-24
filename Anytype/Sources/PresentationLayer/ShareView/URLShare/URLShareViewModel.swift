import AnytypeCore
import Services
import SwiftUI

final class URLShareViewModel: ObservableObject {
    @Published var destinationObject: ObjectDetails?
    @Published var urlOption: URLShareView.Option = .bookmark
    @Published var selectedSpace: SpaceView?
    
    var onSaveOptionSave: ((SharedContentSaveOption) -> Void)? {
        didSet {
            updateSelection(option: urlOption, destinationObject: destinationObject)
        }
    }
    
    private let url: URL
    private let onDocumentSelection: RoutingAction<SearchModuleModel>
    private let onSpaceSelection: RoutingAction<(SpaceView) -> Void>
    
    init(
        url: URL,
        onDocumentSelection: @escaping RoutingAction<SearchModuleModel>,
        onSpaceSelection: @escaping RoutingAction<(SpaceView) -> Void>
    ) {
        self.url = url
        self.onDocumentSelection = onDocumentSelection
        self.onSpaceSelection = onSpaceSelection
    }
    
    func didSelectURLOption(option: URLShareView.Option) {
        self.destinationObject = nil
        self.urlOption = option
        
        updateSelection(option: option, destinationObject: destinationObject)
    }
    
    func tapSelectDestination() {
        guard let selectedSpace else { return }
        let searchModuleModel = SearchModuleModel(
            spaceId: selectedSpace.targetSpaceId,
            title: urlOption.destinationText,
            layoutLimits: urlOption.supportedLayouts,
            onSelect: { [weak self] searchData  in
                guard let self = self else { return }
                self.destinationObject = searchData.details
                self.updateSelection(option: self.urlOption, destinationObject: searchData.details)
            }
        )
        onDocumentSelection(searchModuleModel)
    }
    
    func tapSelectSpace() {
        onSpaceSelection { [weak self] space in
            guard let self = self else { return }
            selectedSpace = space
            updateSelection(option: urlOption, destinationObject: destinationObject)
        }
    }
    
    private func updateSelection(option: URLShareView.Option, destinationObject: ObjectDetails?) {
        let selectedOption: SharedContentSaveOption
        let destination: SharedContentSaveOption.URLDestinationOption = {
            if let destinationObject = destinationObject {
                return .target(destinationObject)
            } else {
                return .asObject(named: url.absoluteString)
            }
        }()
        
        guard let selectedSpace else {
            onSaveOptionSave?(.unavailable)
            return
        }
        
        switch option {
        case .bookmark:
            selectedOption = .url(
                url: url,
                savingOption: .space(
                    space: selectedSpace,
                    destination: .bookmark(destination: destination)
                )
            )
        case .text:
            switch destination {
            case .asObject:
                selectedOption = .unavailable
            case .target(let targetObject):
                selectedOption = .text(
                    string: url.attributedString,
                    destination: .space(
                        space: selectedSpace,
                        destination: .textBlock(targetObject)
                    )
                )
            }
        }
        
        onSaveOptionSave?(selectedOption)
    }
}

extension URLShareViewModel: ShareViewModelProtocol {
    func didSelectDestination(searchData: ObjectSearchData) {
        destinationObject = searchData.details
    }
    
    var showingView: AnyView {
        URLShareView(viewModel: self).eraseToAnyView()
    }
}

extension URLShareView.Option {
    var supportedLayouts: [DetailsLayout] {
        switch self {
        case .bookmark:
            return DetailsLayout.editorLayouts + [.collection]
        case .text:
            return DetailsLayout.editorLayouts
        }
    }
}
