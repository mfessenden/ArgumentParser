//
//  Option.swift
//  ArgumentParser
//
//  Created by Michael Fessenden on 8/23/16.
//

//
//  Option.swift
//  ArgumentParser
//
//  Created by Michael Fessenden on 2/12/17.
//

import Foundation


public enum OptionGroup {
    case positional
    case options
    case actions
    case multi
}


public enum OptionType {
    case string
    case bool
    case integer
    case double
    case path
}


public enum NumArgs: String {
    case one        = "?"
    case list       = "*"
    case listOrOne  = "+"
}


// MARK: - Option Classes

/// Option base class
open class Option {
    open var name: String
    open var flags: [String] = []
    open var helpString: String? = nil
    open var metavar: String? = nil                 // description of the value type in usage (ie: path, input)
    open var isRequired: Bool = false               // is the option required?
    open var group: OptionGroup = .options          // Group type in help message.
    open var nargs: Int = 1                         // max number of values allowed (? - 1 value, or default)
                                                    //                              (* - args are split into list)
                                                    //                              (+ - same as *, but requires 1)
    open var hasValue: Bool {
        return false
    }
    
    open var flagsString: String? {
        return (flags.count != 0) ? flags.map {"-\($0)"}.joined(separator: ", ") : nil
    }
    
    open var usageString: String {
        let shortUsage = (flagsString == nil) ? "" : "\(flagsString!) "
        let metaFlag = metavar == nil ? "" : "  <\(metavar!)> "
        return "\(shortUsage)--\(name)\(metaFlag)"
    }
    
    public init(named: String, flag: String?=nil, required: Bool=false, helpString: String?=nil) {
        self.name = named.replacingOccurrences(of: " ", with: "-")
        
        if let flagArg = flag {
            self.flags.append(flagArg)
        }
        self.isRequired = required
        self.helpString = helpString
    }
    
    public init(named: String, flags: [String], required: Bool=false, helpString: String?=nil) {
        self.name = named.replacingOccurrences(of: " ", with: "-")
        self.flags = flags.uniqueElements
        self.isRequired = required
        self.helpString = helpString
    }
    
    public func setValue(_ values: String...) -> Bool {
        return false
    }
    
    public func setDefaultValue(_ value: Any) -> Bool {
        return false
    }
}


open class StringOption: Option {
    internal var _value: String? = nil
    internal var _default: String? = nil
    
    open var value: String? {
        return _value ?? _default
    }
    
    override open var hasValue: Bool {
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


open class BoolOption: Option {
    internal var _value: Bool = false
    
    open var value: Bool {
        return _value
    }
    
    override open var hasValue: Bool {
        return false
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
    internal var _value: Int? = nil
    internal var _default: Int? = nil
    
    open var value: Int? {
        return _value ?? _default
    }
    
    override open var hasValue: Bool {
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
    internal var _value: Double? = nil
    internal var _default: Double? = nil
    
    open var value: Double? {
        return _value ?? _default
    }
    
    override open var hasValue: Bool {
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
    internal static var fileManager = FileManager.default
    
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
            
        case .string:
            return StringOption.self
            
        case .integer:
            return IntegerOption.self
            
        case .double:
            return DoubleOption.self
            
        case .path:
            return PathOption.self
        }
        
    }
}


public func == (lhs: Option, rhs: String) -> Bool {
    return lhs.name == rhs || lhs.flagsString ?? "~" == rhs
}


public func == (lhs: Option, rhs: Option) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

extension Option: Hashable {
    public var hashValue: Int { return name.hashValue }
}


extension Option: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { return usageString }
    public var debugDescription: String { return description }
}


extension Option {
    
    public convenience init(named: String, helpString: String) {
        self.init(named: named, flag: nil, required: false, helpString: helpString)
    }
    
    public convenience init(named: String, flag: String, helpString: String) {
        self.init(named: named, flag: flag, required: false, helpString: helpString)
    }
}
