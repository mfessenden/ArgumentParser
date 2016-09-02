//
//  String+Extensions.swift
//  ArgumentParser
//
//  Created by Michael Fessenden on 8/22/16.
//  Copyright © 2016 Michael Fessenden. All rights reserved.
//
//  ANSI Formatting reference:
//  http://stackoverflow.com/questions/27807925/color-ouput-with-swift-command-line-tool

import Foundation


public enum ANSIColor: UInt8 {
    case black    = 30
    case red      = 31
    case green    = 32
    case yellow   = 33
    case blue     = 34
    case magenta  = 35
    case cyan     = 36
    case white    = 37
    case none     = 39
}


public enum ANSIStyle: UInt8 {
    case none      = 0
    case bold      = 1
    case dim       = 2
    case italic    = 3
    case underline = 4
    case blink     = 5
}





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
    
    // \u{001B}[\(attribute code like bold, dim, normal);\(color code)m
    public func ansiFormatted(color: ANSIColor, style: ANSIStyle = .none) -> String {
        let prefix: String = "\u{001B}["
        let codes: [UInt8] = [color.rawValue, style.rawValue]
        return "\(prefix)\(codes.map{String($0)}.joined(separator: ";"))m\(self)\(prefix)0m"
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

