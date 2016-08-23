//
//  String+Extensions.swift
//  ArgumentParser
//
//  Created by Michael Fessenden on 8/22/16.
//  Copyright © 2016 Michael Fessenden. All rights reserved.
//

import Foundation


public extension String {

    /**
     Pads a string with the given character.
     
     - parameter length:  `Int` length of padded string.
     - parameter buffer:  `String` fill value.
     - returns: `String` padded string.
     */
    public func zfill(length: Int, buffer: String=" ") -> String {
        if length < 0 { return "" }
        var filler = ""
        for _ in 0..<(length - self.characters.count) {
            filler += buffer
        }
        return self + filler
    }
    
    /// Returns true if the string represents a path that exists.
    public var fileExists: Bool {
        let fm = FileManager.default
        return fm.fileExists(atPath: self)
    }
    
    /// Returns true if the string represents a path that exists and is a directory.
    public var isDirectory: Bool {
        let fm = FileManager.default
        var isDir : ObjCBool = false
        return fm.fileExists(atPath: self, isDirectory: &isDir)
    }
}


public extension Bool {
    public init<T : Integer>(_ integer: T) {
        self.init(integer != 0)
    }
    
    public init(_ string: String) {
        self.init(["true", "True", "1", "yes"].contains(string))
    }
}


public extension Integer {
    public init(_ bool: Bool) {
        self = bool ? 1 : 0
    }
}



public extension Sequence where Iterator.Element: Hashable {
    public var uniqueElements: [Iterator.Element] {
        return Array( Set(self) )
    }
}

public extension Sequence where Iterator.Element: Equatable {
    public var uniqueElements: [Iterator.Element] {
        return self.reduce([]){
            uniqueElements, element in
            
            uniqueElements.contains(element)
                ? uniqueElements
                : uniqueElements + [element]
        }
    }
}

