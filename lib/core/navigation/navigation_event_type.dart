/// Types of navigation events that can occur.
enum NavigationEventType {
  /// A route was pushed onto the navigator.
  push,

  /// A route was popped from the navigator.
  pop,

  /// A route was replaced with another.
  replace,

  /// A route was removed from the navigator.
  remove,
}
