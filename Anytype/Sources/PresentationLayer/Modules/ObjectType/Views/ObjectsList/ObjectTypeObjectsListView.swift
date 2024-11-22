import SwiftUI

struct ObjectTypeObjectsListView: View {
    @StateObject private var model: ObjectTypeObjectsListViewModel
    let creationAvailable: Bool
    
    init(objectTypeId: String, spaceId: String, creationAvailable: Bool, output: (any ObjectTypeObjectsListViewModelOutput)?) {
        self.creationAvailable = creationAvailable
        _model = StateObject(wrappedValue: ObjectTypeObjectsListViewModel(
            objectTypeId: objectTypeId, spaceId: spaceId, output: output
        ))
    }
    
    var body: some View {
        content
            .task(id: model.sort) { await model.startSubscription() }
            .onDisappear { model.stopStopSubscription() }
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
                AllContentSortMenu(sort: $model.sort)
            } label: {
                IconView(asset: .X24.more).frame(width: 24, height: 24)
            }
            .menuOrder(.fixed)
            
            Spacer.fixedWidth(16)
            if creationAvailable {
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
        VStack {
            ForEach(model.rows) { row in
                WidgetObjectListRowView(model: row)
            }
            AnytypeNavigationSpacer(minHeight: 130)
        }
    }
}

#Preview {
    ObjectTypeObjectsListView(objectTypeId: "", spaceId: "", creationAvailable: true, output: nil)
}
