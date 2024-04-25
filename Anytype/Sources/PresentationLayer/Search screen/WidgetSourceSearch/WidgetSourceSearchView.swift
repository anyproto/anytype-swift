import Foundation
import SwiftUI

struct WidgetSourceSearchView: View {
    
    let data: WidgetSourceSearchModuleModel
    let onSelect: (_ source: WidgetSource) -> Void
    
    var body: some View {
        // TODO: Migrate from NewSearchView
        NewSearchView(
             viewModel: NewSearchViewModel(
                 title: Loc.Widgets.sourceSearch,
                 searchPlaceholder: Loc.search,
                 style: .default,
                 itemCreationMode: .unavailable,
                 internalViewModel: WidgetSourceSearchViewModel(
                     interactor: WidgetSourceSearchInteractor(
                        spaceId: data.spaceId
                     ),
                     internalModel: WidgetSourceSearchSelectInternalViewModel(context: data.context, onSelect: onSelect)
                 )
             )
         )
    }
}
