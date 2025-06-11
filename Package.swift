// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-observability",
    platforms: [.iOS, .macOS],
    products: [
        .library("Observability"),
    ],
    dependencies: [
        .external(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.2"),
    ],
    targets: [
        .target("Observability", dependencies: [
            .external("Dependencies", package: "swift-dependencies"),
        ]),
        .test("Observability"),
    ]
)

/* --------- START SHARED CODE --------- */

// MARK: - SupportedPlatform

extension SupportedPlatform {
    /// The minimum deployment version for iOS across the solo project.
    static var iOS: SupportedPlatform { .iOS(.v26) }
    /// The minimum deployment version for macOS across the solo project.
    static var macOS: SupportedPlatform { .macOS(.v26) }
}

// MARK: - Product

extension Product {
    static func library(_ name: String, type: Library.LibraryType? = nil) -> Product {
        .library(name: name, type: type, targets: [name])
    }
}

// MARK: - Package.Dependency

extension Package.Dependency {
    /// Adds a package dependency that uses the version requirement, starting with the given minimum version,
    /// going up to the next major version.
    public static func external(
        url: String,
        from version: Version
    ) -> Package.Dependency {
        .package(url: url, from: version)
    }

    /// Adds a package dependency that uses the exact version requirement.
    public static func external(
        url: String,
        exact version: Version
    ) -> Package.Dependency {
        .package(url: url, exact: version)
    }

    /// Adds a remote package dependency given a branch requirement.
    public static func external(
        url: String,
        branch: String
    ) -> Package.Dependency {
        .package(url: url, branch: branch)
    }

    /// Adds a remote package dependency given a revision requirement.
    public static func external(
        url: String,
        revision: String
    ) -> Package.Dependency {
        .package(url: url, revision: revision)
    }

    public static var shared: Package.Dependency {
        .package(path: "../solo-shared")
    }
}

// MARK: - Target.Dependency

extension Target.Dependency {
    static func external(_ name: String, package: String) -> Target.Dependency {
        .product(name: name, package: package)
    }

    static func shared(_ name: String) -> Target.Dependency {
        .product(name: name, package: "solo-shared")
    }
}

// MARK: - Target

extension Target {
    static func target(
        _ name: String,
        dependencies: [PackageDescription.Target.Dependency] = [],
        path: String? = nil,
        exclude: [String] = [],
        sources: [String]? = nil,
        resources: [PackageDescription.Resource]? = nil,
        publicHeadersPath: String? = nil,
        packageAccess: Bool = true,
        cSettings: [PackageDescription.CSetting]? = nil,
        cxxSettings: [PackageDescription.CXXSetting]? = nil,
        swiftSettings: [PackageDescription.SwiftSetting]? = nil,
        linkerSettings: [PackageDescription.LinkerSetting]? = nil,
        plugins: [PackageDescription.Target.PluginUsage]? = nil
    ) -> Target {
        .target(
            name: name,
            dependencies: dependencies,
            path: path,
            exclude: exclude,
            sources: sources,
            resources: resources,
            publicHeadersPath: publicHeadersPath,
            packageAccess: packageAccess,
            cSettings: cSettings,
            cxxSettings: cxxSettings,
            swiftSettings: swiftSettings,
            linkerSettings: linkerSettings,
            plugins: plugins
        )
    }

    static func test(
            _ name: String,
            additionalDependencies: [Dependency] = [],
            path: String? = nil,
            exclude: [String] = [],
            sources: [String]? = nil,
            resources: [Resource]? = nil,
            packageAccess: Bool = true,
            cSettings: [CSetting]? = nil,
            cxxSettings: [CXXSetting]? = nil,
            swiftSettings: [SwiftSetting]? = nil,
            linkerSettings: [LinkerSetting]? = nil,
            plugins: [PluginUsage]? = nil
    ) -> Target {
        .testTarget(
            name: name + "Tests",
            dependencies: [.byName(name: name)] + additionalDependencies,
            path: path,
            exclude: exclude,
            sources: sources,
            resources: resources,
            packageAccess: packageAccess,
            cSettings: cSettings,
            cxxSettings: cxxSettings,
            swiftSettings: swiftSettings,
            linkerSettings: linkerSettings,
            plugins: plugins
        )
    }
}

/* ---------- END SHARED CODE ---------- */
