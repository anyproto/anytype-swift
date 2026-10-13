import Foundation
import AnytypeCore

/// Lossless JSON value for pubsub payloads. Keeps object key order and number lexemes,
/// which `JSONSerialization` and `JSONDecoder` both lose. Agent `data` is shown key by key
/// in source order and copied back out exactly as received.
enum ActivityJSON: Equatable, Sendable {
    case null
    case bool(Bool)
    case number(String)
    case string(String)
    case array([ActivityJSON])
    case object([ActivityJSONField])
}

struct ActivityJSONField: Equatable, Sendable {
    let key: String
    var value: ActivityJSON
}

extension ActivityJSON {

    /// Pubsub app payload limit; larger payloads are refused by the middleware anyway.
    static let maxPayloadBytes = 65_508
    static let maxDepth = 128

    static func parse(_ data: Data) -> ActivityJSON? {
        guard data.count <= maxPayloadBytes else { return nil }
        var parser = ActivityJSONParser(bytes: Array(data))
        return parser.parseDocument()
    }

    static func parse(_ string: String) -> ActivityJSON? {
        parse(Data(string.utf8))
    }

    subscript(key: String) -> ActivityJSON? {
        guard case .object(let fields) = self else { return nil }
        return fields.first { $0.key == key }?.value
    }

    var fields: [ActivityJSONField]? {
        guard case .object(let fields) = self else { return nil }
        return fields
    }

    var stringValue: String? {
        guard case .string(let value) = self else { return nil }
        return value
    }

    var nonEmptyString: String? {
        guard let value = stringValue, value.isNotEmpty else { return nil }
        return value
    }

    var boolValue: Bool? {
        guard case .bool(let value) = self else { return nil }
        return value
    }

    /// Status `data` is retained only when it carries something: `null`, `{}`, `[]` and `""` don't.
    var qualifiesForRetention: Bool {
        switch self {
        case .null:
            false
        case .bool, .number:
            true
        case .string(let value):
            value.isNotEmpty
        case .array(let values):
            values.isNotEmpty
        case .object(let fields):
            fields.isNotEmpty
        }
    }

    /// Shallow merge for same-call updates: top-level fields present in `update` replace the old
    /// values whole (including `null`), absent ones are kept. Existing keys keep their position.
    func mergingTopLevel(_ update: ActivityJSON) -> ActivityJSON {
        guard case .object(var merged) = self, case .object(let updateFields) = update else {
            return update
        }
        for field in updateFields {
            if let index = merged.firstIndex(where: { $0.key == field.key }) {
                merged[index].value = field.value
            } else {
                merged.append(field)
            }
        }
        return .object(merged)
    }

    /// One-line value preview: literal scalars, "Object(n)" / "Array(n)" for containers.
    var preview: String {
        switch self {
        case .null:
            "null"
        case .bool(let value):
            value ? "true" : "false"
        case .number(let lexeme):
            lexeme
        case .string(let value):
            value
        case .array(let values):
            "Array(\(values.count))"
        case .object(let fields):
            "Object(\(fields.count))"
        }
    }

    func serialized(pretty: Bool = false, sortedKeys: Bool = false) -> String {
        var output = ""
        ActivityJSONWriter(pretty: pretty, sortedKeys: sortedKeys).write(self, indent: 0, into: &output)
        return output
    }
}

// MARK: - Writer

private struct ActivityJSONWriter {
    let pretty: Bool
    let sortedKeys: Bool

    func write(_ value: ActivityJSON, indent: Int, into output: inout String) {
        switch value {
        case .null:
            output += "null"
        case .bool(let flag):
            output += flag ? "true" : "false"
        case .number(let lexeme):
            output += lexeme
        case .string(let string):
            writeString(string, into: &output)
        case .array(let values):
            guard values.isNotEmpty else {
                output += "[]"
                return
            }
            output += "["
            for (index, element) in values.enumerated() {
                if index > 0 { output += "," }
                newline(indent: indent + 1, into: &output)
                write(element, indent: indent + 1, into: &output)
            }
            newline(indent: indent, into: &output)
            output += "]"
        case .object(let fields):
            guard fields.isNotEmpty else {
                output += "{}"
                return
            }
            let ordered = sortedKeys ? fields.sorted { $0.key < $1.key } : fields
            output += "{"
            for (index, field) in ordered.enumerated() {
                if index > 0 { output += "," }
                newline(indent: indent + 1, into: &output)
                writeString(field.key, into: &output)
                output += pretty ? ": " : ":"
                write(field.value, indent: indent + 1, into: &output)
            }
            newline(indent: indent, into: &output)
            output += "}"
        }
    }

    private func newline(indent: Int, into output: inout String) {
        guard pretty else { return }
        output += "\n" + String(repeating: "  ", count: indent)
    }

    private func writeString(_ string: String, into output: inout String) {
        output += "\""
        for scalar in string.unicodeScalars {
            switch scalar {
            case "\"":
                output += "\\\""
            case "\\":
                output += "\\\\"
            case "\n":
                output += "\\n"
            case "\r":
                output += "\\r"
            case "\t":
                output += "\\t"
            case "\u{08}":
                output += "\\b"
            case "\u{0C}":
                output += "\\f"
            default:
                if scalar.value < 0x20 {
                    output += String(format: "\\u%04x", scalar.value)
                } else {
                    output.unicodeScalars.append(scalar)
                }
            }
        }
        output += "\""
    }
}

// MARK: - Parser

private struct ActivityJSONParser {

    private let bytes: [UInt8]
    private var index = 0

    init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    mutating func parseDocument() -> ActivityJSON? {
        skipWhitespace()
        guard let value = parseValue(depth: 0) else { return nil }
        skipWhitespace()
        return index == bytes.count ? value : nil
    }

    private func peek() -> UInt8? {
        index < bytes.count ? bytes[index] : nil
    }

    private mutating func skipWhitespace() {
        while let byte = peek(), byte == 0x20 || byte == 0x0A || byte == 0x0D || byte == 0x09 {
            index += 1
        }
    }

    private mutating func parseValue(depth: Int) -> ActivityJSON? {
        guard depth < ActivityJSON.maxDepth, let byte = peek() else { return nil }
        switch byte {
        case UInt8(ascii: "{"):
            return parseObject(depth: depth + 1)
        case UInt8(ascii: "["):
            return parseArray(depth: depth + 1)
        case UInt8(ascii: "\""):
            return parseString().map { .string($0) }
        case UInt8(ascii: "t"):
            return consume("true") ? .bool(true) : nil
        case UInt8(ascii: "f"):
            return consume("false") ? .bool(false) : nil
        case UInt8(ascii: "n"):
            return consume("null") ? .null : nil
        default:
            return parseNumber().map { .number($0) }
        }
    }

    private mutating func parseObject(depth: Int) -> ActivityJSON? {
        index += 1
        var fields: [ActivityJSONField] = []
        var positions: [String: Int] = [:]
        skipWhitespace()
        if peek() == UInt8(ascii: "}") {
            index += 1
            return .object(fields)
        }
        while true {
            skipWhitespace()
            guard peek() == UInt8(ascii: "\""), let key = parseString() else { return nil }
            skipWhitespace()
            guard peek() == UInt8(ascii: ":") else { return nil }
            index += 1
            skipWhitespace()
            guard let value = parseValue(depth: depth) else { return nil }
            // Duplicate key: the last value wins, the first position stays
            if let position = positions[key] {
                fields[position].value = value
            } else {
                positions[key] = fields.count
                fields.append(ActivityJSONField(key: key, value: value))
            }
            skipWhitespace()
            switch peek() {
            case UInt8(ascii: ","):
                index += 1
            case UInt8(ascii: "}"):
                index += 1
                return .object(fields)
            default:
                return nil
            }
        }
    }

    private mutating func parseArray(depth: Int) -> ActivityJSON? {
        index += 1
        var values: [ActivityJSON] = []
        skipWhitespace()
        if peek() == UInt8(ascii: "]") {
            index += 1
            return .array(values)
        }
        while true {
            skipWhitespace()
            guard let value = parseValue(depth: depth) else { return nil }
            values.append(value)
            skipWhitespace()
            switch peek() {
            case UInt8(ascii: ","):
                index += 1
            case UInt8(ascii: "]"):
                index += 1
                return .array(values)
            default:
                return nil
            }
        }
    }

    private mutating func parseString() -> String? {
        index += 1
        var buffer: [UInt8] = []
        while let byte = peek() {
            index += 1
            switch byte {
            case UInt8(ascii: "\""):
                // Invalid UTF-8 makes the payload malformed rather than silently altered
                return String(bytes: buffer, encoding: .utf8)
            case UInt8(ascii: "\\"):
                guard let escaped = peek() else { return nil }
                index += 1
                switch escaped {
                case UInt8(ascii: "\""), UInt8(ascii: "\\"), UInt8(ascii: "/"):
                    buffer.append(escaped)
                case UInt8(ascii: "b"):
                    buffer.append(0x08)
                case UInt8(ascii: "f"):
                    buffer.append(0x0C)
                case UInt8(ascii: "n"):
                    buffer.append(0x0A)
                case UInt8(ascii: "r"):
                    buffer.append(0x0D)
                case UInt8(ascii: "t"):
                    buffer.append(0x09)
                case UInt8(ascii: "u"):
                    guard let scalar = parseUnicodeEscape() else { return nil }
                    buffer.append(contentsOf: Array(String(Character(scalar)).utf8))
                default:
                    return nil
                }
            default:
                // Raw control characters are not allowed inside JSON strings
                guard byte >= 0x20 else { return nil }
                buffer.append(byte)
            }
        }
        return nil
    }

    /// Reads the 4 hex digits after `\u`, joining a surrogate pair when one follows.
    /// A lone surrogate becomes U+FFFD.
    private mutating func parseUnicodeEscape() -> Unicode.Scalar? {
        guard let first = parseHex4() else { return nil }
        if (0xD800...0xDBFF).contains(first) {
            let save = index
            if consume("\\u"), let second = parseHex4(), (0xDC00...0xDFFF).contains(second) {
                let combined = 0x10000 + ((UInt32(first) - 0xD800) << 10) + (UInt32(second) - 0xDC00)
                return Unicode.Scalar(combined)
            }
            index = save
            return Unicode.Scalar(0xFFFD)
        }
        if (0xDC00...0xDFFF).contains(first) {
            return Unicode.Scalar(0xFFFD)
        }
        return Unicode.Scalar(UInt32(first))
    }

    private mutating func parseHex4() -> UInt16? {
        guard index + 4 <= bytes.count else { return nil }
        var value: UInt16 = 0
        for _ in 0..<4 {
            let byte = bytes[index]
            let digit: UInt16
            switch byte {
            case UInt8(ascii: "0")...UInt8(ascii: "9"):
                digit = UInt16(byte - UInt8(ascii: "0"))
            case UInt8(ascii: "a")...UInt8(ascii: "f"):
                digit = UInt16(byte - UInt8(ascii: "a") + 10)
            case UInt8(ascii: "A")...UInt8(ascii: "F"):
                digit = UInt16(byte - UInt8(ascii: "A") + 10)
            default:
                return nil
            }
            value = value * 16 + digit
            index += 1
        }
        return value
    }

    /// Validates the JSON number grammar and returns the original lexeme.
    private mutating func parseNumber() -> String? {
        let start = index
        if peek() == UInt8(ascii: "-") { index += 1 }
        guard let first = peek(), isDigit(first) else { return nil }
        index += 1
        if first != UInt8(ascii: "0") {
            while let byte = peek(), isDigit(byte) { index += 1 }
        }
        if peek() == UInt8(ascii: ".") {
            index += 1
            guard let byte = peek(), isDigit(byte) else { return nil }
            while let byte = peek(), isDigit(byte) { index += 1 }
        }
        if let byte = peek(), byte == UInt8(ascii: "e") || byte == UInt8(ascii: "E") {
            index += 1
            if let sign = peek(), sign == UInt8(ascii: "+") || sign == UInt8(ascii: "-") { index += 1 }
            guard let byte = peek(), isDigit(byte) else { return nil }
            while let byte = peek(), isDigit(byte) { index += 1 }
        }
        return String(decoding: bytes[start..<index], as: UTF8.self)
    }

    private func isDigit(_ byte: UInt8) -> Bool {
        byte >= UInt8(ascii: "0") && byte <= UInt8(ascii: "9")
    }

    private mutating func consume(_ literal: String) -> Bool {
        let literalBytes = Array(literal.utf8)
        guard index + literalBytes.count <= bytes.count,
              Array(bytes[index..<(index + literalBytes.count)]) == literalBytes else { return false }
        index += literalBytes.count
        return true
    }
}
