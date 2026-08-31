/// Simulates network latency so loading states are visible in demos.
///
/// SRP: one job, shared by every mock repository instead of being copied.
mixin MockLatency {
  Future<void> settle([int milliseconds = 900]) =>
      Future<void>.delayed(Duration(milliseconds: milliseconds));
}
