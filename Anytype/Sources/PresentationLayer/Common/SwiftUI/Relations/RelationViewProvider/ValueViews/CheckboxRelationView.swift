import SwiftUI

struct CheckboxRelationView: View {
    let isChecked: Bool
    
    var body: some View {
        isChecked ? Image.Relations.checkboxChecked : Image.Relations.checkboxUnchecked
    }
}

struct CheckboxRelationView_Previews: PreviewProvider {
    static var previews: some View {
        CheckboxRelationView(isChecked: true)
    }
}
