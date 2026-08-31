/// The four states every async screen can be in (Week 3, Session 9).
enum ViewState { idle, loading, success, empty, error }

/// Mixin giving a provider a consistent async lifecycle.
///
/// SRP: state bookkeeping lives here so each provider is left with only its
/// own domain logic.
mixin AsyncState {
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;
  bool get isEmpty => _state == ViewState.empty;

  void setState(ViewState value, {String? error}) {
    _state = value;
    _errorMessage = error;
  }
}
