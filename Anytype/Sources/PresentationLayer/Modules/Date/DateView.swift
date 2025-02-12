import SwiftUI
import Services

struct DateView: View {
    
    @StateObject private var model: DateViewModel
    
    init(date: Date?, spaceId: String, output: (any DateModuleOutput)?) {
        self._model = StateObject(wrappedValue: DateViewModel(date: date, spaceId: spaceId, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            titleView
            content
        }
        .task(id: model.document?.objectId) {
            await model.documentDidChange()
        }
        .task(item: model.state) { state in
            await model.restartRelationSubscription(with: state)
        }
        .onAppear {
            model.onAppear()
        }
        .onDisappear {
            model.onDisappear()
        }
    }
    
    private var navigationBar: some View {
        PageNavigationHeader(title: "") {
            HStack(alignment: .center, spacing: 12) {
                SwiftUIEditorSyncStatusItem(
                    statusData: model.syncStatusData,
                    itemState: .initial,
                    onTap: {
                        model.onSyncStatusTap()
                    }
                )
                .frame(width: 28, height: 28)
                
                Image(asset: .X24.calendar)
                    .foregroundColor(.Control.active)
                    .onTapGesture {
                        model.onCalendarTap()
                    }
            }
        }
    }
    
    private var titleView: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                if model.relativeTag.isNotEmpty {
                    AnytypeText(model.relativeTag, style: .relation2Regular)
                        .foregroundColor(.Text.secondary)
                    Circle()
                        .fill(Color.Text.secondary)
                        .frame(width: 3, height: 3)
                        .padding(.horizontal, 8)
                }
                AnytypeText(model.weekday, style: .relation2Regular)
                    .foregroundColor(.Text.secondary)
            }
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
        }
        .padding(.top, 16)
        .padding(.bottom, 32)
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
            title: "",
            subtitle: Loc.Date.Object.Empty.State.title,
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
        ScrollViewReader { reader in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    relationsListButton
                    ForEach(model.relationItems) { item in
                        relationView(item: item)
                    }
                }
                .frame(height: 40)
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
            .onChange(of: model.scrollToRelationId) { id in
                reader.scrollTo(id, anchor: .center)
            }
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
        .id(item.id)
        .onAppear {
            model.resetScrollToRelationIdIfNeeded(id: item.id)
        }
    }
    
    private var list: some View {
        PlainList {
            ForEach(model.objects) { data in
                ObjectCell(data: data)
                    .onAppear {
                        model.onAppearLastRow(data.id)
                    }
                    .if(data.canArchive) {
                        $0.swipeActions {
                            Button(Loc.toBin, role: .destructive) {
                                model.onDelete(objectId: data.id)
                            }
                        }
                    }
            }
            AnytypeNavigationSpacer(minHeight: 130)
        }
        .scrollIndicators(.never)
        .id(model.state.scrollId)
    }
}

#Preview {
    DateView(date: Date(), spaceId: "spaceId", output: nil)
}
