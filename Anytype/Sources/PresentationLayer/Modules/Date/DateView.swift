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
            content
        }
        .task(id: model.document.objectId) {
            await model.documentDidChange()
        }
        .task(item: model.state) { state in
            await model.restartRelationSubscription(with: state)
        }
        .onDisappear() {
            model.onDisappear()
        }
    }
    
    private var navigationBar: some View {
        HStack(alignment: .center, spacing: 14) {
            SwiftUIEditorSyncStatusItem(
                statusData: model.syncStatusData,
                itemState: .initial,
                onTap: {
                    model.onSyncStatusTap()
                }
            )
            .frame(width: 28, height: 28)
            
            Spacer()
            
            Image(asset: .X24.calendar)
                .foregroundColor(.Control.active)
                .onTapGesture {
                    model.onCalendarTap()
                }
        }
        .padding(.horizontal, 12)
        .frame(height: 48)
    }
    
    private var titleView: some View {
        HStack(alignment: .center) {
            Image(asset: .X24.Arrow.left)
                .foregroundColor(.Control.active)
                .onTapGesture {
                    model.onPrevDayTap()
                }
                .opacity(model.hasPrevDay() ? 1 : 0)
            
            Spacer()
            AnytypeText(model.title, style: .title)
                .foregroundColor(.Text.primary)
                .padding(.vertical, 32)
                .onTapGesture {
                    model.onCalendarTap()
                }
            Spacer()
            
            Image(asset: .X24.Arrow.right)
                .foregroundColor(.Control.active)
                .onTapGesture {
                    model.onNextDayTap()
                }
                .opacity(model.hasNextDay() ? 1 : 0)
        }
        .padding(.horizontal, 16)
    }
    
    private var content: some View {
        VStack(spacing: 8) {
            if model.relationItems.isNotEmpty {
                relations
                list
            } else {
                emptyState
            }
        }
    }
    
    private var emptyState: some View {
        EmptyStateView(
            title: Loc.Date.Object.Empty.State.title,
            subtitle: "",
            style: .plain
        )
    }
    
    private var relationsListButton: some View {
        Button {
            model.onRelationsListTap()
        } label: {
            IconView(asset: .X24.burger)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.Shape.primary, lineWidth: 1)
                )
        }
    }
    
    private var relations: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                relationsListButton
                ForEach(model.relationItems) { item in
                    relationView(item: item)
                }
            }
            .frame(height: 40)
            .padding(.horizontal, 16)
            .padding(.vertical, 1)
        }
    }
    
    private func relationView(item: RelationItemData) -> some View {
        Button {
            model.onRelationTap(item.details)
        } label: {
            HStack(spacing: 6) {
                IconView(icon: item.icon)
                    .frame(width: 24, height: 24)
                AnytypeText(item.title, style: .uxCalloutMedium)
                    .foregroundColor(.Text.primary)
            }
        }
        .padding(.horizontal,12)
        .frame(height: 40)
        .background(model.state.selectedRelation == item.details ? Color.Shape.transperentSecondary : .clear)
        .cornerRadius(10, style: .continuous)
        .border(10, color: Color.Shape.primary)
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
