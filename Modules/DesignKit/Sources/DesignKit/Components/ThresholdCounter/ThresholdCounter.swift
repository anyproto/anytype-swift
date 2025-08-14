import SwiftUI


public struct ThresholdCounter: View {
    public let threshold: Int
    public let visibilityCount: Int
    
    public var count: Int
    
    public init(usecase: ThresholdCounterUsecase, count: Int) {
        self.threshold = usecase.threshold
        self.visibilityCount = usecase.visibilityCount
        self.count = count
    }
    
    public var body: some View {
        HStack {
            Spacer()
            if count >= threshold - visibilityCount {
                AnytypeText("\(threshold - count)", style: .calloutRegular)
                    .foregroundColor(count <= threshold ? .Text.secondary : .Pure.red)
                    .contentTransition(.numericText())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    
            }
        }
        .animation(.default, value: count)
    }
}
