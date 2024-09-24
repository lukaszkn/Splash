//
//  DartGrammar.swift
//  
//
//  Created by Dana Buehre on 1/7/24.
//

import Foundation
import Splash

public struct DartGrammar: Grammar {
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
            "abstract", "as", "assert", "async", "await",
            "break", "case", "catch", "class", "const",
            "continue", "default", "deferred", "do", "dynamic",
            "else", "enum", "export", "extends", "extension",
            "external", "factory", "false", "final", "finally",
            "for", "Function", "get", "hide", "if", "implements",
            "import", "in", "interface", "is", "library", "mixin",
            "new", "null", "on", "operator", "part", "rethrow",
            "return", "set", "show", "static", "super", "switch",
            "sync", "this", "throw", "true", "try", "typedef",
            "var", "void", "while", "with", "yield"
        ]

        func matches(_ segment: Segment) -> Bool {
            let currentToken = segment.tokens.current
            return KeywordRule.keywords.contains(currentToken)
        }
    }

    struct OperatorRule: SyntaxRule {
        var tokenType: TokenType { return .custom("operator") }

        static let operators: Set<String> = [
            "+", "-", "*", "/", "%", "++", "--", "=", "+=",
            "-=", "*=", "/=", "%=", "==", "!=", ">", "<", ">=",
            "<=", "&&", "||", "!", ".", "..", "...", "?", "?.",
            "??", "??=", ">>>", ">>", "<<", "&", "|", "^", "~",
            ">>=", "<<=", "&=", "|=", "^=", "~/", "~/="
        ]

        func matches(_ segment: Segment) -> Bool {
            let currentToken = segment.tokens.current
            return OperatorRule.operators.contains(currentToken)
        }
    }
}

