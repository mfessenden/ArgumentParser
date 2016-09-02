//
//  Option.swift
//  ArgumentParser
//
//  Created by Michael Fessenden on 8/23/16.
//

import Foundation


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


// MARK: - Option Classes

/// Option base class. Not intended to be used directly.
open class Option {
    open var type: OptionType {
        return .none
    }
    open var _name: String                          // option name
    open var flags: [String] = []                   // option flags (short names)
    open var helpString: String? = nil              // optional help string
    open var metavar: String? = nil                 // description of the value type in usage (ie: path, input)
    open var _isRequired: Bool = false              // is the option required?
    open var nargs: Int = 1                         // max number of values allowed (? - 1 value, or default)
                                                    //                              (* - args are split into list)
                                                    //                              (+ - same as *, but requires 1)
    
    
    /// Indicates that the option has a value(s) assigned
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
    
    /// Returns a string describing the option's usage instructions
    // ie: `-f --filename`
    open var usageString: String {
        let shortUsage = (flagsString == nil) ? "" : "\(flagsString!), "
        let namePrefix = (isPositional == false) ? "--" : ""
        return "\(shortUsage)\(namePrefix)\(name)"
    }
    
    // MARK: - Init
    public init(named: String, flag: String?=nil, required: Bool=false, helpString: String?=nil) {
        self._name = named.replacingOccurrences(of: " ", with: "-")
        
        if let flagArg = flag {
            self.flags.append(flagArg)
        }
        self._isRequired = required
        self.helpString = helpString
    }
    
    public init(named: String, flags: [String], required: Bool=false, helpString: String?=nil) {
        self._name = named.replacingOccurrences(of: " ", with: "-")
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
    internal var _value: String? = nil
    internal var _default: String? = nil
    
    open var value: String? {
        return _value ?? _default
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
            _value = strValue
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
    internal var _value: Bool = false
    override open var nargs: Int {
        didSet {
            if nargs > 1 {
                nargs = 1
            }
        }
    }
    
    open var value: Bool {
        return _value
    }
    
    override open var hasValue: Bool {
        return value == true
    }
    
    override open var isSatisfied: Bool {
        return true
    }
    
    override public func setValue(_ values: String...) -> Bool {
        if let boolValue = values.first {
            _value = Bool(boolValue)
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
    internal var _value: Int? = nil
    internal var _default: Int? = nil
    
    open var value: Int? {
        return _value ?? _default
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
            self._value = intValue
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
    internal var _value: Double? = nil
    internal var _default: Double? = nil
    
    open var value: Double? {
        return _value ?? _default
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
            self._value = doubleValue
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


// MARK: - Extensions
extension OptionType {
    /// Return the appropriate option type.
    public var option: Any {
        switch self {
        case .bool:
            return BoolOption.self
            
        case .string, .multiString:
            return StringOption.self
            
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


extension Option {
    
    public convenience init(named: String, helpString: String) {
        self.init(named: named, flag: nil, required: false, helpString: helpString)
    }
    
    public convenience init(named: String, flag: String, helpString: String) {
        self.init(named: named, flag: flag, required: false, helpString: helpString)
    }
}
