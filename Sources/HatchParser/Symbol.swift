import Foundation

// MARK: - Symbol Protocol

/// Represents a Swift type or symbol
public protocol Symbol {
    var children: [Symbol] { get }
}

/// Represent a Swift type that can inherit from or conform to other types
public protocol InheritingSymbol {
    var name: String { get }
    var inheritedTypes: [String] { get }
}

public protocol PropertiedSymbol {
    var properties: [MemberProperty] { get }
}

// MARK: - Concrete Symbols
public struct MemberProperty {
    public let accessControl: String
    public let name: String
    public let type: String
}

/// A swift protocol
public typealias ProtocolType = Protocol

public struct Protocol: Symbol, InheritingSymbol, PropertiedSymbol {
    public let name: String
    public let children: [Symbol]
    public let inheritedTypes: [String]
    public let properties: [MemberProperty]
}

/// A swift class
public struct Class: Symbol, InheritingSymbol, PropertiedSymbol {
    public let name: String
    public let children: [Symbol]
    public let inheritedTypes: [String]
    public let properties: [MemberProperty]
}

/// A swift actor
public struct Actor: Symbol, InheritingSymbol, PropertiedSymbol {
    public let name: String
    public let children: [Symbol]
    public let inheritedTypes: [String]
    public let properties: [MemberProperty]
}

/// A swift struct
public struct Struct: Symbol, InheritingSymbol, PropertiedSymbol {
    public let name: String
    public let children: [Symbol]
    public let inheritedTypes: [String]
    public let properties: [MemberProperty]
}

/// A swift enum
public struct Enum: Symbol, InheritingSymbol  {
    public let name: String
    public let children: [Symbol]
    public let inheritedTypes: [String]
}

/// A single case of a swift enum
public struct EnumCase: Symbol  {
    public let children: [Symbol]
}

/// A single element of a swift enum case
public struct EnumCaseElement: Symbol  {
    public let name: String
    public let children: [Symbol]
}

/// A swift typealias to an existing type
public struct Typealias: Symbol  {
    public let name: String
    public let existingType: String
    public let children: [Symbol] = []
}

/// A swift extension
public struct Extension: Symbol, InheritingSymbol  {
    public let name: String
    public let children: [Symbol]
    public let inheritedTypes: [String]
}
