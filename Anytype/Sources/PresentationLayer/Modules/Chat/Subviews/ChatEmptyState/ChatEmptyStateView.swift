import Foundation
import SwiftUI

struct ChatEmptyStateView: View {
    
    enum Field: Hashable {
        case title
        case description
    }
    
    @StateObject private var model: ChatEmptyStateViewModel
    @FocusState private var focusedField: Field?
    
    init(objectId: String, onIconSelected: @escaping () -> Void, onDone: @escaping () -> Void) {
        self._model = StateObject(wrappedValue: ChatEmptyStateViewModel(objectId: objectId, onIconSelected: onIconSelected, onDone: onDone))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            IconView(icon: model.icon)
                .frame(width: 112, height: 112)
                .onTapGesture {
                    model.didTapIcon()
                }
            Spacer.fixedHeight(20)
            TextField(Loc.Message.ChatTitle.placeholder, text: $model.title, axis: .vertical)
                .anytypeFontStyle(.title)
                .foregroundStyle(Color.Text.primary)
                .focused($focusedField, equals: .title)
                .submitLabel(.next)
                .onChange(of: model.title) { newValue in
                    // onSubmit doesn't work if axis == .vertical
                    if newValue.last == "\n" {
                        model.title = newValue.replacingOccurrences(of: "\n", with: "")
                        focusedField = .description
                    }
                }
            
            Spacer.fixedHeight(8)
            TextField(Loc.BlockText.ContentType.Description.placeholder, text: $model.description, axis: .vertical)
                .anytypeFontStyle(.relation1Regular)
                .foregroundStyle(Color.Text.primary)
                .submitLabel(.next)
                .focused($focusedField, equals: .description)
                .onChange(of: model.description) { newValue in
                    // onSubmit doesn't work if axis == .vertical
                    if newValue.last == "\n" {
                        model.description = newValue.replacingOccurrences(of: "\n", with: "")
                        model.didTapDone()
                    }
                }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 25)
        .task {
            await model.startDetailsSubscription()
        }
        .throwingTask(id: model.title) {
            try await model.titleUpdated()
        }
        .throwingTask(id: model.description) {
            try await model.descriptionUpdated()
        }
        .onAppear {
            focusedField = .title
        }
    }
}
