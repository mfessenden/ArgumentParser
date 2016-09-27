//
//  ArgumentParser.swift
//  ArgumentParser
//
//  Created by Michael Fessenden on 8/23/16.
//  Copyright © 2016 Michael Fessenden. All rights reserved.
//
//  ANSI Formatting reference:
//  http://stackoverflow.com/questions/27807925/color-ouput-with-swift-command-line-tool

import Cocoa


public enum ParsingError: Error, CustomStringConvertible {
    
    case invalidValueType(option: Option, optIndex: Int)
    case missingOptions(options: [String])
    case conflictingOption(option: String)
    
    public var description: String {
        switch self {
        case let .invalidValueType(option, optIndex):
            return "Invalid argument type: \"\(option.name)\" at index: \(optIndex)"
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


// MARK: - Options

/// Describes the type of option value types available.
public enum OptionType {
    case none
    case string
    case bool
    case integer
    case double
    case path
    case multiString
    case multiInteger
    case multiDouble
    case multiPath
}


public enum NumArgs: String {
    case one        = "?"
    case list       = "*"
    case listOrOne  = "+"
}


/** 
 Option base class. Not intended to be used directly.
 */
open class Option {

    internal var _name: String                      // option name
    internal var _isRequired: Bool = false          // is the option required?
    
    open var flags: [String] = []                   // option flags (short names)
    open var helpString: String? = nil              // optional help string
    open var metavar: String? = nil                 // description of the value type in usage (ie: path, input)
    internal var nargs: Int = 1                     // max number of values allowed (? - 1 value, or default)
                                                    //                              (* - args are split into list)
                                                    //                              (+ - same as *, but requires 1)
    
    /// Type of value this option accepts
    open var type: OptionType {
        return .none
    }
    
    /// The option name
    open var name: String {
        return _name.hasPrefix(shortPrefix) ? _name.components(separatedBy: shortPrefix).last! : _name
    }
    
    /// Indicates that the option has a value(s) assigned
    open var hasValue: Bool {
        return false
    }
    
    /// Returns true if the option has a valid value.
    open var isSatisfied: Bool {
        return false
    }
    
    /// Indicates that an option is positional
    open var isPositional: Bool {
        return flags.isEmpty && !_name.hasPrefix(shortPrefix)
    }
    
    /// Indicates that an option is required to have a value.
    open var isRequired: Bool {
        return _isRequired == true || isPositional == true
    }
    
    /// Indicates that the option can be processed.
    open var isValid: Bool {
        guard type != .none else { return false }
        return (isSatisfied == true) ? true : (isRequired == true) ? false : true
    }
    
    /// Returns a string with all of the current flags
    open var flagsString: String? {
        return (flags.count != 0) ? flags.map {"-\($0)"}.joined(separator: ", ") : nil
    }
    
    /// Returns a string describing the option's usage instructions:
    ///   ie: `-f, --filename`
    open var usageString: String {
        let shortUsage = (flagsString == nil) ? "" : "\(flagsString!), "
        let namePrefix = (isPositional == false) ? "--" : ""
        return "\(shortUsage)\(namePrefix)\(name)"
    }
    
    // MARK: - Init
    /**
      Initialize a named option.
     
     - parameter named: `String` argument name.
     */
    required public init(named: String) {
        self._name = named.replacingOccurrences(of: " ", with: "-")
    }
    
    /**
     Initialize an option with name & help description.
     
     - parameter named:      `String` argument name.
     - parameter helpString: `String` argument help string.
     */
    convenience public init(named: String, helpString: String) {
        self.init(named: named, flag: nil, required: false, helpString: helpString)
    }
    
    /**
     Initialize an option with name, flag & help description.
     
     - parameter named:      `String` argument name.
     - parameter flag:       `String` argument flag.
     - parameter helpString: `String` argument help string.
     */
    convenience public init(named: String, flag: String, helpString: String) {
        self.init(named: named, flag: flag, required: false, helpString: helpString)
    }
    
    /**
     Initialize an option with name and optional parameters.
     
     - parameter name:       `String` argument name.
     - parameter flag:       `String?` optional argument flag.
     - parameter required:   `Bool` argument is required to be fulfilled.
     - parameter helpString: `String?` argument help string.
     */
    convenience public init(named: String, flag: String?=nil, required: Bool=false, helpString: String?=nil) {
        self.init(named: named)
        
        if let flagArg = flag {
            self.flags.append(flagArg)
        }
        self._isRequired = required
        self.helpString = helpString
    }
    
    /**
     Initialize an option with name and optional parameters.
     
     - parameter name:       `String` argument name.
     - parameter flags:      `[String]` argument flags.
     - parameter required:   `Bool` argument is required to be fulfilled.
     - parameter helpString: `String?` argument help string.
     */
    convenience public init(named: String, flags: [String], required: Bool=false, helpString: String?=nil) {
        self.init(named: named)
        self.flags = flags.uniqueElements
        self._isRequired = required
        self.helpString = helpString
    }
    
    public func setValue(_ values: String...) -> Bool {
        return false
    }
    
    public func setDefaultValue(_ value: Any) -> Bool {
        return false
    }
}


/// Basic string option.
open class StringOption: Option {
    override open var type: OptionType {
        return .string
    }
    
    internal var rawValue: String? = nil
    internal var _default: String? = nil
    
    open var value: String? {
        return rawValue ?? _default
    }
    
    override open var hasValue: Bool {
        return value != nil
    }
    
    override open var isSatisfied: Bool {
        // TODO: expand this for multi-values
        return value != nil
    }
    
    public convenience init(named: String, flag: String?, required: Bool, helpString: String?, defaultValue: String?=nil) {
        self.init(named: named, flag: flag, required: required, helpString: helpString)
        self._default = defaultValue
    }
    
    public convenience init(named: String, flags: String... , required: Bool=false, helpString: String?=nil, defaultValue: String?=nil) {
        self.init(named: named, flags: flags, required: required, helpString: helpString)
        self._default = defaultValue
    }
    
    public convenience init(named: String, helpString: String, defaultValue: String?=nil) {
        self.init(named: named, flag: nil, required: false, helpString: helpString, defaultValue: defaultValue)
    }
    
    override public func setValue(_ values: String...) -> Bool {
        if let strValue = values.first {
            rawValue = strValue
            return true
        }
        return false
    }
    
    override public func setDefaultValue(_ value: Any) -> Bool {
        if let strValue = value as? String {
            _default = strValue
            return true
        }
        return false
    }
}

/// Boolean option
///  - Can only have one value
open class BoolOption: Option {
    override open var type: OptionType {
        return .bool
    }
    internal var rawValue: Bool = false
    override open var nargs: Int {
        didSet {
            if nargs > 1 {
                nargs = 1
            }
        }
    }
    
    open var value: Bool {
        return rawValue
    }
    
    override open var hasValue: Bool {
        return value == true
    }
    
    override open var isSatisfied: Bool {
        return true
    }
    
    override public func setValue(_ values: String...) -> Bool {
        if let boolValue = values.first {
            rawValue = Bool(boolValue)
            return true
        }
        return false
    }
    
    override public func setDefaultValue(_ value: Any) -> Bool {
        return false
    }
}


open class IntegerOption: Option {
    override open var type: OptionType {
        return .integer
    }
    internal var rawValue: Int? = nil
    internal var _default: Int? = nil
    
    open var value: Int? {
        return rawValue ?? _default
    }
    
    override open var hasValue: Bool {
        return value != nil
    }
    
    override open var isSatisfied: Bool {
        // TODO: expand this for multi-values
        return value != nil
    }
    
    public convenience init(named: String, flag: String?, required: Bool, helpString: String?, defaultValue: Int?=nil) {
        self.init(named: named, flag: flag, required: required, helpString: helpString)
        self._default = defaultValue
    }
    
    public convenience init(named: String, flags: String... , required: Bool=false, helpString: String?=nil, defaultValue: Int?=nil) {
        self.init(named: named, flags: flags, required: required, helpString: helpString)
        self._default = defaultValue
    }
    
    public convenience init(named: String, helpString: String, defaultValue: Int?=nil) {
        self.init(named: named, flag: nil, required: false, helpString: helpString, defaultValue: defaultValue)
    }
    
    override public func setValue(_ values: String...) -> Bool {
        if let intValue = Int(values.first!) {
            self.rawValue = intValue
            return true
        }
        return false
    }
    
    override public func setDefaultValue(_ value: Any) -> Bool {
        if let intValue = Int(value as! String) {
            _default = intValue
            return true
        }
        return false
    }
}


open class DoubleOption: Option {
    override open var type: OptionType {
        return .double
    }
    internal var rawValue: Double? = nil
    internal var _default: Double? = nil
    
    open var value: Double? {
        return rawValue ?? _default
    }
    
    override open var hasValue: Bool {
        return value != nil
    }
    
    override open var isSatisfied: Bool {
        // TODO: expand this for multi-values
        return value != nil
    }
    
    public convenience init(named: String, flag: String?, required: Bool, helpString: String?, defaultValue: Double?=nil) {
        self.init(named: named, flag: flag, required: required, helpString: helpString)
        self._default = defaultValue
    }
    
    public convenience init(named: String, flags: String... , required: Bool=false, helpString: String?=nil, defaultValue: Double?=nil) {
        self.init(named: named, flags: flags, required: required, helpString: helpString)
        self._default = defaultValue
    }
    
    public convenience init(named: String, helpString: String, defaultValue: Double?=nil) {
        self.init(named: named, flag: nil, required: false, helpString: helpString, defaultValue: defaultValue)
    }
    
    override public func setValue(_ values: String...) -> Bool {
        if let doubleValue = Double(values.first!) {
            self.rawValue = doubleValue
            return true
        }
        return false
    }
    
    override public func setDefaultValue(_ value: Any) -> Bool {
        if let doubleValue = Double(value as! String) {
            _default = doubleValue
            return true
        }
        return false
    }
}


open class PathOption: StringOption {
    
    override open var type: OptionType {
        return .path
    }
    internal static var fileManager = FileManager.default
    
    override open var isSatisfied: Bool {
        // TODO: expand this to indicate that the url dirname is valud
        return value != nil
    }
    
    public var url: URL? {
        return value != nil ? URL(fileURLWithPath: value!) : nil
    }
    
    public var exists: Bool {
        guard let path = value else { return false }
        return PathOption.fileManager.fileExists(atPath: path)
    }
    
    public var isDirectory: Bool {
        guard let path = value else { return false }
        var isDir : ObjCBool = false
        return PathOption.fileManager.fileExists(atPath: path, isDirectory: &isDir)
    }
}

// MARK: - ArgumentParser


open class ArgumentParser {
    // internal file manager
    internal static let fileManager = FileManager.default
    open var path: String! = nil
    
    private var _executable: String! = nil                          // executable name
    private var _options: [Option] = []
    private var _rawArgs: [String] = []
    private var _helpMode: Bool = false                             // parser isn't processing arguments, just displaying help
    internal var _usage: String? = nil                              // custom usage string
    
    open var docString: String = "(No description)"                 // parser help string

    public var name: String {
        return self._executable ?? "(none)"
    }
    
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
    
    /// Returns true if the parser has all required options satisfied.
    public var isValid: Bool {
        if (_helpMode == true) { return true }
        return !options.map { $0.isValid }.contains(false)
    }
    
    /// Returns an array of options that aren't fulfilled.
    public var invalidOptions: [Option] {
        return options.filter( {$0.isValid == false} )
    }
    
    // MARK: - Init
    /**
     Initialize a parser with command-line arguments.
     
     - parameter args:       `[String]` raw string arguments.
     */
    public init(_ args: [String]) {
        _rawArgs = args
        _executable = args.first
        _options.append(BoolOption(named: "help", flag: "h", helpString: "show help message and exit"))
    }
    
    /**
     Initialize a parser with usage & description.
     
     - parameter desc:  `String` parser description.
     - parameter usage: `String?` optional usage string.
     */
    public init(desc: String, usage: String?=nil) {
        docString = desc
        _usage = usage
        _options.append(BoolOption(named: "help", flag: "h", helpString: "show help message and exit"))
    }
    
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
    
    /// Formatted usage string.
    open var usageString: String {
        if let _usage = _usage { return _usage }
        
        // executable name
        let execName = self._executable ?? "(none)"
        var result: String = execName.ansiFormatted(color: .none, style: .bold)
        for option in options {
            // skip help
            if option == "help" { continue }
            let optionName = option.metavar != nil ? option.metavar! : option.name
            
            let fontColor: ANSIColor = (option.isValid == true) ? .none : .red
            let fontStyle: ANSIStyle = (option.isValid == true) ? .none : .bold
            let optionNameFormatted = "<\(optionName)>".ansiFormatted(color: fontColor, style: fontStyle)
            
            result += " \(option.flags.first != nil ? "-\(option.flags.first!) \(optionNameFormatted) " : "\(optionNameFormatted)")"
        }
        return result
    }

    
    // MARK: - Parsing
    /**
     Parse the given strings and return a dictionary of parsed arguments from the command-line.
     
     - parameter args:        `[String]` options to add.
     - returns: `[String: Any]` dictionary of parsed values.
     */
    open func parse(_ args: [String]) throws -> [String: Any] {
        _rawArgs = args
        _executable = args.first
        return try parse()
    }
    
    /**
     Main parse method.
     
     - returns: `[String: Any]` dictionary of parsed values.
     */
    open func parse() throws -> [String: Any] {
        
        // dictionary for parsed arguments
        var result: [String: Any] = [:]
        
        // remove the command name
        let nargs = _rawArgs.dropFirst()
        
        // stash matched arguments
        var matchedArgs: [String] = []
        
        // loop through arguments and match flags
        for (idx, arg) in nargs.enumerated() {
            
            // break if user has enacted help
            if ["--help", "-h"].contains(arg.lowercased()) {
                help()
                break
            }
            
            // positional values
            if !arg.hasPrefix(shortPrefix) {
                continue
            }
            
            if let option = getOption(named: arg) {
                matchedArgs.append(arg)
                let fvalues = getFlagsAfterIndex(idx + 1)
                
                
                if option.type == .string {
                    if let stringOption = option as? StringOption {
                        for value in fvalues {
                            guard (stringOption.setValue(value) == true) else {
                                throw ParsingError.invalidValueType(option: stringOption, optIndex: idx)
                            }
                            
                            
                            matchedArgs.append(value)
                            
                            if let stringValue = stringOption.value {
                                result[stringOption.name] = stringValue
                            }
                        }
                    }
                }
                
                if option.type == .bool {
                    if let boolOption = option as? BoolOption {
                        for value in fvalues {
                            guard (boolOption.setValue(value) == true) else {
                                throw ParsingError.invalidValueType(option: boolOption, optIndex: idx)
                            }
                            
                            matchedArgs.append(value)
                            let boolValue = boolOption.value
                            result[boolOption.name] = boolValue
                        }
                    }
                }
                
                if option.type == .integer {
                    if let intOption = option as? IntegerOption {
                        for value in fvalues {
                            guard (intOption.setValue(value) == true) else {
                                throw ParsingError.invalidValueType(option: intOption, optIndex: idx)
                            }
                            
                            matchedArgs.append(value)
                            if let intValue = intOption.value {
                                result[intOption.name] = intValue
                            }
                        }
                    }
                }
                
                if option.type == .double {
                    if let doubleOption = option as? DoubleOption {
                        for value in fvalues {
                            guard (doubleOption.setValue(value) == true) else {
                                throw ParsingError.invalidValueType(option: doubleOption, optIndex: idx)
                            }
                            
                            matchedArgs.append(value)
                            if let doubleValue = doubleOption.value {
                                result[doubleOption.name] = doubleValue
                            }
                        }
                    }
                }
                
                if option.type == .path {
                    if let pathOption = option as? PathOption {
                        for value in fvalues {
                            
                            guard (pathOption.setValue(value) == true) else {
                                throw ParsingError.invalidValueType(option: pathOption, optIndex: idx)
                            }
                            
                            matchedArgs.append(value)
                            if let stringValue = pathOption.value {
                                result[pathOption.name] = stringValue
                            }
                        }
                    }
                }
            }
        }
        
        // return if help in enacted
        if _helpMode == true { return [:] }
        
        
        // loop a second time to catch positional arguments
        for (nidx, narg) in nargs.enumerated() {
            
            // exclude previously matched arguments
            if !matchedArgs.contains(narg) {
                
                let option = options[nidx]
                if !option.isPositional {
                    throw ParsingError.invalidValueType(option: option, optIndex: nidx)
                }
                
                if option.type == .string {
                    if let stringOption = option as? StringOption {
                        
                        guard (stringOption.setValue(narg) == true) else {
                            throw ParsingError.invalidValueType(option: stringOption, optIndex: nidx)
                        }
                        
                        
                        if let stringValue = stringOption.value {
                            result[stringOption.name] = stringValue
                        }
                    }
                }
                
                if option.type == .bool {
                    if let boolOption = option as? BoolOption {

                        guard (boolOption.setValue(narg) == true) else {
                            throw ParsingError.invalidValueType(option: boolOption, optIndex: nidx)
                        }
                        
                        let boolValue = boolOption.value
                        result[boolOption.name] = boolValue
                    }
                }
                
                if option.type == .integer {
                    if let intOption = option as? IntegerOption {
                        guard (intOption.setValue(narg) == true) else {
                            throw ParsingError.invalidValueType(option: intOption, optIndex: nidx)
                        }
                        
                        if let intValue = intOption.value {
                            result[intOption.name] = intValue
                        }
                    }
                }
                
                if option.type == .double {
                    if let doubleOption = option as? DoubleOption {
                        
                        guard (doubleOption.setValue(narg) == true) else {
                            throw ParsingError.invalidValueType(option: doubleOption, optIndex: nidx)
                        }
                        
                        if let doubleValue = doubleOption.value {
                            result[doubleOption.name] = doubleValue
                        }
                    }
                }
                
                if option.type == .path {
                    if let pathOption = option as? PathOption {
                        
                        guard (pathOption.setValue(narg) == true) else {
                            throw ParsingError.invalidValueType(option: pathOption, optIndex: nidx)
                        }
                        
                        if let stringValue = pathOption.value {
                            result[pathOption.name] = stringValue
                        }
                    }
                }
                
            }
        }
        
        return result
    }
    
    // MARK: - Option Handling
    
    /**
     Create & add an new option to the parser, given option type, name, flags etc. Returns the option (if created).
     
     - parameter named:         `String` option name.
     - parameter flags:         `String...` option flags.
     - parameter optionType:    `OptionType` option type.
     - parameter required:      `Bool` option is required.
     - parameter helpString:    `String?` optional help string.
     - parameter defaultValue:  `Any?` optional default value.
     - returns: `Option?` option (if created).
     */
    open func addOption(named: String, flags: String..., optionType: OptionType, required: Bool, helpString: String?, defaultValue: Any?=nil) -> Option? {
        let option = optionType.option.init(named: named)
        option.flags = flags
        option._isRequired = required
        option.helpString = helpString
        
        if let defaultValue = defaultValue {
            if !option.setDefaultValue(defaultValue) {
                fatalError("incorrect type of default value passed: \(defaultValue)")
            }
        }
        return option
    }
    
    /**
     Create & add an new option to the parser, given option type, name, help string etc. Returns the option (if created).
     
     - parameter named:         `String` option name.
     - parameter flag:          `String?` option flag.
     - parameter optionType:    `OptionType` option type.
     - parameter required:      `Bool` option is required.
     - parameter helpString:    `String?` optional help string.
     - parameter defaultValue:  `Any?` optional default value.
     - returns: `Option?` option (if created).
     */
    open func addOption(named: String, flag: String?, optionType: OptionType, required: Bool, helpString: String?, defaultValue: Any?=nil) -> Option? {
        let option = optionType.option.init(named: named)
        option._isRequired = required
        option.helpString = helpString
        
        if let defaultValue = defaultValue {
            if !option.setDefaultValue(defaultValue) {
                fatalError("incorrect type of default value passed: \(defaultValue)")
            }
        }
        return option
    }
    
    /**
     Add an option to the parser. Optionally specify whether option is required as well as default value.
     
     - parameter option:        `Option` options to add.
     - parameter required:      `Bool` option is required.
     - parameter defaultValue:  `Any?` optional default value.
     - returns: `Bool` add was successful.
     */
    open func addOption(_ option: Option, required: Bool=false, defaultValue: Any?=nil) -> Bool {
        if option.name == "help" || option.flags.contains("h") || hasOption(flag: option.name){
            print("Option exists: \"\(option.name)\"")
            return false
        }
        _options.append(option)
        option._isRequired = required
        
        guard let defaultValue = defaultValue else { return false }
        return option.setDefaultValue(defaultValue)
    }
    
    /**
     Add multiple options to the parser.
     
     - parameter options:  `Option...` options to add.
     - returns: `Bool` add was successful.
     */
    open func addOptions(_ options: Option...) -> Bool {
        for option in options {
            if option.name == "help" || option.flags.contains("h") || hasOption(flag: option.name) {
                print("Option exists: \"\(option.name)\"")
                return false
            }
            _options.append(option)
        }
        return true
    }
    
    /**
     Returns true if the parser contains the named option.
     
     - parameter flag:  `String` option name.
     - returns: `Bool` parser contains the named option.
     */
    public func hasOption(flag: String) -> Bool {
        if let _ = options.index( where: { $0 == flag } ) {
            return true
        }
        return false
    }
    
    /**
     Return a named option (if one exists).
     
     - parameter named:  `String` option name.
     - returns: `Option?` named option, nil if it does not exist.
     */
    public func getOption(named: String) -> Option? {
        for option in options {
            if option == named {
                return option
            }
        }
        return nil
    }
    
    // MARK: - Utilities
    
    /**
     Get an array of flags after the given index.
     
     - returns: `[String]` flags after the given index.
     */
    private func getFlagsAfterIndex(_ idx: Int) -> [String] {
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
    
    
    /**
     Get an array of flags before the given index.
     
     - returns: `[String]` flags before the given index.
     */
    private func getFlagsBeforeIndex(_ idx: Int) -> [String] {
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

    
    // MARK: - Help
    
    /**
     If help is called, print the help string.
     */
    public func help() {
        _helpMode = true
        print(helpString)
    }
    
    /**
     Dump the contents of the parser, useful for dubugging.
     */
    open func dump() {
        let execName = self._executable ?? "none"
        print("\n# ArgumentParser: \"\(execName)\":")
        for option in options {
            print(option.debugDescription)
        }
    }
}


// MARK: - Extensions

extension OptionType {
    /// Return the appropriate option type.
    public var option: Option.Type {
        switch self {
        case .bool:
            return BoolOption.self
            
        case .integer, .multiInteger:
            return IntegerOption.self
            
        case .double, .multiDouble:
            return DoubleOption.self
            
        case .path, .multiPath:
            return PathOption.self
            
        default:
            return StringOption.self
        }
    }
}


public func == (lhs: Option, rhs: String) -> Bool {
    let parsedName = lhs.name.hasPrefix(shortPrefix) ? lhs.name.components(separatedBy: shortPrefix).last! : lhs.name
    let flagName = rhs.hasPrefix(shortPrefix) ? rhs.components(separatedBy: shortPrefix).last! : rhs
    return parsedName == flagName || lhs.flagsString ?? "~" == flagName || lhs.flags.contains(flagName)
}


public func == (lhs: Option, rhs: Option) -> Bool {
    return lhs.hashValue == rhs.hashValue
}


extension Option: Hashable {
    public var hashValue: Int {
        let parsedName = name.hasPrefix(shortPrefix) ? name.components(separatedBy: shortPrefix).last! : name
        return parsedName.hashValue
    }
}


extension Option: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { return usageString }
    public var debugDescription: String {
        
        var result = (isValid == true) ? " \(self.name) (\(self.type))" : "*\(self.name) (\(self.type))"
        
        result += ":  positional: \(self.isPositional)"
        result += ", required: \(self.isRequired)"
        
        
        let style: ANSIStyle = (isSatisfied == true) ? .none : (isRequired == true) ? .bold : .none
        let color: ANSIColor = (isSatisfied == true) ? .none : (isRequired == true) ? .red : .none
        let satisfiedDesc = "\(self.isSatisfied)".ansiFormatted(color: color, style: style)
        
        result += ", satisfied: \(satisfiedDesc)"
        return result
    }
}



extension ArgumentParser: CustomStringConvertible, CustomDebugStringConvertible {
    open var description: String { return docString }
    open var debugDescription: String { return description }
}


// MARK: - ANSI Formatting

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


// MARK: - Extensions


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

