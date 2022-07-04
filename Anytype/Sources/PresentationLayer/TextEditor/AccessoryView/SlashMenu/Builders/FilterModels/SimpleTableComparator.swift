import Foundation

struct SimpleTableSlashMenuComparator {
    static func matchDefaultTable(slashAction: SlashAction, inputString: String) -> SlashActionFilterMatch? {
        let tableString = "table"

        guard inputString.contains(tableString) else {
            return SlashMenuComparator.match(slashAction: slashAction, string: inputString)
        }

        guard let rangeOfPath = inputString.range(of: tableString) else {
            return .init(action: slashAction, filterMatch: .fullTitle)
        }

        let nXmString = inputString.replacingCharacters(in: rangeOfPath, with: "")

        let numberParts = nXmString.split(separator: "x")

        guard let firstPart = numberParts[safe: 0],
              let firstNumber = Int(firstPart) else {
            return .init(action: slashAction, filterMatch: .titleSubstring)
        }

        let range = 1...25

        guard range ~= firstNumber else {
            return .init(action: slashAction, filterMatch: .titleSubstring)
        }

        guard let secondPart = numberParts[safe: 1],
              let secondNumber = Int(secondPart),
              range ~= secondNumber  else {
            return .init(action: .other(.table(rowsCount: firstNumber, columnsCount: 3)), filterMatch: .fullTitle)
        }

        return .init(
            action: .other(.table(rowsCount: firstNumber, columnsCount: secondNumber)),
            filterMatch: .fullTitle
        )
    }
}
