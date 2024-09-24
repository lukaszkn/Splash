//
//  KotlinGrammar.swift
//  
//
//  Created by Dana Buehre on 1/7/24.
//

import Foundation

public struct KotlinGrammar: Grammar {
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
            let currentToken = segment.tokens.current
            return currentToken.hasPrefix("//") || currentToken.hasPrefix("/*")
        }
    }

    struct StringRule: SyntaxRule {
        var tokenType: TokenType { return .string }

        func matches(_ segment: Segment) -> Bool {
            let currentToken = segment.tokens.current
            return currentToken.hasPrefix("\"") || currentToken.hasPrefix("\"\"\"")
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
            "abstract", "annotation", "as", "break", "by", "catch",
            "class", "companion", "const", "constructor", "continue",
            "crossinline", "data", "delegate", "do", "dynamic", "else",
            "enum", "expect", "external", "false", "final", "finally",
            "for", "fun", "get", "if", "import", "in", "infix", "init",
            "inline", "inner", "interface", "internal", "is", "it",
            "lateinit", "noinline", "null", "object", "open", "operator",
            "out", "override", "package", "private", "protected", "public",
            "reified", "return", "sealed", "set", "super", "suspend", "tailrec",
            "this", "throw", "true", "try", "typealias", "typeof", "val",
            "var", "when", "where", "while"
        ]

        func matches(_ segment: Segment) -> Bool {
            let currentToken = segment.tokens.current
            return KeywordRule.keywords.contains(currentToken)
        }
    }

    struct OperatorRule: SyntaxRule {
        var tokenType: TokenType { return .custom("operator") }

        static let operators: Set<String> = [
            "+", "-", "*", "/", "%", "++", "--", "=", "+=", "-=",
            "*=", "/=", "%=", "==", "!=", ">", "<", ">=", "<=",
            "&&", "||", "!", ".", "::", "?.", "?", "?:", "!!",
            ">", "!", "&", "|", "^", "<<", ">>", "~", ">>>",
            "and", "or", "not", "in", "is", "not in", "is not"
        ]

        func matches(_ segment: Segment) -> Bool {
            let currentToken = segment.tokens.current
            return OperatorRule.operators.contains(currentToken)
        }
    }
}
