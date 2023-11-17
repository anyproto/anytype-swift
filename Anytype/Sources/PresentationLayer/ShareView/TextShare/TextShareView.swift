import SwiftUI

struct TextShareView: View {
    @ObservedObject var viewModel: TextShareViewModel
    
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
        AnytypeInlinePicker(initialValue: $viewModel.textOption, allValues: Option.allCases)
            .onChange(of: viewModel.textOption) { newValue in
                viewModel.didSelectTextOption(option: newValue)
            }
    }
    
    var selectDocumentRow: some View {
        AnytypeRow(
            title: viewModel.textOption.destinationText,
            description: viewModel.destinationObject?.name ?? "",
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

extension TextShareView {
    enum Option: Int, CaseIterable, Identifiable, TitleProvider {
        var id: Int { rawValue }
        
        case newObject
        case textBlock
        
        var title: String {
            switch self {
            case .newObject:
                return Loc.Sharing.Text.noteObject
            case .textBlock:
                return Loc.Sharing.Text.textBlock
            }
        }
        
        var destinationText: String {
            switch self {
            case .newObject:
                return Loc.Sharing.linkTo
            case .textBlock:
                return Loc.Sharing.addTo
            }
        }
    }
}
