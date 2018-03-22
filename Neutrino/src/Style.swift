import UIKit

// MARK: - UIStyle

open class UIStyle: UIStyleProtocol {
  static var notApplicableStyleIdentifier: String = "__UIStyleNotApplicableStyleIdentifier"
  public let styleIdentifier: String = UIStyle.notApplicableStyleIdentifier

  public init() { }

  /// Applies the style to the view passed as argument.
  open func apply(to view: UIView) { }
}

open class UILayoutSpecStyle<V: UIView>: UIStyle {
  // The current layout specification.
  var layoutSpec: UINode<V>.LayoutSpec? = nil
  private var applicationClosure: (UINode<V>.LayoutSpec) -> Void = { _ in }

  public init(_ closure: @escaping (UINode<V>.LayoutSpec) -> Void) {
    applicationClosure = closure
    super.init()
  }

  override open func apply(to view: UIView) {
    guard let _ = view as? V, let layoutSpec = layoutSpec else { return }
    applicationClosure(layoutSpec)
  }

  /// Reset all of the style arguments.
  public func reset() {
    layoutSpec = nil
  }
}

// MARK: - UIStyleProtocol

public protocol UIStyleProtocol {
  /// The full path for this style {NAMESPACE.STYLE(.MODIFIER)?}.
  /// - note: Not necessary for *UIStyle* subclasses.
  var styleIdentifier: String { get }
  /// Applies this style to the view passed as argument.
  /// - note: Non KVC-compliant keys are skipped if this is a style generated from a stylesheet.
  func apply(to view: UIView)
}

public class UINilStyle: UIStyle {
  public static let `nil` = UINilStyle()
  /// No operation.
  public override func apply(to view: UIView) { }
}
