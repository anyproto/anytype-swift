import Foundation
import SwiftUI

struct WidgetChangeSourceSearchView: View {
    
    let data: WidgetChangeSourceSearchModuleModel
    
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
                     internalModel: WidgetSourceSearchChangeInternalViewModel(
                        widgetObjectId: data.widgetObjectId,
                        widgetId: data.widgetId,
                        context: data.context,
                        onFinish: data.onFinish
                    )
                 )
             )
         )
    }
}
