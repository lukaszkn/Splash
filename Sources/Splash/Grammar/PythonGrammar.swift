import Foundation

public struct PythonGrammar: Grammar {
    public var delimiters: CharacterSet
    public var syntaxRules: [SyntaxRule]

    public init() {
        delimiters = .whitespacesAndNewlines

        syntaxRules = [
            CommentRule(),
            StringRule(),
            NumberRule(),
            KeywordRule(),
            OperatorRule()
        ]
    }

    struct CommentRule: SyntaxRule {
        var tokenType: TokenType { return .comment }

        func matches(_ segment: Segment) -> Bool {
            if segment.tokens.current.hasPrefix("#") {
                return true
            }

            if segment.tokens.onSameLine.contains(anyOf: "#", "\"\"\"") {
                return true
            }
            
            return false
        }
    }

    struct StringRule: SyntaxRule {
        var tokenType: TokenType { return .string }

        func matches(_ segment: Segment) -> Bool {
            let currentToken = segment.tokens.current
            return currentToken.hasPrefix("'") || currentToken.hasPrefix("\"")
        }
    }

    struct NumberRule: SyntaxRule {
        var tokenType: TokenType { return .number }

        func matches(_ segment: Segment) -> Bool {
            let currentToken = segment.tokens.current
            return currentToken.isNumber
        }
    }

    struct KeywordRule: SyntaxRule {
        var tokenType: TokenType { return .keyword }

        static let keywords: Set<String> = [
            "False", "None", "True", "and", "as", "assert",
            "async", "await", "break", "class", "continue",
            "def", "del", "elif", "else", "except", "finally",
            "for", "from", "global", "if", "import", "in",
            "is", "lambda", "nonlocal", "not", "or", "pass",
            "raise", "return", "try", "while", "with", "yield"
        ]

        func matches(_ segment: Segment) -> Bool {
            let currentToken = segment.tokens.current
            return KeywordRule.keywords.contains(currentToken)
        }
    }

    struct OperatorRule: SyntaxRule {
        var tokenType: TokenType { return .custom("operator") }

        static let operators: Set<String> = [
            "+", "-", "*", "/", "//", "%", "**", "@",
            "<<", ">>", "&", "|", "^", "~", "<", ">", "<=",
            ">=", "==", "!=", "is", "is not", "in", "not in",
            "and", "or", "not", "=", "+=", "-=", "*=", "/=",
            "//=", "%=", "**=", "&=", "|=", "^=", "<<=", ">>=",
            "~=", "===", "!==", "<>", "!<", ">", "<>", ">=", "<=",
            "@=", ":=", "->", "...", "..", "..."
        ]

        func matches(_ segment: Segment) -> Bool {
            let currentToken = segment.tokens.current
            return OperatorRule.operators.contains(currentToken)
        }
    }
}
