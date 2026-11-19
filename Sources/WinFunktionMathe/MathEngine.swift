import Foundation

enum MathError: Error, CustomStringConvertible {
    case syntax(String)
    case unknownFunction(String)
    case divisionByZero

    var description: String {
        switch self {
        case .syntax(let msg): return "Syntaxfehler: \(msg)"
        case .unknownFunction(let name): return "Unbekannte Funktion: \(name)"
        case .divisionByZero: return "Division durch Null"
        }
    }
}

/// Rekursiver Abstiegs-Parser und Auswerter für mathematische Ausdrücke
/// mit Klammern, ^, Funktionen (sin, cos, tan, sqrt, ln, log, exp, abs),
/// den Konstanten pi und e sowie der Variablen x.
enum MathEngine {

    static func evaluate(_ input: String, x: Double = 0) throws -> Double {
        let normalized = input
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: "−", with: "-")
        let tokens = try tokenize(normalized)
        var parser = Parser(tokens: tokens, x: x)
        let value = try parser.parseExpression()
        if !parser.isAtEnd {
            throw MathError.syntax("unerwartetes Zeichen am Ende")
        }
        return value
    }

    // MARK: Tokenizer

    private enum Token: Equatable {
        case number(Double)
        case identifier(String)
        case op(Character)
        case lparen
        case rparen
    }

    private static func tokenize(_ s: String) throws -> [Token] {
        var tokens: [Token] = []
        var chars = Array(s)
        var i = 0
        while i < chars.count {
            let c = chars[i]
            if c.isWhitespace { i += 1; continue }
            if c.isNumber || c == "." {
                var j = i
                var text = ""
                while j < chars.count, chars[j].isNumber || chars[j] == "." {
                    text.append(chars[j])
                    j += 1
                }
                guard let value = Double(text) else { throw MathError.syntax("ungültige Zahl '\(text)'") }
                tokens.append(.number(value))
                i = j
            } else if c.isLetter {
                var j = i
                var text = ""
                while j < chars.count, chars[j].isLetter || chars[j].isNumber {
                    text.append(chars[j])
                    j += 1
                }
                tokens.append(.identifier(text.lowercased()))
                i = j
            } else if c == "+" || c == "-" || c == "*" || c == "/" || c == "^" {
                tokens.append(.op(c))
                i += 1
            } else if c == "(" {
                tokens.append(.lparen)
                i += 1
            } else if c == ")" {
                tokens.append(.rparen)
                i += 1
            } else {
                throw MathError.syntax("Zeichen '\(String(c))' nicht erlaubt")
            }
        }
        _ = chars.removeAll()
        guard !tokens.isEmpty else { throw MathError.syntax("leerer Ausdruck") }
        return tokens
    }

    // MARK: Parser

    private struct Parser {
        let tokens: [Token]
        let x: Double
        var pos = 0

        var isAtEnd: Bool { pos >= tokens.count }

        mutating func parseExpression() throws -> Double {
            var value = try parseTerm()
            while pos < tokens.count {
                switch tokens[pos] {
                case .op(let c) where c == "+" || c == "-":
                    pos += 1
                    let rhs = try parseTerm()
                    if c == "+" { value += rhs } else { value -= rhs }
                default:
                    return value
                }
            }
            return value
        }

        mutating func parseTerm() throws -> Double {
            var value = try parseUnary()
            while pos < tokens.count {
                switch tokens[pos] {
                case .op(let c) where c == "*" || c == "/":
                    pos += 1
                    let rhs = try parseUnary()
                    if c == "*" {
                        value *= rhs
                    } else {
                        if rhs == 0 { throw MathError.divisionByZero }
                        value /= rhs
                    }
                default:
                    return value
                }
            }
            return value
        }

        mutating func parseUnary() throws -> Double {
            if pos < tokens.count, case .op(let c) = tokens[pos], c == "-" {
                pos += 1
                return -(try parseUnary())
            }
            if pos < tokens.count, case .op(let c) = tokens[pos], c == "+" {
                pos += 1
                return try parseUnary()
            }
            return try parsePower()
        }

        mutating func parsePower() throws -> Double {
            let base = try parseAtom()
            if pos < tokens.count, case .op("^") = tokens[pos] {
                pos += 1
                let exponent = try parseUnary()
                return pow(base, exponent)
            }
            return base
        }

        mutating func parseAtom() throws -> Double {
            guard pos < tokens.count else { throw MathError.syntax("Ausdruck endet unerwartet") }
            switch tokens[pos] {
            case .number(let v):
                pos += 1
                return v
            case .lparen:
                pos += 1
                let value = try parseExpression()
                guard pos < tokens.count, case .rparen = tokens[pos] else {
                    throw MathError.syntax("')' erwartet")
                }
                pos += 1
                return value
            case .identifier(let name):
                pos += 1
                switch name {
                case "pi": return Double.pi
                case "e": return M_E
                case "x":
                    return x
                default:
                    guard pos < tokens.count, case .lparen = tokens[pos] else {
                        if name == "x" { return x }
                        throw MathError.unknownFunction(name)
                    }
                    pos += 1
                    let arg = try parseExpression()
                    guard pos < tokens.count, case .rparen = tokens[pos] else {
                        throw MathError.syntax("')' erwartet")
                    }
                    pos += 1
                    switch name {
                    case "sin": return sin(arg)
                    case "cos": return cos(arg)
                    case "tan": return tan(arg)
                    case "asin": return asin(arg)
                    case "acos": return acos(arg)
                    case "atan": return atan(arg)
                    case "sqrt": return sqrt(arg)
                    case "abs": return abs(arg)
                    case "ln": return log(arg)
                    case "log": return log10(arg)
                    case "exp": return exp(arg)
                    default: throw MathError.unknownFunction(name)
                    }
                }
            case .op, .rparen:
                throw MathError.syntax("unerwartetes Zeichen")
            }
        }
    }
}
