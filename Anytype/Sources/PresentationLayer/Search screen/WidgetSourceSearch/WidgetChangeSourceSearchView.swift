import Foundation
import SwiftUI

struct WidgetChangeSourceSearchView: View {
    
    let data: WidgetChangeSourceSearchModuleModel
    let onFinish: (_ openObject: ScreenData?) -> Void
    
    var body: some View {
        // TODO: Migrate from LegacySearchView
        LegacySearchView(
             viewModel: LegacySearchViewModel(
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
                        widgetSpaceId: data.spaceId,
                        context: data.context,
                        onFinish: onFinish
                    )
                 )
             )
         )
    }
}
