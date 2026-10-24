// Platform-specific Drift connection factory.
//
// Native SQLite connections are enabled on platforms with Dart FFI. A web
// executor is intentionally not activated until the SQLite WASM + Drift
// worker assets are included and tested in the repository.
export 'database_connection_stub.dart'
    if (dart.library.ffi) 'database_connection_native.dart'
    if (dart.library.js_interop) 'database_connection_web.dart';
