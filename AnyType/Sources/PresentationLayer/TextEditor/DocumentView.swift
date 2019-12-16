//
//  DocumentView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct DocumentView: View {
    @Environment(\.showViewFrames) private var showViewFrames
    
    @ObservedObject var viewModel: DocumentViewModel
    @State var dragCoordinates: CGRect?
    @State var blocksRects: [CGRect] // blocks' rects
    @State var velocity: CGPoint = .zero
    
    init(viewModel: DocumentViewModel) {
        self.viewModel = viewModel
        _blocksRects = State(initialValue: [CGRect]())
        
        if let builders = viewModel.blocksViewsBuilders {
            _blocksRects = State(initialValue: Array<CGRect>(repeating: CGRect.zero, count: builders.count))
        }
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
    
    func blocksView(viewBulders: [BlockViewBuilderProtocol]) -> some View {
        CustomScrollView() {
            ForEach(0..<viewBulders.count, id: \.self) { index in
                self.makeBlockView(for: index, in: viewBulders)
                    .padding(.top, -10) // Workaround: remove spacing
            }
                .padding(.top, 10) // Workaround: adjust first item after removing spacing
        }
        .scrollViewOffset(offset: self.velocity)
        .border(showViewFrames ? Color.red : Color.clear)
            // TODO: Replace with pasteDraggingView func
        .overlayPreferenceValue(BaseViewPreferenceKey.self) { preference in
            GeometryReader { proxy in
                return DraggingView(proxy: proxy, viewBulders: viewBulders, preference: preference)
            }
        }
        .overlayPreferenceValue(DraggingViewPreferenceDataKey.self) { preference in
            self.saveDraggingViewPostion(preference: preference)
        }
        .modifier(VelocityOnIntersectViewBoundary(velocity: self.$velocity))
    }
    
     // TODO: Move to PasteDraggingView struct
    
    struct DraggingViewPreferenceData: Identifiable, Equatable {
        static func == (lhs: DraggingViewPreferenceData, rhs: DraggingViewPreferenceData) -> Bool {
            lhs.id == rhs.id
        }
        
        let id = UUID()
        let position: Anchor<CGRect>?
        let globalPositon: CGRect?
    }
    
    
    struct DraggingViewPreferenceDataKey: PreferenceKey {
        typealias Value = DraggingViewPreferenceData
        
        static var defaultValue = DraggingViewPreferenceData(position: nil, globalPositon: nil)
        
        static func reduce(value: inout DraggingViewPreferenceData, nextValue: () -> DraggingViewPreferenceData) {
            value = nextValue()
        }
    }
    
    struct DraggingView: View {
        var proxy: GeometryProxy
        var viewBulders: [BlockViewBuilderProtocol]
        var preference: BaseViewPreferenceData
        @State var position: Anchor<CGRect>?
        @State var globalPosition: CGRect = .zero
        
        init(proxy: GeometryProxy, viewBulders: [BlockViewBuilderProtocol], preference: BaseViewPreferenceData) {
            self.proxy = proxy
            self.viewBulders = viewBulders
            self.preference = preference
        }
        
        var body: some View {
            dragginView(proxy: proxy, viewBulders: viewBulders, preference: preference)
        }
        
        private func dragginView(proxy: GeometryProxy, viewBulders: [BlockViewBuilderProtocol], preference: BaseViewPreferenceData) -> some View {
            let dragginView = viewBulders.first(where: { viewBuilder in
                viewBuilder.id == preference.id
            })?.buildView()
            
            return Group {
                if preference.isActive {
                    dragginView
                        .anchorPreference(key: DraggingViewPreferenceDataKey.self, value: .bounds) {
                            DraggingViewPreferenceData(position: $0, globalPositon: self.globalPosition)
                    }
                    .saveBounds(viewId: 1)
                    .retrieveBounds(viewId: 1, $globalPosition)
                    .position(CGPoint(x: proxy[self.position ?? self.preference.position!].midX, y: proxy[self.position ?? self.preference.position!].midY))
                    .offset(x: preference.translation.width, y: preference.translation.height)
                    .onAppear {
                        self.position = self.preference.position
                    }
                    .onDisappear {
                        self.position = nil
                    }
                } else {
                    EmptyView()
                        .onAppear {
                            self.position = nil
                    }
                }
            }
        }
    }
    
    
    private func makeBlockView(for index: Int, in builders: [BlockViewBuilderProtocol]) -> some View {
        let rowViewBuilder = builders[index]
        
        return VStack(spacing: 0) {
            HStack {
                Spacer(minLength: 10)
                rowViewBuilder.buildView().modifier(ShowViewOnRectIntersect(blocksRects: self.$blocksRects, dragCoordinates: self.$dragCoordinates, index: index))
            }
        }
    }
    
    // Convert anchor drag to frame in current ccoordinates
    private func saveDraggingViewPostion(preference: DraggingViewPreferenceData) -> some View {
//        guard let position = preference.globalPositon else { return Color.clear }
        
        DispatchQueue.main.async {
            self.dragCoordinates = preference.globalPositon
        }
            
        return Color.clear
    }
    
    var loading: some View {
        Text("Loading...")
            .foregroundColor(.gray)
    }
}


struct VelocityOnIntersectViewBoundary: ViewModifier {
    @Binding var velocity: CGPoint
    @Environment(\.showViewFrames) private var showViewFrames
    
    private struct VelocityKey: PreferenceKey {
        
        static var defaultValue: CGPoint {
            .zero
        }
        
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value = nextValue()
        }
    }
    
    func body(content: Content) -> some View {
        return content
            .overlayPreferenceValue(DocumentView.DraggingViewPreferenceDataKey.self) { preference in
                GeometryReader { proxy in
                    self.obtainBoundary(proxy: proxy, preference: preference)
                }
        }
            .onPreferenceChange(VelocityKey.self) { velocity in
                self.velocity = velocity
        }
    }
    
    private func obtainBoundary(proxy: GeometryProxy, preference: DocumentView.DraggingViewPreferenceData) -> some View {
        var velocity = CGPoint(x: 0, y: 0)
        
        let frame = proxy.frame(in: .local)
        let upperBoundary = CGRect(origin: .zero, size: CGSize(width: frame.width, height: frame.height * 0.15))
        
        let bottomY = frame.maxY - frame.height * 0.15
        let bottomOrigin = CGPoint(x: frame.minX, y: bottomY)
        let bottomBoundary = CGRect(origin: bottomOrigin, size: CGSize(width: frame.width, height: frame.height * 0.15))
        
        if let anchorDragRect = preference.position {
            if upperBoundary.intersects(proxy[anchorDragRect]) {
                velocity = CGPoint(x: 0, y: -10)
            } else if bottomBoundary.intersects(proxy[anchorDragRect]) {
                velocity = CGPoint(x: 0, y: 10)
            }
        }
        
        return ZStack {
            Color.clear
            
            if showViewFrames {
                Rectangle()
                    .stroke(Color.green)
                    .frame(width: upperBoundary.width, height: upperBoundary.height)
                    .position(x: upperBoundary.midX, y: upperBoundary.midY)
                Rectangle()
                    .stroke(Color.blue)
                    .frame(width: bottomBoundary.width, height: bottomBoundary.height)
                    .position(x: bottomBoundary.midX, y: bottomBoundary.midY)
            }
        }
        .preference(key: VelocityKey.self, value: velocity)
    }
}


struct ShowViewOnRectIntersect: ViewModifier {
    @State private var showDivider: Bool = false
    @Binding var blocksRects: [CGRect]
    @Binding var dragCoordinates: CGRect?
    var index: Int
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
                .background(
                    GeometryReader { proxy in
                        self.obtainCoordinates(proxy: proxy)
                })
            DropDividerView().opacity(showDivider ? 1 : 0)
        }
    }
    
    private func obtainCoordinates(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            let frame = proxy.frame(in: .global)
            self.blocksRects[self.index] = frame
        }
        self.showContent(proxy: proxy, dragCoordinates: self.dragCoordinates)
        
        return Color.clear
    }
    
    private func showContent(proxy: GeometryProxy, dragCoordinates: CGRect?) {
        let rect1 = blocksRects[index]
        var rect2: CGRect = CGRect(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        
        if blocksRects.count > index + 1 {
            rect2 = blocksRects[index + 1]
        }
        
        // get min x
        let minX = min(rect1.minX, rect2.minX)
        // get max x
        let maxX = max(rect1.maxX, rect2.maxX)
        // get min y
        let minY = rect1.midY
        // get max y
        let maxY = rect2.midY
        
        let dropArea = CGRect.frame(from: CGPoint(x: minX, y: minY), to: CGPoint(x: maxX, y: maxY))
        
        if let dragCoordinates = dragCoordinates, dropArea.contains(dragCoordinates.origin) {
//            print("divider: \(dropArea.minY) : \(dropArea.maxY) : \(dragCoordinates.minY)")
            DispatchQueue.main.async {
                self.showDivider = true
            }
        } else {
//            print("divider: hide")
            DispatchQueue.main.async {
                self.showDivider = false
            }
        }
    }
}

struct DropDividerView: View {
    
    var body: some View {
        Rectangle()
            .foregroundColor(Color.blue)
            .frame(height: 4)
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = DocumentViewModel(documentId: "1")
        
        return DocumentView(viewModel: viewModel)
    }
    
}
