import Foundation

// MARK: - LogHandlerBuilder

public typealias LogHandlerBuilder = ArrayBuilder<any LogHandler>

// MARK: - EventHandlerBuilder

public typealias EventHandlerBuilder = ArrayBuilder<any EventHandler>

// MARK: - ArrayBuilder

/// A result builder that allows you to build a collection of elements.
///
/// Array builders uses an enum under the hood to build components without allocating unnecessary arrays.
/// During the final result, the component enumeration is converted into an array of elements and returned.
@resultBuilder
public enum ArrayBuilder<Element> {

    // MARK: Component

    /// A component used to cut down on the number of arrays allocated.
    public enum Component {
        case array([Element])
        case element(Element)
        case empty
    }

    // MARK: Builders

    public static func buildExpression(_ element: Element) -> Component {
        .element(element)
    }

    public static func buildBlock(_ components: Component...) -> Component {
        buildArray(components)
    }

    public static func buildArray(_ components: [Component]) -> Component {
        let array: [Element] = components.reduce(into: []) { array, component in
            switch component {
            case .array(let components):
                array.append(contentsOf: components)
            case .element(let element):
                array.append(element)
            case .empty:
                break
            }
        }

        return .array(array)
    }

    public static func buildEither(first component: Component) -> Component {
        component
    }

    public static func buildEither(second component: Component) -> Component {
        component
    }

    public static func buildOptional(_ component: Component?) -> Component {
        component ?? .empty
    }

    public static func buildLimitedAvailability(_ component: Component) -> Component {
        component
    }

    static func buildFinalResult(_ component: Component) -> [Element] {
        switch component {
        case .array(let array): array
        case .element(let element): [element]
        case .empty: []
        }
    }
}
