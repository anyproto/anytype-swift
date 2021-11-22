import SwiftUI

struct FlowCheckboxRelationView: View {
    let isChecked: Bool
    
    var body: some View {
        isChecked ? Image.Relations.checkboxChecked : Image.Relations.checkboxUnchecked
    }
}

struct FlowCheckboxRelationView_Previews: PreviewProvider {
    static var previews: some View {
        CheckboxRelationView(isChecked: true)
    }
}
