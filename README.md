# 🔭 SoloObservability

An observability framework that provides a core foundation for logging `logs` and tracking `events`. This framework exposes a configurable `logger` and `tracker` that consumers can use to handle `logging` and `tracking` in their system.

## Terminology
| Term               | Description                                                  |
|--------------------|--------------------------------------------------------------|
| `Emitter`          | An object that can emit an `Emission`<br><br>Both `Logger` and `Tracker` are implementations of an `Emitter`. |
| `Emission`         | An object emitted from an `Emitter`<br><br>Both `Log` and `Tracker` are implementations of an `Emissions` |
| `Emission Handler` | An object that recieves `Emissions` emitted from an `Emitter`<br><br>Both `LogHandler` and `EventHandler` are implementations of an `Emission Hanlder` |

## Basic Usage
This section outlines the absolute core necessities to start sending `Logs` and `Events` to your own custom handlers.

### `Logger`
The `Logger` type is a style of emitter that emits `Log` messages. Logs are categorized by their `Level` of severity. In addition, each `Log` can contain associated `Metadata`.

### `Tracker`
The `Tracker` type is a style of emitter that emits `Event` messages. Events have a name and can contain associated `Metadata`.

### Dependencies
Both `Logger` and `Tracker` are exposed through the `@Dependency` property wrapper. This dependency injection service is provided by the [PointFree Dependencies framework](https://github.com/pointfreeco/swift-dependencies) .

```swift
// A container for all current and future observability tools.
@Dependency(\.observability) var observability

// Retrieves the current logger.
@Dependency(\.logger) var logger
// 👆 Short hand for 👇
// @Dependency(\.observability.logger) var logger

// Retrieves the current tracker.
@Dependency(\.tracker) var tracker
// 👆 Short hand for 👇
// @Dependency(\.observability.tracker) var tracker
```

### Sending `Logs` & Tracking `Events`
`Logs` and `Events` are sent with a very basic interface on `Logger` and `Tracker` respectively.

```swift
// Get the current logger.
@Dependency(\.logger) var logger
// Log a message
logger.log(.warning, "The cat escaped the house!")
// Log a message with some metadata
logger.log(.warning, "The engine is overheating!", metadata: [
    "make": "BMW",
    "model": "M2 Competition",
])

// Get the current tracker.
@Dependency(\.tracker) var tracker
// Track an event.
logger.track("CAT DID START PURRING")
// Log a message with some metadata
logger.track("ENGINE DID STALL", metadata: [
    "make": "BMW",
    "model": "M2 Competition",
])
```

### Handling `Logs` & `Events`
The default implementations of `Logger` and `Tracker` don’t make many assumptions about what you want to do with the emissions. In `DEBUG`, the default implementations simply output `Logs` and `Events` to the console. In `RELEASE`, they do nothing.

> [!CAUTION]
> When implementing your own handlers, you should respect a few requirements that are necessary so that observability works regardless of your handler’s implementation.
> - Handlers should operate as values types, or implement copy on write semantics. It is strongly recommended to use a `struct` to avoid unnecessary risks.

To customize the handling of each emitter, you must conform to their respective handler protocols.

#### `LogHandler`
In order to handle `Log` emissions from a `Logger`, you must conform to `LogHandler`

```swift
struct CustomLogHandler: LogHandler {
    ...

    /// The log handler's log level will be used to determine whether
    /// the handler should be notified of individual logs.
    /// Any log level less than `.warning` will be ignored.
    let level: Log.Level = .warning
    /// Called by the logger when there is a log that meets or exceeds
    /// The handler's log severity level.
    func log(_ log: Log) {
        let name = event.name
        let metadata = event.metadata
        /// Implement the functionality to handle emitted logs.
        service.publish(name: name, metadata: metadata)
    }
}
```

#### `EventHandler`
In order to handle `Event` emissions from a `Tracker`, you must conform to `EventHandler`

```swift
struct CustomEventHandler: EventHandler {
    ...

    /// Called by the tracker when there is an event.
    func track(_ event: Event) {
        let name = event.name
        let metadata = event.metadata
        /// Implement the functionality to handle emitted logs.
        service.publish(name: name, metadata: metadata)
    }
}
```

### Attaching Emission Handlers
Observability makes use of the `TaskLocal` values through [PointFree’s Dependencies framework](https://github.com/pointfreeco/swift-dependencies). This allows you to “scope” your configuration, layering on more handlers and context within different areas of your application.

You can make use of`withLogHandlers`, `withEventHandlers` to add or override the handlers for the scope of a given operation, as well as extending the scope for any structured concurrency tasks spawned from that scope.

##### `Logger`
```swift
/// Working with `Logger`...
withLogHandlers(shouldReplaceExistingHandlers: true) {
    /// @LogHandlerResultBuilder allows defining handlers similar to
    /// how you would define SwiftUI views.
    CustomLogHandlerA()
} operation {
    @Dependency(\.logger) var logger
    /// CustomLogHandler will receive the log.
    logger.log(.debug, "We won the lottery!")

    Task {
        @Dependency(\.logger) var taskLogger
        /// CustomLogHandler will receive the log.
        taskLogger.log(.debug, "We lost the lottery!")
    }
}

@Dependency(\.logger) var outOfScopeLogger
/// CustomLogHandler will NOT receive the log.
outOfScopeLogger.log(.debug, "We lost the lottery!")
```
#### `Tracker`
```swift
withEventHandlers(shouldReplaceExistingHandlers: true) {
    /// @EventHandlerResultBuilder allows defining handlers similar to
    /// how you would define SwiftUI views.
    CustomEventHandlerA()
} operation {
    @Dependency(\.tracker) var tracker
    /// CustomEventHandler will receive the event.
    tracker.track("LOTTERY TICKET PURCHASED")

    Task {
        @Dependency(\.tracker) var taskTracker
        /// CustomEventHandler will receive the event.
        taskTracker.track("LOTTERY PRIZE CLAIMED")
    }
}

@Dependency(\.tracker) var outOfScopeTracker
/// CustomEventHandler will NOT receive the event.
outOfScopeTracker.track("LOTTERY PRIZE SPENT")
```

To read more about how dependency lifetimes work with `TaskLocal` values, you can read [PointFree’s Dependency Lifetimes Documentation.](https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/lifetimes).

## Advanced Usage
This section outlines more functionality and features available within the `Observability` framework.

### `Metadata`
There are many instances in which you may want to send additional context along with your `Logs` or `Events`. This can be done by applying `Metadata` in a few ways…

- You can use the functions `log(_:_:metadata:)` or `track(_:metadata:)` to add `Metadata` to the specific `Log` or `Event` this is sent.

- You can modify the `Logger` or `Tracker` metadata directly through the `metadata` property or the `metadataKey` subscript.

- You can apply metadata for the duration of a scoped operation using `withLoggerMetadata(_:uniquingKeysWith:operation:)` or `withTrackerMetadata(_:uniquingKeysWith:operation:)`

#### `Logger`
```swift
@Dependency(\.logger) var logger
var loggerWithMetadata = logger
/// Update the entire metadata.
loggerWithMetadata.metadata = ["candy": “Skittles"]
/// Update an individual key.
loggerWithMetadata[metadataKey: "candy"] = "Sour Skittles"

/// Will contain ["candy": "Sour Skittles"] as metadata.
loggerWithMetadata.log(.warning, "Stop eating so much sugar!")

/// Will contain ["candy": "Sour Skittles", "drink": "Lucozade"] as metadata.
loggerWithMetadata.log(.warning, "Seriously stop!", metadata: [
    "drink": "Lucozade"
])

withLoggerMetadata(["crisps": "Quavers"]) {
    @Dependency(\.logger) var scopedLogger
    /// Will contain ["crisps": "Quavers"] as metadata.
    scopedLogger.log(.warning, "You're out of control!")
}

/// Original logger contains no metadata.
logger.log(.warning, "No Metadata")
```
#### `Tracker`
```swift
@Dependency(\.tracker) var tracker
var trackerWithMetadata = tracker
/// Update the entire metadata.
trackerWithMetadata.metadata = ["candy": “Skittles"]
/// Update an individual key.
trackerWithMetadata[metadataKey: "candy"] = "Sour Skittles"

/// Will contain ["candy": "Sour Skittles"] as metadata.
trackerWithMetadata.track("EATING CANDY")

/// Will contain ["candy": "Sour Skittles", "drink": "Lucozade"] as metadata.
trackerWithMetadata.track("IGNORING ADVICE", metadata: [
    "drink": "Lucozade"
])

withTrackerMetadata(["crisps": "Quavers"]) {
    @Dependency(\.tracker) var scopedTracker
    /// Will contain ["crisps": "Quavers"] as metadata.
    scopedTracker.track("EATING JUNK FOOD")
}

/// Original tracker contains no metadata.
tracker.track("NO METADATA")
```

### `MetadataProviders`

Metadata providers operate very similarly to `Metadata` except they provide their `Metadata` at the time of the emission. Providers can be used to inject metadata from other sources that are potentially dynamic and changing. This could be done through injected dependencies or through `TaskLocal` values.

```swift
struct UserMetadataProvider: MetadataProvider {
    ...
    var metadata: Metadata {
        return [
            "id": userRepository.user.id
        ]
    }
}
```

Attaching a `MetadataProvider` can be done in a few ways…

- You can attach the provider to your `Logger` or `Tracker` using the `metadataProvider` property.

- You can attach the provider to your `LogHandler` or `EventHandler` using the `metadataProvider` property.

- You can apply metadata for the duration of a scoped operation using `withTrackerMetadataProvider(shouldReplaceExistingMetadata:_:operation:)` or `withTrackerMetadataProvider(shouldReplaceExistingMetadata:_:operation:)`

#### `Logger`
```swift
@Dependency(\.logger) var logger
var loggerWithMetadataProvider = logger
loggerWithMetadataProvider.metadataProvider = UserMetadataProvider()

/// Will contain ["id": "<user_id>"] as metadata, collected at the
/// the log is emitted.
loggerWithMetadata.log(.warning, "Missed the bus!")

withTrackerMetadataProvider {
    BusMetadataProvider()
} operation: {
    @Dependency(\.logger) var scopedLogger
    /// Will contain ["id": "<user_id>", "bus": "3"] as metadata,
    /// collected at the time the log is emitted.
    scopedLogger.log(.warning, "Chasing the bus!")
}

/// Original logger contains no metadata provider.
logger.log(.warning, "No Metadata")
```
#### `Tracker`
```swift
@Dependency(\.tracker) var tracker
var trackerithMetadataProvider = tracker
trackerWithMetadataProvider.metadataProvider = UserMetadataProvider()

/// Will contain ["id": "<user_id>"] as metadata, collected at the
/// the log is emitted.
trackerWithMetadata.track("DID MISSED BUS")

withTrackerMetadataProvider {
    BusMetadataProvider()
} operation: {
    @Dependency(\.tracker) var scopedTracker
    /// Will contain ["id": "<user_id>", "bus": "3"] as metadata,
    /// collected at the time the event is emitted.
    scopedLogger.track("DID START BUS CHASE")
}

/// Original tracker contains no metadata provider.
tracker.track("NO METADATA")
```

### `withObservability`, `withLogger` & `withTracker`

Additional scoping functions are provided in order to directly manipulate the current `Logger` and `Tracker` objects for the duration of a given operation. These functiona are provided as a convenience around `withDependencies` from PointFree.

```swift
withObservability {
    /// Updates the labels of the two observability tools
    /// for the duration of the operation.
    $0.logger.label = "my.custom.logger"
    $0.tracker.label = "my.custom.tracker"
} operation: {
    ...
}

withLogger {
    /// Updates the log level for all of the logger's current handlers
    /// for the duration of the operation.
    $0.logger.level = .critical
} operation: {
    ...
}

withTracker {
    /// Update the tracker's metadata provider for duration of the
    /// operation.
    $0.metadataProvider = MyCustomMetadataProvider()
} operation: {
    ...
}
```



