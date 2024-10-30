import SwiftUI
import Services

struct DateView: View {
    
    @StateObject private var model: DateViewModel
    
    init(objectId: String, spaceId: String, output: (any DateModuleOutput)?) {
        self._model = StateObject(wrappedValue: DateViewModel(objectId: objectId, spaceId: spaceId, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            titleView
            relations
            Spacer.fixedHeight(8)
            list
        }
        .task {
            await model.subscribeOnSyncStatus()
        }
        .task {
            await model.subscribeOnDetails()
        }
        .task {
            await model.getRelationsList()
        }
        .task(item: model.state) { state in
            await model.restartSubscription(with: state)
        }
        .onDisappear() {
            model.onDisappear()
        }
    }
    
    private var navigationBar: some View {
        HStack(alignment: .center, spacing: 14) {
            SwiftUIEditorSyncStatusItem(
                statusData: model.syncStatusData,
                itemState: EditorBarItemState(haveBackground: false, opacity: 0),
                onTap: {
                    model.onSyncStatusTap()
                }
            )
            .frame(width: 28, height: 28)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(height: 48)
    }
    
    private var titleView: some View {
        AnytypeText(model.title, style: .title)
            .foregroundColor(.Text.primary)
            .padding(.vertical, 32)
    }
    
    private var relations: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(model.relationDetails, id: \.self) { details in
                    relationView(details: details)
                }
            }
            .frame(height: 40)
            .padding(.horizontal, 16)
            .padding(.vertical, 1)
        }
    }
    
    private func relationView(details: RelationDetails) -> some View {
        Button {
            model.onRelationTap(details)
        } label: {
            HStack(spacing: 8) {
                AnytypeText(details.name, style: .uxCalloutMedium)
                    .foregroundColor(.Text.primary)
            }
            .padding(.horizontal,12)
            .padding(.vertical, 10)
            .background(model.state.selectedRelation == details ? Color.Shape.transperentSecondary : .clear)
            .cornerRadius(10, style: .continuous)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.Shape.primary, lineWidth: 1)
            )
        }
    }
    
    private var list: some View {
        PlainList {
            ForEach(model.objects) { data in
                ObjectCell(data: data)
                    .onAppear {
                        model.onAppearLastRow(data.id)
                    }
            }
            AnytypeNavigationSpacer(minHeight: 130)
        }
        .scrollIndicators(.never)
        .id(model.state.scrollId)
    }
}

#Preview {
    DateView(objectId: "", spaceId: "", output: nil)
}
