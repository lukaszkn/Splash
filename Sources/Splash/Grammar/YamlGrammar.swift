//
//  YamlGrammer.swift
//  
//
//  Created by Dana Buehre on 1/7/24.
//

import Foundation

public struct YamlGrammar: Grammar {
    public var delimiters: CharacterSet
    public var syntaxRules: [SyntaxRule]
    
    public init() {
        var delimiters = CharacterSet.alphanumerics.inverted
        delimiters.remove("_")
        delimiters.remove("-")
        delimiters.remove("\"")
        delimiters.remove("#")
        delimiters.remove("@")
        delimiters.remove("$")
        self.delimiters = delimiters
        
        syntaxRules = [
            KeywordRule(),
            TypeRule(),
            StringRule(),
            CommentRule(),
            NumberRule(),
            
        ]
    }
    
    public func isDelimiter(_ delimiterA: Character, mergableWith delimiterB: Character) -> Bool {
        switch (delimiterA, delimiterB) {
        case (_, ":"):
            return false
        case (":", "/"):
            return true
        case (":", _):
            return false
        case ("-", _):
            return false
        case ("#", _):
            return false
        default:
            return true
        }
    }
}

private extension YamlGrammar {
    static let keywords = ([
        "|", "---", "...", ">", "[", "]", "-"
    ] as Set<String>)
    
    struct CommentRule: SyntaxRule {
        var tokenType: TokenType { return .comment }
        
        func matches(_ segment: Segment) -> Bool {
            if segment.tokens.onSameLine.contains("#") {
                return true
            }
            
            return segment.tokens.current.hasPrefix("#")
        }
    }
    
    struct StringRule: SyntaxRule {
        var tokenType: TokenType { return .string }
        
        func matches(_ segment: Segment) -> Bool {
            if let prev = segment.tokens.previous {
                /**
                 *  In yaml files, quotes around strings are optional
                 *  Unless it's a number, a value following a colon or lines after a pipe (|) are considered a string
                 */
                if prev.hasSuffix(":") {
                    if segment.tokens.current.hasSuffix(":") && segment.isLastOnLine {
                        /**
                         * ie.
                         *  name:
                         *    name2: << This is not a string
                         *      ...
                         */
                        return false
                    }
                    return true
                } else {
                    var sameLine: Bool = false
                    segment.tokens.onSameLine.forEach( { token in
                        if token.hasSuffix(":") {
                            sameLine = true
                        }
                    })
                    if sameLine {
                        return true
                    }
                }
            }
            if segment.tokens.current == ":" {
                return false
            }
            return true
        }
    }
    
    struct NumberRule: SyntaxRule {
        var tokenType: TokenType { return .number }
        
        func matches(_ segment: Segment) -> Bool {
            if segment.tokens.current.isNumber {
                return true
            }
            
            guard segment.tokens.current == "." else {
                return false
            }
            
            guard let prev = segment.tokens.previous, let next = segment.tokens.next else {
                return false
            }
            
            return prev.isNumber && next.isNumber
        }
    }
    
    struct KeywordRule: SyntaxRule {
        var tokenType: TokenType { return .keyword }
        
        func matches(_ segment: Segment) -> Bool {
            return keywords.contains(segment.tokens.current)
        }
    }
    
    struct TypeRule: SyntaxRule {
        var tokenType: TokenType { return .type }
        
        func matches(_ segment: Segment) -> Bool {
            if let next = segment.tokens.next {
                return next.hasSuffix(":")
            } else {
                return false
            }
        }
    }
}

private extension Segment {
    
}
