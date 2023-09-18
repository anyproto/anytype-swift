import SwiftUI

struct TextShareView: View {
    @ObservedObject var viewModel: TextShareViewModel
    
    var body: some View {
        SectionTitle(title: Loc.Sharing.saveAs)
        urlSegmentView
        Spacer.fixedHeight(16)
        selectDocumentRow
    }
    
    var urlSegmentView: some View {
        AnytypeInlinePicker(allValues: Option.allCases) { selection in
            viewModel.didSelectTextOption(option: selection)
        }
    }
    
    var selectDocumentRow: some View {
        AnytypeRow(
            title: viewModel.textOption.destinationText,
            description: viewModel.destinationObject?.name ?? "",
            action: viewModel.tapSelectDestination
        )
        .background(Color.Background.primary)
        .cornerRadius(8)
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
