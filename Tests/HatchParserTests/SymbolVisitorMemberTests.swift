//
//  SymbolVisitorMemberTests.swift
//
//  Created by : Tomoaki Yagishita on 2023/10/19
//  © 2023  SmallDeskSoftware
//

import XCTest
@testable import HatchParser

final class SymbolVisitorMemberTests: XCTestCase {

    func testExtractingStructWithMember() throws {
        let code = """
        struct MyStruct {
            let value: Int = 3
        }
        """

        let structs = SymbolParser.parse(source: code)
            .compactMap { $0 as? Struct }

        XCTAssertEqual(structs.count, 1)
        let structInfo = try XCTUnwrap(structs.first)
        
        XCTAssertEqual(structInfo.name, "MyStruct")
        XCTAssertEqual(structInfo.properties.count, 1)
        let propertyInfo = try XCTUnwrap(structInfo.properties.first)
        XCTAssertEqual(propertyInfo.name, "value")
        XCTAssertEqual(propertyInfo.type, "Int")
    }
    
    func testExtractingStructWithOptionalMember() throws {
        let code = """
        struct MyStruct {
            let value: Int? = 3
        }
        """

        let structs = SymbolParser.parse(source: code)
            .compactMap { $0 as? Struct }

        XCTAssertEqual(structs.count, 1)
        let structInfo = try XCTUnwrap(structs.first)
        
        XCTAssertEqual(structInfo.name, "MyStruct")
        XCTAssertEqual(structInfo.properties.count, 1)
        let propertyInfo = try XCTUnwrap(structInfo.properties.first)
        XCTAssertEqual(propertyInfo.name, "value")
        XCTAssertEqual(propertyInfo.type, "Int?")
    }
    
    func testExtractingStructWithUnknownTypeMember() throws {
        let code = """
        struct MyStruct {
            let value = 3
        }
        """

        let structs = SymbolParser.parse(source: code)
            .compactMap { $0 as? Struct }

        XCTAssertEqual(structs.count, 1)
        let structInfo = try XCTUnwrap(structs.first)
        
        XCTAssertEqual(structInfo.name, "MyStruct")
        XCTAssertEqual(structInfo.properties.count, 1)
        let propertyInfo = try XCTUnwrap(structInfo.properties.first)
        XCTAssertEqual(propertyInfo.name, "value")
        XCTAssertEqual(propertyInfo.type, "_")
    }
    
    func testExtractingClassWithMember() throws {
        let code = """
        class MyClass {
            let value: Int = 3
        }
        """

        let classes = SymbolParser.parse(source: code)
            .compactMap { $0 as? Class }

        XCTAssertEqual(classes.count, 1)
        let classInfo = try XCTUnwrap(classes.first)
        
        XCTAssertEqual(classInfo.name, "MyClass")
        XCTAssertEqual(classInfo.properties.count, 1)
        let propertyInfo = try XCTUnwrap(classInfo.properties.first)
        XCTAssertEqual(propertyInfo.name, "value")
        XCTAssertEqual(propertyInfo.type, "Int")
    }
    func testExtractingClassWithOptionalMember() throws {
        let code = """
        class MyClass {
            let value: Int? = 3
        }
        """

        let classes = SymbolParser.parse(source: code)
            .compactMap { $0 as? Class }

        XCTAssertEqual(classes.count, 1)
        let classInfo = try XCTUnwrap(classes.first)
        
        XCTAssertEqual(classInfo.name, "MyClass")
        XCTAssertEqual(classInfo.properties.count, 1)
        let propertyInfo = try XCTUnwrap(classInfo.properties.first)
        XCTAssertEqual(propertyInfo.name, "value")
        XCTAssertEqual(propertyInfo.type, "Int?")
    }
}
