import SwiftUI

// Source: https://betterprogramming.pub/custom-paging-ui-in-swiftui-13f1347cf529
struct AnytypeIndexView: View {
  
  // MARK: - Public Properties
  
  let numberOfPages: Int
  let currentIndex: Int
  
  
  // MARK: - Drawing Constants
  
  private let circleSize: CGFloat = 8
  private let circleSpacing: CGFloat = 12
  
  private let primaryColor = Color.Text.primary
  private let secondaryColor = Color.Text.primary.opacity(0.2)
  
  private let smallScale: CGFloat = 0.8
  
  
  // MARK: - Body
  
  var body: some View {
    HStack(spacing: circleSpacing) {
        ForEach(0..<numberOfPages, id: \.self) { index in // 1
        if shouldShowIndex(index) {
          Circle()
            .fill(currentIndex == index ? primaryColor : secondaryColor) // 2
            .scaleEffect(currentIndex == index ? 1 : smallScale)
            
            .frame(width: circleSize, height: circleSize)
       
            .transition(AnyTransition.opacity.combined(with: .scale)) // 3
            
            .id(index) // 4
        }
      }
    }.setZeroOpacity(numberOfPages <= 1)
  }
  
  
  // MARK: - Private Methods
  
  func shouldShowIndex(_ index: Int) -> Bool {
    ((currentIndex - 1)...(currentIndex + 1)).contains(index)
  }
}
