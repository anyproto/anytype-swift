import SwiftUI

struct ObjectTypeObjectsListView: View {
    @StateObject private var model: ObjectTypeObjectsListViewModel
    
    init(typeDocument: any BaseDocumentProtocol, output: (any ObjectTypeObjectsListViewModelOutput)?) {
        _model = StateObject(wrappedValue: ObjectTypeObjectsListViewModel(
            document: typeDocument, output: output
        ))
    }
    
    var body: some View {
        content
            .task(id: model.sort) { await model.startListSubscription() }
            .task { await model.startSubscriptions() }
            .onDisappear { model.stopSubscriptions() }
            .onChange(of: model.sort) {
                AnytypeAnalytics.instance().logChangeTypeSort(
                    type: $0.relation.analyticsValue,
                    sort: $0.type.analyticValue
                )
            }
    }
    
    private var content: some View {
        VStack {
            header
            if model.rows.count > 0 {
                objectList
            } else {
                noObjects
            }
        }.padding(10).padding(.horizontal, 10)
    }
    
    private var header: some View {
        HStack(spacing: 0) {
            AnytypeText(Loc.objects, style: .subheading)
            Spacer.fixedWidth(8)
            AnytypeText("\(model.rows.count)", style: .previewTitle1Regular)
                .foregroundColor(Color.Text.secondary)
            Spacer()
            
            Menu {
                AsyncButton(model.setButtonText) { try await model.onSetButtonTap() }
                AllContentSortMenu(sort: $model.sort)
            } label: {
                IconView(asset: .X24.more).frame(width: 24, height: 24)
            }
            .menuOrder(.fixed)
            
            Spacer.fixedWidth(16)
            if model.canCreateOjbect {
                Button(action: {
                    model.onCreateNewObjectTap()
                }, label: {
                    IconView(asset: .X24.plus).frame(width: 24, height: 24)
                })
            }
        }
    }
    
    private var noObjects: some View {
        VStack(spacing: 2) {
            AnytypeText(Loc.EmptyView.Default.title, style: .uxTitle2Medium)
                .foregroundColor(.Text.secondary)
            AnytypeText(Loc.EmptyView.Default.subtitle, style: .relation3Regular)
                .foregroundColor(.Text.secondary)
        }.padding(.vertical, 18)
    }
    
    private var objectList: some View {
        VStack(spacing: 0) {
            ForEach(model.rows) { row in
                WidgetObjectListRowView(model: row)
            }
            Spacer.fixedHeight(12)
            setButton
            AnytypeNavigationSpacer(minHeight: 130)
        }
    }
    
    private var setButton: some View {
        AsyncStandardButton(model.setButtonText, style: .secondaryLarge) {
            try await model.onSetButtonTap()
        }
    }
}
