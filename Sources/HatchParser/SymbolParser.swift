import SwiftSyntax
import SwiftParser

/// A SyntaxVistor subclass that parses swift code into a hierarchical list of symbols
open class SymbolParser: SyntaxVisitor {

    // MARK: - Private

    private var scope: Scope = .root(symbols: [])

    private var properties: [MemberProperty] = []

    // MARK: - Public

    /// Parses `source` and returns a hierarchical list of symbols from a string
    static public func parse(source: String) -> [Symbol] {
        let visitor = Self()
        visitor.walk(Parser.parse(source: source))
        return visitor.scope.symbols
    }

    /// Designated initializer
    required public init() {
        super.init(viewMode: .sourceAccurate)
    }

    /// Starts a new scope which can contain zero or more nested symbols
    public func startScope() -> SyntaxVisitorContinueKind {
        scope.start()
        return .visitChildren
    }

    /// Ends the current scope and adds the symbol returned by the closure to the symbol tree
    /// - Parameter makeSymbolWithChildrenInScope: Closure that return a new ``Symbol``
    ///
    /// Call in `visitPost(_ node:)` methods
    public func endScopeAndAddSymbol(makeSymbolWithChildrenInScope: (_ children: [Symbol]) -> Symbol) {
        scope.end(makeSymbolWithChildrenInScope: makeSymbolWithChildrenInScope)
        properties = []
    }

    // MARK: - SwiftSyntax overridden methods

    open override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        startScope()
    }

    open override func visitPost(_ node: ClassDeclSyntax) {
        endScopeAndAddSymbol { children in
            Class(
                name: node.name.text,
                children: children,
                inheritedTypes: node.inheritanceClause?.types ?? [],
                properties: properties
            )
        }
    }
    
    open override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        startScope()
    }

    open override func visitPost(_ node: ActorDeclSyntax) {
        endScopeAndAddSymbol { children in
            Actor(
                name: node.name.text,
                children: children,
                inheritedTypes: node.inheritanceClause?.types ?? [],
                properties: properties
            )
        }
    }

    open override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        startScope()
    }

    open override func visitPost(_ node: ProtocolDeclSyntax) {
        endScopeAndAddSymbol { children in
            Protocol(
                name: node.name.text,
                children: children,
                inheritedTypes: node.inheritanceClause?.types ?? [],
                properties: properties
            )
        }
    }

    open override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        startScope()
    }

    open override func visitPost(_ node: StructDeclSyntax) {
        endScopeAndAddSymbol { children in
            let newStruct = Struct(
                name: node.name.text,
                children: children,
                inheritedTypes: node.inheritanceClause?.types ?? [],
                properties: properties
            )
            properties = []
            return newStruct
        }
    }

    open override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        startScope()
    }

    open override func visitPost(_ node: EnumDeclSyntax) {
        endScopeAndAddSymbol { children in
            Enum(
                name: node.name.text,
                children: children,
                inheritedTypes: node.inheritanceClause?.types ?? []
            )
        }
    }

    open override func visit(_ node: EnumCaseDeclSyntax) -> SyntaxVisitorContinueKind {
        startScope()
    }
    
    open override func visitPost(_ node: EnumCaseDeclSyntax) {
        endScopeAndAddSymbol { children in
            EnumCase(children: children)
        }
    }

    open override func visit(_ node: EnumCaseElementSyntax) -> SyntaxVisitorContinueKind {
        startScope()
    }
    
    open override func visitPost(_ node: EnumCaseElementSyntax) {
        endScopeAndAddSymbol { children in
            EnumCaseElement(
                name: node.name.text,
                children: children
            )
        }
    }

    open override func visit(_ node: TypeAliasDeclSyntax) -> SyntaxVisitorContinueKind {
        startScope()
    }

    open override func visitPost(_ node: TypeAliasDeclSyntax) {
        endScopeAndAddSymbol { children in
            Typealias(
                name: node.name.text,
                existingType: node.initializer.value.trimmedDescription
            )
        }
    }

    open override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        startScope()
    }

    open override func visitPost(_ node: ExtensionDeclSyntax) {
        endScopeAndAddSymbol { children in
            Extension(
                name: node.extendedType.trimmedDescription,
                children: children,
                inheritedTypes: node.inheritanceClause?.types ?? []
            )
        }
    }
    
    // collect property info
    open override func visitPost(_ node: PatternBindingSyntax) {
        if let name = node.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
            if let typeAnnotation = node.typeAnnotation?.as(TypeAnnotationSyntax.self),
               let nonOptionalName = typeAnnotation.type.as(IdentifierTypeSyntax.self)?.name.text {
                properties.append(MemberProperty(accessControl: "", name: name, type: nonOptionalName))
            } else if let typeAnnotation = node.typeAnnotation?.as(TypeAnnotationSyntax.self),
                      let optionalName = typeAnnotation.type.as(OptionalTypeSyntax.self)?.wrappedType.as(IdentifierTypeSyntax.self)?.name.text {
                properties.append(MemberProperty(accessControl: "", name: name, type: optionalName + "?"))
            } else {
                properties.append(MemberProperty(accessControl: "", name: name, type: "_")) // type is not written?
            }
        }
    }
}

public extension InheritanceClauseSyntax {
    var types: [String] {
        inheritedTypes.map {
            $0.type.trimmedDescription
        }
    }
}
