//
//  ArgumentParser.swift
//  ArgumentParser
//
//  Created by Michael Fessenden on 8/23/16.
//  Copyright © 2016 Michael Fessenden. All rights reserved.
//

import Cocoa


open class ArgumentParser {
    // internal file manager
    internal static let fileManager = FileManager.default
    
    open var _executable: String! = nil
    open var path: String! = nil
    open var options: [Option] = []
    // stash for raw input
    open var _rawArgs: [String] = []
    open var docString: String = "(No description)"
    open var usage: String? = nil
    
    /// Formatted help string.
    open var helpString: String {
        
        let hasOptions: Bool = options.count > 0
        
        var optionsString = (hasOptions == true) ? "\n\nOPTIONS: \n" : "\n\nOPTIONS: (None)\n"

        let usageStrings = options.map { $0.usageString }
        var buffer = 5
        
        if (hasOptions == true) {
            // get the largest string size
            let usageMax: Int = usageStrings.reduce(0, { (total: Int, val: String) -> Int in
                return val.characters.count > total ? val.characters.count : total
            })
            
            buffer += usageMax
            for (_, option) in options.enumerated() {
                let helpString = option.helpString ?? ""
                let usageString = "\n\(option.usageString.zfill(length: buffer))\(helpString)"
                optionsString += usageString
            }
        }
        return "\nOVERVIEW:   \(docString)\n\nUSAGE:  \(usageString)\(optionsString)"
    }
    
    open var usageString: String {
        if let usage = usage { return usage }
        var result: String = self._executable ?? "(none)"
        for option in options {
            result += " \(option.flags.first != nil ? "-\(option.flags.first!) <\(option.name)> " : "<\(option.name)>")"
        }
        return result
    }
    
    public init(_ args: [String]) {
        _rawArgs = args
        _executable = args.first
    }
    
    public func parse() throws {
        let nargs = _rawArgs.dropFirst()
        for (idx, arg) in nargs.enumerated() {
            print("\(idx). \(arg)")
            if hasOption(flag: arg) {
                print(" -> found option: \(arg)")
            }
        }
    }
    
    public func addOption(named: String, flag: String, required: Bool, optionType: OptionType) {
  
    }
    
    public func addOption(_ option: Option, required: Bool=false, defaultValue: Any?=nil) -> Bool {
        options.append(option)
        option.isRequired = required
        
        guard let defaultValue = defaultValue else { return false }
        return option.setDefaultValue(defaultValue)
    }
    
    public func addOptions(_ options: Option...) {
        for option in options {
            self.options.append(option)
        }
    }
    
    public func addFlag(named: String, flag: String?=nil, required: Bool=false) {
        let option = Option(named: named, flag: flag, required: required)
        options.append(option)
    }
    
    public func help() {
        print(helpString)
    }
}


extension ArgumentParser {
    
    public var requiredOptions: [Option] {
        return options.filter( {$0.isRequired == true} )
    }
    
    public func hasOption(flag: String) -> Bool {
        for option in options {
            if option == flag {
                return true
            }
        }
        return false
    }
}

