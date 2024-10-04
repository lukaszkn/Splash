//
//  NoGrammar.swift
//
//
//  Created by Dana Buehre on 1/7/24.
//

import Foundation

public struct NoGrammar: Grammar {
    public var delimiters: CharacterSet = CharacterSet()
    public var syntaxRules = [Splash.SyntaxRule]()
    
    public init() {
    }
}
