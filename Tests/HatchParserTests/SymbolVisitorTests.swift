import XCTest
@testable import HatchParser

final class SymbolVisitorTests: XCTestCase {

    func testExtractingStruct() throws {
        let code = """
        struct MyStruct {
        }
        """

        let structs = SymbolParser.parse(source: code)
            .compactMap { $0 as? Struct }

        XCTAssertEqual(structs.count, 1)
        XCTAssertEqual(structs.first?.name, "MyStruct")
    }

    func testExtractingNestedStructs() throws {
        let code = """
        enum MyEnum {
          struct MyNestedStructA {}
          struct MyNestedStructB {}
        }
        """

        let symbols = SymbolParser.parse(source: code)
            .flattened()

        let structs = symbols
            .compactMap { $0 as? Struct }

        XCTAssertEqual(symbols.count, 3)
        XCTAssertEqual(structs.count, 2)
        XCTAssertEqual(structs[0].name, "MyNestedStructA")
        XCTAssertEqual(structs[1].name, "MyNestedStructB")
    }

    func testExtractingGenericStruct() throws {
        let code = """
        struct MyStruct<T> where T: StringProtocol {
        }
        """

        let structs = SymbolParser.parse(source: code)
            .compactMap { $0 as? Struct }

        XCTAssertEqual(structs.count, 1)
        XCTAssertEqual(structs.first?.name, "MyStruct")
    }

    func testExtractingInheritingStruct() throws {
        let code = """
        struct MyStruct: Error, StringProtocol {
        }
        """

        let structs = SymbolParser.parse(source: code)
            .compactMap { $0 as? Struct }

        XCTAssertEqual(structs.count, 1)
        XCTAssertEqual(structs.first?.name, "MyStruct")
        XCTAssertEqual(structs.first?.inheritedTypes, ["Error", "StringProtocol"])
    }

    func testExtractingClass() throws {
        let code = """
        class MyClass {
        }
        """

        let classes = SymbolParser.parse(source: code)
            .compactMap { $0 as? Class }

        XCTAssertEqual(classes.count, 1)
        XCTAssertEqual(classes.first?.name, "MyClass")
    }

    func testExtractingNestedClasses() throws {
        let code = """
        enum MyEnum {
          class MyNestedClassA {}
          class MyNestedClassB {}
        }
        """

        let symbols = SymbolParser.parse(source: code)
            .flattened()

        let classes = symbols
            .compactMap { $0 as? Class }

        XCTAssertEqual(symbols.count, 3)
        XCTAssertEqual(classes.count, 2)
        XCTAssertEqual(classes[0].name, "MyNestedClassA")
        XCTAssertEqual(classes[1].name, "MyNestedClassB")
    }

    func testExtractingInhertingClass() throws {
        let code = """
        class MyClass: OtherModule.OtherClass, MyProtocol {
        }
        """

        let classes = SymbolParser.parse(source: code)
            .compactMap { $0 as? Class }

        XCTAssertEqual(classes.count, 1)
        XCTAssertEqual(classes.first?.name, "MyClass")
        XCTAssertEqual(classes.first?.inheritedTypes, ["OtherModule.OtherClass", "MyProtocol"])
    }

    func testExtractingEnum() throws {
        let code = """
        enum MyEnum {
            case x, y
            case a(number: Int, text: String)
            case b
            case c
        }
        """

        let enums = SymbolParser.parse(source: code)
            .compactMap { $0 as? Enum }

        let cases = enums.first?.children.flattened()
            .compactMap { $0 as? EnumCaseElement }
            .map(\.name)

        XCTAssertEqual(enums.count, 1)
        XCTAssertEqual(enums.first?.name, "MyEnum")
        XCTAssertEqual(cases, ["x", "y", "a", "b", "c"])
    }


    func testExtractingGenericEnum() throws {
        let code = """
        enum MyEnum<T> where T: StringProtocol {
            case x
            case y(Array<T>)
        }
        """

        let enums = SymbolParser.parse(source: code)
            .compactMap { $0 as? Enum }

        let cases = enums.first?.children.flattened()
            .compactMap { $0 as? EnumCaseElement }
            .map(\.name)

        XCTAssertEqual(enums.count, 1)
        XCTAssertEqual(enums.first?.name, "MyEnum")
        XCTAssertEqual(cases, ["x", "y"])
    }

    func testExtractingInhertingEnum() throws {
        let code = """
        enum MyEnum: Error {
            case x
            case y
        }
        """

        let enums = SymbolParser.parse(source: code)
            .compactMap { $0 as? Enum }

        XCTAssertEqual(enums.count, 1)
        XCTAssertEqual(enums.first?.name, "MyEnum")
        XCTAssertEqual(enums.first?.inheritedTypes, ["Error"])
    }

    func testExtractingNestedEnum() throws {
        let code = """
        enum MyEnum {
            enum MyNestedEnum {
                case a
                case b
            }
        }
        """

        let enums = SymbolParser.parse(source: code)
            .flattened()
            .compactMap { $0 as? Enum }

        XCTAssertEqual(enums.count, 2)
        XCTAssertEqual(enums[0].name, "MyEnum")
        XCTAssertEqual(enums[1].name, "MyNestedEnum")
    }

    func testExtractingProtocol() throws {
        let code = """
        protocol MyProtocol {
            func foo()
            var text: String { get }
        }
        """

        let protocols = SymbolParser.parse(source: code)
            .compactMap { $0 as? ProtocolType }

        XCTAssertEqual(protocols.count, 1)
        XCTAssertEqual(protocols.first?.name, "MyProtocol")
    }

    func testExtractingInheritingProtocol() throws {
        let code = """
        protocol MyProtocol: Hashable, Error {}
        """

        let protocols = SymbolParser.parse(source: code)
            .compactMap { $0 as? ProtocolType }

        XCTAssertEqual(protocols.count, 1)
        XCTAssertEqual(protocols.first?.name, "MyProtocol")
        XCTAssertEqual(protocols.first?.inheritedTypes, ["Hashable", "Error"])
    }

    func testExtractingTypealias() throws {
        let code = """
        typealias MyAlias = Int
        """

        let aliases = SymbolParser.parse(source: code)
            .compactMap { $0 as? Typealias }

        XCTAssertEqual(aliases.count, 1)
        XCTAssertEqual(aliases.first?.name, "MyAlias")
        XCTAssertEqual(aliases.first?.existingType, "Int")
    }

    func testExtractingTypealiasWithCompositeTypes() throws {
        let code = """
        typealias MyAlias = StringProtocol & View
        """

        let aliases = SymbolParser.parse(source: code)
            .compactMap { $0 as? Typealias }

        XCTAssertEqual(aliases.count, 1)
        XCTAssertEqual(aliases.first?.name, "MyAlias")
        XCTAssertEqual(aliases.first?.existingType, "StringProtocol & View")
    }

    func testExtractingNestedTypealiases() throws {
        let code = """
        enum MyEnum {
            typealias MyAlias = Int
        }
        """

        let aliases = SymbolParser.parse(source: code)
            .flattened()
            .compactMap { $0 as? Typealias }

        XCTAssertEqual(aliases.count, 1)
        XCTAssertEqual(aliases.first?.name, "MyAlias")
        XCTAssertEqual(aliases.first?.existingType, "Int")
    }

    func testExtractingExtension() throws {
        let code = """
        extension String: MyProtocol {
        }
        """

        let extensions = SymbolParser.parse(source: code)
            .compactMap { $0 as? Extension }

        XCTAssertEqual(extensions.count, 1)
        XCTAssertEqual(extensions.first?.name, "String")
        XCTAssertEqual(extensions.first?.inheritedTypes.first, "MyProtocol")
    }
    
    func testExtractingActor() throws {
          let code = """
          actor MyActor {
          }
          """

          let actors = SymbolParser.parse(source: code)
              .compactMap { $0 as? Actor }

          XCTAssertEqual(actors.count, 1)
          XCTAssertEqual(actors.first?.name, "MyActor")
      }

      func testExtractingNestedActor() throws {
          let code = """
          enum MyEnum {
            actor MyNestedActorA {}
            actor MyNestedActorB {}
          }
          """

          let symbols = SymbolParser.parse(source: code)
              .flattened()

          let actors = symbols
              .compactMap { $0 as? Actor }

          XCTAssertEqual(symbols.count, 3)
          XCTAssertEqual(actors.count, 2)
          XCTAssertEqual(actors[0].name, "MyNestedActorA")
          XCTAssertEqual(actors[1].name, "MyNestedActorB")
      }

      func testExtractingGenericActor() throws {
          let code = """
          actor MyActor<T> where T: StringProtocol {
          }
          """

          let actors = SymbolParser.parse(source: code)
              .compactMap { $0 as? Actor }

          XCTAssertEqual(actors.count, 1)
          XCTAssertEqual(actors.first?.name, "MyActor")
      }

      
      func testExtractingInheritingActor() throws {
          let code = """
          actor MyActor: Error, Sendable {
          }
          """

          let actors = SymbolParser.parse(source: code)
              .compactMap { $0 as? Actor }

          XCTAssertEqual(actors.count, 1)
          XCTAssertEqual(actors.first?.name, "MyActor")
          XCTAssertEqual(actors.first?.inheritedTypes, ["Error", "Sendable"])
      }
}
