import Foundation
import SwiftUI

struct ObjectVersionView: View {
    
    @StateObject private var model: ObjectVersionViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: ObjectVersionData, output: (any ObjectVersionModuleOutput)?) {
        _model = StateObject(wrappedValue: ObjectVersionViewModel(data: data, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            content
            if model.data.canRestore {
                buttons
            }
        }
        .onAppear {
            model.onAppear()
        }
        .task {
            await model.setupObject()
        }
        .onChange(of: model.dismiss) {
            dismiss()
        }
    }
    
    private var header: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title:  model.data.title) {
                ObjectIconView(icon: model.data.icon)
                    .frame(width: 24, height: 24)
            }
        }
        .background(Color.Background.primary)
    }
    
    @ViewBuilder
    private var content: some View {
        switch model.screenData {
        case .page(let data):
            EditorPageCoordinatorView(data: data, showHeader: false, setupEditorInput: {_,_ in })
        case .list(let data):
            EditorSetCoordinatorView(data: data, showHeader: false)
        default:
            EmptyView()
        }
    }
    
    private var buttons: some View {
        HStack {
            StandardButton(
                Loc.cancel,
                style: .secondaryMedium,
                action: { model.onCancelTap() }
            )
            StandardButton(
                Loc.restore,
                style: .primaryMedium,
                action: { model.onRestoreTap() }
            )
        }
        .padding(.top, 16)
        .padding(.horizontal, 20)
        .overlay(alignment: .top) {
            AnytypeDivider()
        }
        .background(Color.Background.primary)
    }
}
