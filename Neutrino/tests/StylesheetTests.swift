import XCTest
import UIKit
@testable import RenderNeutrino

class StylesheetTests: XCTestCase {

  let test: String = "Test"
  var parser: UIStylesheetManager = UIStylesheetManager()

  override func setUp() {
    parser = UIStylesheetManager()
    try! parser.load(yaml: standardDefs)
  }

  func testCGFloat() {
    XCTAssert(parser.rule(style: test, name: "cgFloat")?.cgFloat == 42.0)
  }
  func testBool() {
    XCTAssert(parser.rule(style: test, name: "bool")?.bool == true)
  }
  func testInt() {
    XCTAssert(parser.rule(style: test, name: "integer")?.integer == 42)
  }
  func testCGFloatExpression() {
    XCTAssert(parser.rule(style: test, name: "cgFloatExpr")?.cgFloat == 42.0)
  }
  func testBoolExpression() {
    XCTAssert(parser.rule(style: test, name: "boolExpr")?.bool == true)
  }
  func testIntExpression() {
    XCTAssert(parser.rule(style: test, name: "integerExpr")?.integer == 42)
  }
  func testConstExpression() {
    XCTAssert(parser.rule(style: test, name: "const")?.cgFloat == 320)
  }
  func testColor() {
    let value = parser.rule(style: test, name: "color")?.color
    XCTAssert(value!.cgColor.components![0] == 1)
    XCTAssert(value!.cgColor.components![1] == 0)
    XCTAssert(value!.cgColor.components![2] == 0)
  }
  func testFont() {
    let value = parser.rule(style: test, name: "font")?.font
    XCTAssert(value!.pointSize == 42.0)
  }
  func testConditionalFloat() {
    XCTAssert(parser.rule(style: test, name: "conditionalFloat")?.cgFloat == 42.0)
  }
  func testConditionalFloatWithMultipleConditions() {
    XCTAssert(parser.rule(style: test, name: "multipleConditionalFloat")?.cgFloat == 42.0)
  }
  func testConditionalFloatWithMultipleExpressions() {
    XCTAssert(parser.rule(style: test, name: "multipleConditionalFloatWithExpr")?.cgFloat == 42.0)
  }
  func testEnum() {
    XCTAssert(parser.rule(style: test, name: "enum")?.enum(NSTextAlignment.self) == .right)
  }
  func testAccessFromStylesheetEnum() {
    try! UIStylesheetManager.default.load(yaml: fooDefs)
    XCTAssert(FooStylesheet.bar.cgFloat == 42)
    XCTAssert(FooStylesheet.baz.cgFloat == 42)
    XCTAssert(FooStylesheet.bax.bool)
  }
  func testApplyStyleseetToView() {
    try! UIStylesheetManager.default.load(yaml: viewDefs)
    let view = UIView()
    ViewStylesheet.apply(to: view)
    let value = view.backgroundColor
    XCTAssert(value!.cgColor.components![0] == 1)
    XCTAssert(value!.cgColor.components![1] == 0)
    XCTAssert(value!.cgColor.components![2] == 0)
    XCTAssert(view.borderWidth == 1)
    XCTAssert(view.yoga.margin == 10)
    XCTAssert(view.yoga.flexDirection == .row)
  }
  func testRefValues() {
    XCTAssert(parser.rule(style: test, name: "cgFloat")?.cgFloat == 42.0)
    XCTAssert(parser.rule(style: test, name: "refValue")?.cgFloat == 42.0)
  }
  func testInheritance() {
    XCTAssert(parser.rule(style: "Foo", name: "foo")?.cgFloat == 1)
    XCTAssert(parser.rule(style: "Bar", name: "foo")?.cgFloat == 1)
    XCTAssert(parser.rule(style: "Bar", name: "bar")?.cgFloat == 2)
  }
}

let standardDefs = """
Test:
  cgFloat: &_cgFloat 42
  refValue: *_cgFloat
  bool: true
  integer: 42
  enum: ${NSTextAlignment.right}
  cgFloatExpr: ${41+1}
  boolExpr: ${1 == 1 && true}
  integerExpr: ${41+1}
  const: ${iPhoneSE.width}
  color: !!color(#ff0000)
  font: !!font(Arial,42)
  conditionalFloat:
    ${false}: 41
    ${default}: 42
  multipleConditionalFloat:
    ${false}: 41
    ${1 == 1}: 42
    ${default}: 1
  multipleConditionalFloatWithExpr:
    ${false}: 41
    ${1 == 1}: ${41+1}
    ${default}: 1
Foo: &_Foo
  foo:  1
Bar:
  <<: *_Foo
  bar: 2
"""

enum FooStylesheet: String, UIStylesheet {
  static let name: String = "Foo"
  case bar, baz, bax
}

let fooDefs = """
Foo:
  bar: 42
  baz: ${41+1}
  bax: true
"""

enum ViewStylesheet: String, UIStylesheet {
  static let name: String = "View"
  case customNonApplicableProperty
}

let viewDefs = """
View:
  backgroundColor: !!color(#ff0000)
  borderWidth: 1
  flexDirection: ${row}
  margin: 10
  customNonApplicableProperty: 42
"""