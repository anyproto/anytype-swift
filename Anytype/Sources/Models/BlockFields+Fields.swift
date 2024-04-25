import Foundation
import Services

extension BlockFields {
    
    var codeLanguage: CodeLanguage {
        CodeLanguage.create(
            middleware: self[CodeBlockFields.FieldName.codeLanguage]?.stringValue
        )
    }
}
