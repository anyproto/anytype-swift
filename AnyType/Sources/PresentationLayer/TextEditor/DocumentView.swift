//
//  DocumentView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct DocumentView: View {
    @ObservedObject var viewModel: DocumentViewModel
    @State var dragCoordinates: CGRect? = nil
    
    init(viewModel: DocumentViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        if let builders = viewModel.blocksViewsBuilders {
            if builders.isEmpty {
                return AnyView(EmptyDocumentView(title: ""))
            } else {
                return AnyView(blocksView(viewBulders: builders))
            }
        } else {
            return AnyView(loading)
        }
    }
}

private extension DocumentView {
    
    func blocksView(viewBulders: [BlockViewRowBuilderProtocol]) -> some View {
        ScrollView {
            ForEach(viewBulders, id: \.id) { rowViewBuilder in
                VStack(spacing: 0) {
                    Divider().modifier(ShowViewOnRectIntersect(dragCoordinates: self.dragCoordinates, emptyView:  Spacer()))
                    rowViewBuilder.buildView()
                }
            }
        }
        .onPreferenceChange(BaseViewPreferenceKey.self) { preference in
            print("onPreferenceChange \(preference.dragRect?.origin.y ?? -0)")
//            if let bounds = preference.dragRect, preference.isDragging {
//                self.dragCoordinates = bounds
//            }
            if preference.isDragging {
                self.dragCoordinates = preference.dragRect
            } else {
                self.dragCoordinates = nil
            }
        }
    }
    
    var loading: some View {
        Text("Loading...")
            .foregroundColor(.gray)
    }
}

struct ShowViewOnRectIntersect<EmptyView: View>: ViewModifier {
    @State private var dropCoordinate: CGRect?
    var dragCoordinates: CGRect?
    var emptyView: EmptyView
    
    func body(content: Content) -> some View {
        VStack {
            if showContent() {
                content
            } else {
                emptyView
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        self.dropCoordinate = proxy.frame(in: .global)
                }
            }
        )
    }
    
    private func showContent() -> Bool {
        if let dropCoordinate = dropCoordinate, let dragCoordinates = dragCoordinates, dragCoordinates.intersects(dropCoordinate) {
            return true
        }
        return false
    }
}


struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = DocumentViewModel(documentId: "1")
        
        return DocumentView(viewModel: viewModel)
    }
    
}
