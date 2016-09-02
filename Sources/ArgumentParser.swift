//
//  ArgumentParser.swift
//  ArgumentParser
//
//  Created by Michael Fessenden on 8/23/16.
//  Copyright © 2016 Michael Fessenden. All rights reserved.
//

import Cocoa


enum ParsingError: Error, CustomStringConvertible {
    case invalidValueType(option: String, optIndex: Int)
    case missingOptions(options: [String])
    case conflictingOption(option: String)
    
    public var description: String {
        switch self {
        case let .invalidValueType(option, optIndex):
            return "Invalid argument type: \(option) at index: \(optIndex)"
        case let .missingOptions(options):
            let optionsString = options.joined(separator: ", ")
            return "Missing required options: \(optionsString)."
        case let .conflictingOption(option):
            return "Conflicting option: \(option)"
        }
    }
}



public let shortPrefix = "-"
public let longPrefix = "--"


open class ArgumentParser {
    // internal file manager
    internal static let fileManager = FileManager.default
    
    open var _executable: String! = nil
    open var path: String! = nil
    open var _options: [Option] = []
    // stash raw input
    open var _rawArgs: [String] = []
    open var docString: String = "(No description)"
    open var usage: String? = nil
    
    var _helpMode: Bool = false
    
    /// Formatted help string.
    open var helpString: String {
        let hasOptions: Bool = options.count > 0
        let optionalCount = optionalOptions.count
        let positionalCount = positionalOptions.count
        
        
        let optFormattedString = "OPTIONAL ARGUMENTS".ansiFormatted(color: .none, style: .underline)
        let posFormattedString = "POSITIONAL ARGUMENTS".ansiFormatted(color: .none, style: .underline)
        
        var optionalString = (optionalCount > 0) ? "\n\n\(optFormattedString): \n" : "\n\n\(optFormattedString): (None)\n"
        var positionalString = (positionalCount > 0) ? "\n\n\(posFormattedString): \n" : "\n"
        
        
        let optionStrings = options.map { $0.usageString }
        
        var buffer = 5
        
        if (hasOptions == true) {
            // get the largest string size
            let usageMax: Int = optionStrings.reduce(0, { (total: Int, val: String) -> Int in
                return val.characters.count > total ? val.characters.count : total
            })
            
            buffer += usageMax
            for (_, oopt) in optionalOptions.enumerated() {
                let helpString = oopt.helpString ?? ""
                let usageString = "\n  \(oopt.usageString.zfill(length: buffer))\(helpString)"
                optionalString += usageString
            }
            
            for (_, popt) in positionalOptions.enumerated() {
                let helpString = popt.helpString ?? ""
                let usageString = "\n  \(popt.usageString.zfill(length: buffer))\(helpString)"
                positionalString += usageString
            }
        }
        
        
        let overviewCodedString = "OVERVIEW".ansiFormatted(color: .none, style: .underline)
        let usageCodedString = "USAGE".ansiFormatted(color: .none, style: .underline)
        
        return "\n\(overviewCodedString):  \(docString)\n\n\(usageCodedString):  \(usageString)\(positionalString)\(optionalString)\n"
    }
    
    open var usageString: String {
        if let usage = usage { return usage }
        
        // executable name
        let execFormattedString: String = self._executable.ansiFormatted(color: .none, style: .bold) ?? "(none)".ansiFormatted(color: .none, style: .bold)
        
        var result: String = execFormattedString
        for option in options {
            // skip help
            if option == "help" { continue }
            let optionName = option.metavar != nil ? option.metavar! : option.name
            result += " \(option.flags.first != nil ? "-\(option.flags.first!) <\(optionName)> " : "<\(optionName)>")"
        }
        return result
    }
    
    // MARK: - Init
    
    public init(_ args: [String]) {
        _rawArgs = args
        _executable = args.first
        _options.append(BoolOption(named: "help", flag: "h", helpString: "show help message and exit"))
    }
    
    public init(desc: String, usage: String?=nil) {
        docString = desc
        self.usage = usage
        _options.append(BoolOption(named: "help", flag: "h", helpString: "show help message and exit"))
    }
    
    // MARK: - Parsing
    open func parse(_ args: [String]) throws -> [String: Any] {
        _rawArgs = args
        _executable = args.first
        return try parse()
    }
            
    
    // MARK: - Option Handling
    public func addOption(_ option: Option, required: Bool=false, defaultValue: Any?=nil) -> Bool {
        if option.name == "help" || option.flags.contains("h") {
            print("Conflicting option string: \(option.name)")
            return false
        }
        _options.append(option)
        option._isRequired = required
        
        guard let defaultValue = defaultValue else { return false }
        return option.setDefaultValue(defaultValue)
    }
    
    public func addOptions(_ options: Option...) {
        for option in options {
            if option.name == "help" || option.flags.contains("h") {
                print("Conflicting option string: \(option.name)")
                return
            }
            _options.append(option)
        }
    }
    
    public func help() {
        _helpMode = true
        print(helpString)
    }
}


extension ArgumentParser: CustomStringConvertible, CustomDebugStringConvertible {
    open var description: String { return docString }
    open var debugDescription: String { return description }
}


extension ArgumentParser {
    
    public var options: [Option] {
        return _options.filter({ $0.name != "help" })
    }
    
    public var positionalOptions: [Option] {
        return options.filter( {$0.isPositional == true } )
    }
    
    public var optionalOptions: [Option] {
        return options.filter( {$0.isPositional == false } )
    }
    
    public var requiredOptions: [Option] {
        return options.filter( {$0.isRequired == true} )
    }
    
    public func hasOption(flag: String) -> Bool {
        if let _ = options.index( where: { $0 == flag } ) {
            return true
        }
        return false
    }
    
    public func getOption(named: String) -> Option? {
        for option in options {
            if option == named {
                return option
}
        }
        return nil
    }
    
    /// Returns true if the parser has all required options satisfied.
    public var isValid: Bool {
        if (_helpMode == true) { return true }
        return !options.map { $0.isValid }.contains(false)
    }
}


extension ArgumentParser {
    /**
     Add an option.
     */
    public func addOption(named: String, flags: String..., required: Bool, optionType: OptionType, helpString: String?, defaultValue: Double?=nil) {
    }
    
    /**
     Get an array of flags after the given index.
     */
    open func getFlagsAfterIndex(_ idx: Int) -> [String] {
        var values: [String] = []
        for i in stride(from: idx + 1, to: _rawArgs.count, by: 1) {
            let currentArg = _rawArgs[i]
            if currentArg.hasPrefix(shortPrefix) && Int(currentArg) == nil && Double(currentArg) == nil {
                break
            }
    
            values.append(currentArg)
        }
        
        return values
    }
    
    open func getFlagsBeforeIndex(_ idx: Int) -> [String] {
        var values: [String] = []
        for i in stride(from: 0, to: idx, by: 1) {
            let currentArg = _rawArgs[i]
            
            if !currentArg.hasPrefix(shortPrefix) {
                continue
            }
            
            if currentArg != _executable {
                values.append(currentArg)
            }
        }
        
        return values
    }
    
    /**
      Main parse method.
     */
    open func parse() throws -> [String: Any] {
        var result: [String: Any] = [:]
        let nargs = _rawArgs.dropFirst()
        
        var cnt = 0
        var matchedArgs: [String] = []
        var unmatchedArgs: [String] = []
        
        for (idx, arg) in nargs.enumerated() {
            
            if ["--help", "-h"].contains(arg.lowercased()) {
                help()
                break
            }
            
            // positional values
            let pvalues = getFlagsAfterIndex(idx)
            
            if !arg.hasPrefix(shortPrefix) {
                //print("positional \(idx): \(arg)")
                continue
            }
            
            if let option = getOption(named: arg) {
                matchedArgs.append(arg)
                let fvalues = getFlagsAfterIndex(idx + 1)
                print("  → option: \"\(option.name)\": \(fvalues)")
                if let stringOption = option as? StringOption {
                    for value in fvalues {
                        stringOption.setValue(value)
                        matchedArgs.append(value)
                    }
                }
                
                if let boolOption = option as? BoolOption {
                    for value in fvalues {
                        boolOption.setValue(value)
                        matchedArgs.append(value)
                    }
                }
                
                if let intOption = option as? IntegerOption {
                    for value in fvalues {
                        intOption.setValue(value)
                        matchedArgs.append(value)
                    }
                }
                
                if let doubleOption = option as? DoubleOption {
                    for value in fvalues {
                        doubleOption.setValue(value)
                        matchedArgs.append(value)
                    }
                }
                
                if let pathOption = option as? PathOption {
                    for value in fvalues {
                        pathOption.setValue(value)
                        matchedArgs.append(value)
                    }
                }
            }
        }
        
        if _helpMode == true { return [:] }
        
        
        for (nidx, narg) in nargs.enumerated() {
            if !matchedArgs.contains(narg) {
                
                let option = options[nidx]
                if !option.isPositional {
                    throw ParsingError.invalidValueType(option: option.name, optIndex: nidx)
                }
                
                print("  → option: \(option.name): \(narg)")
                if let stringOption = option as? StringOption {
                    stringOption.setValue(narg)
                }
                
                if let boolOption = option as? BoolOption {
                    boolOption.setValue(narg)
                }
                
                if let intOption = option as? IntegerOption {
                    intOption.setValue(narg)
                }
                
                if let doubleOption = option as? DoubleOption {
                    doubleOption.setValue(narg)
                }
                
                if let pathOption = option as? PathOption {
                    pathOption.setValue(narg)
                }
                
            }
        }
        
        return result
    }
    
    
    open func dump() {
        print("\n# Debug:")
        for option in options {
            print(option.debugDescription)
        }
    }
}
