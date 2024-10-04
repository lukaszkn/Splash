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
        var delimiters = CharacterSet.alphanumerics.inverted
        delimiters.remove("_")
        delimiters.remove("\"")
        delimiters.remove("#")
        delimiters.remove("@")
        delimiters.remove("$")
        self.delimiters = delimiters

        syntaxRules = [
            CommentRule(),
            RawStringRule(),
            MultiLineStringRule(),
            SingleLineStringRule(),
            NumberRule(),
            KeywordRule(),
            OperatorRule()
        ]
    }

    struct CommentRule: SyntaxRule {
        var tokenType: TokenType { return .comment }

        func matches(_ segment: Segment) -> Bool {
            if segment.tokens.current.hasPrefix("/*") {
                if segment.tokens.current.hasSuffix("*/") {
                    return true
                }
            }
            
            if segment.tokens.current.hasPrefix("//") {
                return true
            }

            if segment.tokens.onSameLine.contains(anyOf: "//", "///") {
                return true
            }

            if segment.tokens.current.isAny(of: "/*", "/**", "*/") {
                return true
            }

            let multiLineStartCount = segment.tokens.count(of: "/*") + segment.tokens.count(of: "/**")
            return multiLineStartCount != segment.tokens.count(of: "*/")
        }
    }

    struct RawStringRule: SyntaxRule {
        var tokenType: TokenType { return .string }

        func matches(_ segment: Segment) -> Bool {
            guard !segment.isWithinRawStringInterpolation else {
                return false
            }

            if segment.isWithinStringLiteral(withStart: "#\"", end: "\"#") {
                return true
            }

            let multiLineStartCount = segment.tokens.count(of: "#\"\"\"")
            let multiLineEndCount = segment.tokens.count(of: "\"\"\"#")
            return multiLineStartCount != multiLineEndCount
        }
    }

    struct MultiLineStringRule: SyntaxRule {
        var tokenType: TokenType { return .string }

        func matches(_ segment: Segment) -> Bool {
            guard !segment.tokens.count(of: "\"\"\"").isEven else {
                return false
            }

            return !segment.isWithinStringInterpolation
        }
    }
    
    struct SingleLineStringRule: SyntaxRule {
        var tokenType: TokenType { return .string }

        func matches(_ segment: Segment) -> Bool {
            if segment.tokens.current.hasPrefix("\"") &&
               segment.tokens.current.hasSuffix("\"") {
                return true
            }

            guard segment.isWithinStringLiteral(withStart: "\"", end: "\"") else {
                return false
            }

            return !segment.isWithinStringInterpolation && !segment.isWithinRawStringInterpolation
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

private extension Segment {
    func isWithinStringLiteral(withStart start: String, end: String) -> Bool {
        if tokens.current.hasPrefix(start) {
            return true
        }
        
        if tokens.current.hasSuffix(end) {
            return true
        }
        
        var markerCounts = (start: 0, end: 0)
        var previousToken: String?
        
        for token in tokens.onSameLine {
            if token.hasPrefix("(") || token.hasPrefix("#(") || token.hasPrefix("\"") {
                guard previousToken != "\\" else {
                    previousToken = token
                    continue
                }
            }
            
            if token == start {
                if start != end || markerCounts.start == markerCounts.end {
                    markerCounts.start += 1
                } else {
                    markerCounts.end += 1
                }
            } else if token == end && start != end {
                markerCounts.end += 1
            } else {
                if token.hasPrefix(start) {
                    markerCounts.start += 1
                }
                
                if token.hasSuffix(end) {
                    markerCounts.end += 1
                }
            }
            
            previousToken = token
        }
        
        return markerCounts.start != markerCounts.end
    }
    
    var isWithinStringInterpolation: Bool {
        return false
    }
    
    var isWithinRawStringInterpolation: Bool {
        return false
    }
}
