//
//  DocumentView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI
import Combine


struct DocumentView: View {
    @ObservedObject var viewModel: DocumentViewModel
    
    @Environment(\.showViewFrames) private var showViewFrames
    @State private var scrollViewOffset: CGPoint = .zero
    @State private var scrollTimer = ScrollTimer()
    
    @State private var possibleBlockIdForObtainingDrop: Int?
    @State private var draggingAnchor: Anchor<CGRect>?
    
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
    
    var loading: some View {
        Text("Loading...")
            .foregroundColor(.gray)
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
        .scrollViewOffset(offset: self.scrollViewOffset)
        .modifier(DraggingView(viewBulders: viewBulders))
        .onPreferenceChange(DraggingViewCoordinatePreferenceKey.self) { preference in
            self.draggingAnchor = preference.position
        }
        .overlayPreferenceValue(SaveBlockAnchorPreferenceKey.self) { preferences in
            GeometryReader { proxy in
                return self.buildDroppingArea(proxy: proxy, preferences: preferences)
            }
        }
            //        .modifier(ViewBoundary(dragCoordinates: draggingPreference.position) { boundary in
            //            switch boundary {
            //            case .top(let intersectionRate):
            //                print("upperBoundary")
            //                self.scrollTimer.timing = 0.1 / intersectionRate
            //            case .bottom(let intersectionRate):
            //                print("bottomBoundary")
            //                self.scrollTimer.timing = 0.1 / intersectionRate
            //            case .neither:
            //                self.scrollTimer.timing = 0.0
            //                print("neither")
            //            }
            //        })
//            .onAppear {
//                self.scrollTimer.fireTimer = {
//                    self.scrollViewOffset += CGPoint(x: self.scrollViewOffset.x, y: 1)
//                }
//        }
        .environment(\.showViewFrames, true)
    }
    
    private func makeBlockView(for index: Int, in builders: [BlockViewBuilderProtocol]) -> some View {
        let rowViewBuilder = builders[index]
        
        return VStack(spacing: 0) {
            HStack {
                Spacer(minLength: 10)
                rowViewBuilder.buildView()
                    .anchorPreference(key: SaveBlockAnchorPreferenceKey.self, value: .bounds) { anchor in
                        [SaveBlockAnchorPreferenceData(viewIdx: index, bounds: anchor)]
                }
                    //                    .modifier(SaveDroppableArea(draggingPreference: self.$draggingPreference, index: index))
                    .modifier(ShowDroppableArea(viewId: index, possibleBlockIdForObtainingDrop: $possibleBlockIdForObtainingDrop))
                
            }
        }
    }
}

private extension DocumentView {
    private struct SaveBlockAnchorPreferenceData {
        let viewIdx: Int
        let bounds: Anchor<CGRect>
    }
    
    private struct SaveBlockAnchorPreferenceKey: PreferenceKey {
        typealias Value = [SaveBlockAnchorPreferenceData]
        
        static var defaultValue: [SaveBlockAnchorPreferenceData] = []
        
        static func reduce(value: inout [SaveBlockAnchorPreferenceData], nextValue: () -> [SaveBlockAnchorPreferenceData]) {
            value.append(contentsOf: nextValue())
        }
    }
    
    private func buildDroppingArea(proxy: GeometryProxy, preferences: [SaveBlockAnchorPreferenceData]) -> some View {
        for (i, preference) in preferences.enumerated() {
            let rect1 = proxy[preference.bounds]
            
            var rect2: CGRect = CGRect(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            
            if preferences.count > i + 1 {
                let preference = preferences[i + 1]
                rect2 = proxy[preference.bounds]
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
            

            if let dragCoordinates = draggingAnchor,
                dropArea.contains(proxy[dragCoordinates].origin) {
                DispatchQueue.main.async {
//                    print("id: \(preference.viewIdx)")
                    self.possibleBlockIdForObtainingDrop =  preference.viewIdx
                }
            }
        }
        return Color.clear
    }
}


private extension DocumentView {
    
    struct DraggingViewCoordinatePreferenceData: Identifiable, Equatable {
        static func == (lhs: DocumentView.DraggingViewCoordinatePreferenceData, rhs: DocumentView.DraggingViewCoordinatePreferenceData) -> Bool {
            lhs.id == rhs.id && lhs.translation == rhs.translation
        }
        
        var id: String? = nil
        var position: Anchor<CGRect>? = nil
        var translation: CGSize = .zero
    }


    struct DraggingViewCoordinatePreferenceKey: PreferenceKey {
        typealias Value = DraggingViewCoordinatePreferenceData
        
        static var defaultValue = DraggingViewCoordinatePreferenceData()
        
        static func reduce(value: inout DraggingViewCoordinatePreferenceData, nextValue: () -> DraggingViewCoordinatePreferenceData) {
            print("DraggingViewCoordinatePreferenceKey")
            value = nextValue()
        }
    }
    
    // TODO: Move to PasteDraggingView struct
    struct DraggingView: ViewModifier {
        var viewBulders: [BlockViewBuilderProtocol]
        @State var initialPosition: Anchor<CGRect>? // We need it due to original postion of dragging view could change (for example when we scrolling)
        
        func body(content: Content) -> some View {
            return content.overlayPreferenceValue(DraggingViewPreferenceKey.self) { preference in
                self.buildDraggingView(preference: preference)
            }
        }
        
        private func buildDraggingView(preference: DraggingViewPreferenceData) -> some View {
            let dragginView = viewBulders.first(where: { viewBuilder in
                viewBuilder.id == preference.id
            })?.buildView()
            
            return Group {
                if preference.isActive {
                    GeometryReader { proxy in
                        dragginView
                            .anchorPreference(key: DraggingViewCoordinatePreferenceKey.self, value: .bounds) {
                                return DraggingViewCoordinatePreferenceData(id: preference.id, position: $0, translation: preference.translation)
                        } // save dragging view anchor
                            .position(CGPoint(x: proxy[self.initialPosition ?? preference.position!].midX, y: proxy[self.initialPosition ?? preference.position!].midY))
                            .offset(x: preference.translation.width, y: preference.translation.height)
                    }
                    .opacity(0.5)
                    .colorInvert()
                    .onAppear {
                        self.initialPosition = preference.position
                    }
                    .onDisappear {
                        self.initialPosition = nil
                    }
                } else {
                    Color.clear
                        .onAppear {
                            self.initialPosition = nil
                    }
                }
            }
        }
        
        func dragCoord(proxy: GeometryProxy, preference: DraggingViewPreferenceData) -> some View {
            if let dragCoordinates = preference.position {
                print("dragCoordinates 1 \(proxy[dragCoordinates].origin)")
            }
            return Color.clear
        }
    }
}


struct ViewBoundary: ViewModifier {
    enum Boundary {
        case top(intersectionRate: Double), bottom(intersectionRate: Double)
        case neither
    }
    @Environment(\.showViewFrames) private var showViewFrames
    
    var dragCoordinates: Anchor<CGRect>?
    var onBoundary: (_ boundary: Boundary) -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { proxy in
                    self.obtainBoundary(proxy: proxy)
            })
    }
    
    private func obtainBoundary(proxy: GeometryProxy) -> some View {
        let frame = proxy.frame(in: .local)
        let upperBoundary = CGRect(origin: .zero, size: CGSize(width: frame.width, height: frame.height * 0.15))
        
        let bottomY = frame.maxY - frame.height * 0.15
        let bottomOrigin = CGPoint(x: frame.minX, y: bottomY)
        let bottomBoundary = CGRect(origin: bottomOrigin, size: CGSize(width: frame.width, height: frame.height * 0.15))
        
        if let anchorDragRect = dragCoordinates {
            if upperBoundary.intersects(proxy[anchorDragRect]) {
                let intersection = upperBoundary.intersection(proxy[anchorDragRect])
                let YIntersectionRate = intersection.height / upperBoundary.height
                onBoundary(.top(intersectionRate: Double(YIntersectionRate)))
            } else if bottomBoundary.intersects(proxy[anchorDragRect]) {
                let intersection = bottomBoundary.intersection(proxy[anchorDragRect])
                let YIntersectionRate = intersection.height / upperBoundary.height
                onBoundary(.bottom(intersectionRate: Double(YIntersectionRate)))
            } else {
                onBoundary(.neither)
            }
        } else {
            onBoundary(.neither)
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
    }
}

struct ShowDroppableArea: ViewModifier {
    var viewId: Int
    @Binding var possibleBlockIdForObtainingDrop: Int?
    
    func body(content: Content) -> some View {
        return VStack(spacing: 0) {
            content
            DropDividerView().opacity(viewId == possibleBlockIdForObtainingDrop ? 1.0 : 0.0)
        }
    }
    
    private struct DropDividerView: View {
        var body: some View {
            Rectangle()
                .foregroundColor(Color.blue)
                .frame(height: 4)
        }
    }
}


// MARK - Scroll timer for dragging view near upper/bottom scroll view edges

extension DocumentView {
    private static var scrollModelInst: Int = 0
    
    fileprivate class ScrollTimer {
        private var numberOfInstance: Int = 0
        
        var fireTimer: (() -> Void)?
        
        private var timer = Timer.publish(every: 1, on: .main, in: .common)
        private var cancellableTimer: AnyCancellable?
        
        var timing: TimeInterval = .zero {
            didSet {
                guard oldValue != timing else { return }
                
                self.cancellableTimer?.cancel()
                print("cancel timer")
                
                if timing != 0 {
                    timer = Timer.publish(every: abs(timing), on: .main, in: .common)
                    cancellableTimer = timer.autoconnect().sink { [weak self] _ in
                        self?.fireTimer?()
                    }
                    print("start timer")
                }
            }
        }
        
        init() {
            scrollModelInst += 1
            numberOfInstance = scrollModelInst
            print("init \(numberOfInstance)")
        }
        
        deinit {
            print("deinit \(numberOfInstance)")
            self.cancellableTimer?.cancel()
        }
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = DocumentViewModel(documentId: "1")
        
        return DocumentView(viewModel: viewModel)
    }
    
}
