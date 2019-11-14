//
//  DocumentView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct DocumentViewPreferenceData: Equatable {
    static func == (lhs: DocumentViewPreferenceData, rhs: DocumentViewPreferenceData) -> Bool {
        lhs.blockRect == rhs.blockRect
    }
    
//    let id: UUID
    let blockRect: CGRect
}

struct DocumentViewPreference: PreferenceKey {
    typealias Value = DocumentViewPreferenceData

    static var defaultValue = DocumentViewPreferenceData(blockRect: .zero)
    
    static func reduce(value: inout DocumentViewPreferenceData, nextValue: () -> DocumentViewPreferenceData) {
        value = nextValue()
    }
}

struct DocumentView: View {
    @ObservedObject var viewModel: DocumentViewModel
    @State var dragCoordinates: CGRect = nil
    @State var dropCoordinates = [DocumentViewPreferenceData]()
    
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
                VStack {
                    ShowViewOnRectIntersect(dragCoordinates: self.$dragCoordinates)
                    rowViewBuilder.buildView()
                }
//                .background(
//                    GeometryReader { geometry in
//                        Color.clear.preference(key: DocumentViewPreference.self, value: [DocumentViewPreferenceData(id: rowViewBuilder.id, blockRect: geometry.frame(in: .global))])
//                    }
//                )
            }
        }
        .onPreferenceChange(BaseViewPreferenceKey.self) { preference in
            print("onPreferenceChange")
            if let bounds = preference.dragRect, preference.isDragging {
                self.dragCoordinates = bounds
            }
        }
//        .onPreferenceChange(DocumentViewPreference.self) { preference in
//            self.dropCoordinates = preference
//        }
    }
    
//    private func showDropLine(index: UUID) -> Bool {
//        var showDropLine = false
//
//        if let dragCoordinates = self.dragCoordinates, let preference = dropCoordinates.first(where: {
//            $0.id == index
//        }) {
//            print("\(preference.proxy[dragCoordinates])")
//        }
//
//        return showDropLine
//    }
    
    var loading: some View {
        Text("Loading...")
            .foregroundColor(.gray)
    }
    
//    private func makeView(geometry: GeometryProxy, preference: BaseViewPreferenceData) -> some View {
//        print("make view")
//
//        if let bounds = preference.dragRect, preference.isDragging {
//            let bounds = geometry[bounds]
//            print("some bounds: \(bounds)")
//        }
//
//        return ZStack {
//            Divider()
//        }
//    }
    
}

struct ShowViewOnRectIntersect: View {
    @Binding var dragCoordinates: CGRect?
    @State private var dropCooridante: CGRect?
    
    var body: some View {
        VStack {
            if showContent() {
                Divider()
            }
        }.background(
            GeometryReader { proxy in
                self.obtainDropCoordinates(proxy: proxy)
            }
        )
    }
    
    private func obtainDropCoordinates(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.dropCooridante = proxy.frame(in: .global)            
        }
        
        return Color.clear
    }
    
    private func showContent() -> Bool {
        if let dragCoordinates = dragCoordinates, let dropCooridante = dropCooridante, dragCoordinates.intersects(dropCooridante) {
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
