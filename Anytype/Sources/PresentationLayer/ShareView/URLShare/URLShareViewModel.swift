import AnytypeCore
import Services
import SwiftUI


final class URLShareViewModel: ObservableObject {
    @Published var destinationObject: ObjectDetails?
    @Published var urlOption: URLShareView.Option = .bookmark
    
    var onSaveOptionSave: ((SharedContentSaveOption) -> Void)? {
        didSet {
            updateSelection(option: urlOption, destinationObject: destinationObject)
        }
    }
    
    private let url: URL
    private let onDocumentSelection: RoutingAction<(String, [DetailsLayout], (ObjectSearchData) -> Void)>
    
    init(
        url: URL,
        onDocumentSelection: @escaping RoutingAction<(String, [DetailsLayout], (ObjectSearchData) -> Void)>
    ) {
        self.url = url
        self.onDocumentSelection = onDocumentSelection
    }
    
    func didSelectURLOption(option: URLShareView.Option) {
        self.destinationObject = nil
        self.urlOption = option
        
        updateSelection(option: option, destinationObject: destinationObject)
    }
    
    func tapSelectDestination() {
        onDocumentSelection((urlOption.destinationText, urlOption.supportedLayouts, { [weak self] searchData in
            guard let self = self else { return }
            self.destinationObject = searchData.details
            self.updateSelection(option: self.urlOption, destinationObject: searchData.details)
        }))
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
        
        switch option {
        case .bookmark:
            selectedOption = .url(url: url, savingOption: .bookmark(destination: destination))
        case .text:
            switch destination {
            case .asObject:
                selectedOption = .unavailable
            case .target(let targetObject):
                selectedOption = .text(string: url.attributedString, destination: .textBlock(targetObject))
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
