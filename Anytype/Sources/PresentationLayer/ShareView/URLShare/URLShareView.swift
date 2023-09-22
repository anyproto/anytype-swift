import SwiftUI

struct URLShareView: View {
    @ObservedObject var viewModel: URLShareViewModel
    
    var body: some View {
        SectionTitle(title: Loc.Sharing.saveAs)
        urlSegmentView
        Spacer.fixedHeight(16)
        selectDocumentRow
    }
    
    var urlSegmentView: some View {
        AnytypeInlinePicker(allValues: Option.allCases) { selection in
            viewModel.didSelectURLOption(option: selection)
        }
    }
    
    var selectDocumentRow: some View {
        AnytypeRow(
            action: viewModel.tapSelectDestination,
            title: viewModel.urlOption.destinationText,
            description: viewModel.destinationObject?.title ?? ""
        )
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

extension URLShareView {
    enum Option: Int, CaseIterable, Identifiable, TitleProvider {
        var id: Int { rawValue }
        
        case bookmark
        case text
        
        var title: String {
            switch self {
            case .bookmark:
                return Loc.Sharing.Url.bookmark
            case .text:
                return Loc.Sharing.Url.text
            }
        }
        
        var destinationText: String {
            switch self {
            case .bookmark:
                return Loc.Sharing.linkTo
            case .text:
                return Loc.Sharing.addTo
            }
        }
    }
}
