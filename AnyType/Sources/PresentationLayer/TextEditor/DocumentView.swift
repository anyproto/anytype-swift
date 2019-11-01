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
    @State var dragCoordinates: Anchor<CGRect>? = nil
    @State var someBool: Bool = false
    
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
//                rowViewBuilder.buildView()
                AnyView(Text("ss").modifier(BaseView()))
            }
        }
        .background(
            GeometryReader { geometry -> EmptyView in
//                if let dragCoordinates = self.dragCoordinates {
//                    print("\(geometry[dragCoordinates])")
//                }
                return EmptyView()
            }
        )
        .onPreferenceChange(BaseViewPreferenceKey.self) { preference in
            print("some bool: \(self.someBool)")
            if let bounds = preference.bounds, preference.isDragging {
//                self.dragCoordinates = bounds
//                self.someBool.toggle()
            }
            self.someBool.toggle()
        }
    }
    
    var loading: some View {
        Text("Loading...")
            .foregroundColor(.gray)
    }
    
    private func makeView(geometry: GeometryProxy, preference: BaseViewPreferenceData) -> some View {
        print("make view")
        
        if let bounds = preference.bounds, preference.isDragging {
            let bounds = geometry[bounds]
            print("some bounds: \(bounds)")
        }
        
        return ZStack {
            Divider()
        }
    }
    
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = DocumentViewModel(documentId: "1")
        
        return DocumentView(viewModel: viewModel)
    }
    
}
