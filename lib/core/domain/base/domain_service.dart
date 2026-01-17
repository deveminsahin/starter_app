import 'package:starter_app/core/domain/base/base.dart'
    show Entity, ValueObject;

/// Base interface for Domain Services.
///
/// In Domain-Driven Design, a Domain Service is used when a specific operation,
/// rule, or logic does not naturally fit
///  within a single [Entity] or [ValueObject].
///
/// **When to use a Domain Service:**
/// - The logic involves multiple entities
///  (e.g., transferring money between two accounts).
/// - The logic requires access to a repository
///  to check global state (e.g., ensuring email uniqueness).
/// - The logic is complex calculation that doesn't belong to a specific object.
///
/// **Orchestration vs Domain Events:**
/// - **Use Domain Service (Orchestration)** when operations **must** happen
///   together to maintain data consistency (Create User + Create Profile).
///   This ensures the system doesn't end up in an invalid partial state.
/// - **Use Domain Events (Fire-and-Forget)** when operations are **side
///   effects** that can happen eventually or fail independently without
///   breaking the core flow (e.g., Create User -> Send Email / Log Analytics).
///
/// **Characteristics:**
/// - **Stateless**: Domain services should not hold state between operations.
/// - **Pure Domain Layer**: They must NOT depend on
///   infrastructure, presentation, or application layers.
/// - **Dependencies**: They can depend on Repositories
///   (interfaces) or other Domain Services.
///
/// **Usage:**
/// ```dart
/// @injectable
/// class PaymentDomainService extends DomainService {
///   const PaymentDomainService(this._repository);
///   final IPaymentRepository _repository;
///
///   Future<Result<Unit>> transfer(Account from, Account to, Money amount) {
///     // Complex logic involving two entities
///   }
/// }
/// ```
abstract class DomainService {
  const DomainService();
}
