import SwiftUI

struct URLShareView: View {
    @ObservedObject var viewModel: URLShareViewModel
    
    var body: some View {
        SectionTitle(title: Loc.Sharing.saveAs)
        urlSegmentView
        Spacer.fixedHeight(16)
        VStack {
            selectSpaceRow
            if viewModel.selectedSpace != nil {
                selectDocumentRow
            }
        }
        .background(UIColor.secondarySystemGroupedBackground.suColor)
        .cornerRadius(8)
        
    }
    
    var urlSegmentView: some View {
        AnytypeInlinePicker(initialValue: $viewModel.urlOption, allValues: Option.allCases)
            .onChange(of: viewModel.urlOption) { newValue in
                viewModel.didSelectURLOption(option: newValue)
        }
    }
    
    var selectDocumentRow: some View {
        AnytypeRow(
            title: viewModel.urlOption.destinationText,
            description: viewModel.destinationObject?.title ?? "",
            action: viewModel.tapSelectDestination
        )
    }
    
    var selectSpaceRow: some View {
        AnytypeRow(
            title: Loc.Sharing.selectSpace,
            description: viewModel.selectedSpace?.title ?? "",
            action: viewModel.tapSelectSpace
        )
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
