// // lib/utils/http_client.dart
//
// import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // 실제 HTTP 구현은 _http 라는 별칭으로 불러옵니다
// import 'package:http/http.dart' as http;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fineplay/presentation/viewmodel/token_provider.dart';
//
// typedef Request = _http.Request;
// typedef Response = _http.Response;
// typedef StreamedResponse = _http.StreamedResponse;
//
// class _RefreshClient extends _http.BaseClient {
//   final _http.Client _inner;
//   final ProviderContainer _container;
//   final FlutterSecureStorage _storage;
//
//   _RefreshClient(this._inner, this._container, this._storage);
//
//   @override
//   Future<_http.StreamedResponse> send(_http.BaseRequest req) async {
//     final at = _container.read(tokenProvider);
//     req.headers['Authorization'] = 'Bearer $at';
//     final resp = await _inner.send(req);
//     if (resp.statusCode == 401 && !req.url.path.contains('http://localhost:8080/api/auth/refresh')) {
//       final ok = await _tryRefresh();
//       if (ok) {
//         req.headers['Authorization'] = 'Bearer ${_container.read(tokenProvider)}';
//         return _inner.send(req);
//       }
//     }
//     return resp;
//   }
//
//   Future<bool> _tryRefresh() async {
//     final rt = await _storage.read(key: 'refreshToken');
//     if (rt == null) return false;
//     final r = await _inner.post(
//       Uri.parse('http://localhost:8080/api/auth/refresh'),
//       headers: {'Cookie': 'refreshToken=$rt'},
//     );
//     if (r.statusCode == 200) {
//       final newAt = json.decode(r.body)['accessToken'] as String;
//       _container.read(tokenProvider.notifier).state = newAt;
//       return true;
//     }
//     return false;
//   }
// }
//
// class ApiHttp {
//   static late _http.Client _client;
//
//   static void init(ProviderContainer container) {
//     final storage = FlutterSecureStorage();
//     _client = _RefreshClient(_http.Client(),container, storage);
//   }
//
//   // 기존 get/post
//   static Future<_http.Response> get(Uri uri, {Map<String, String>? headers}) =>
//       _client.get(uri, headers: headers);
//   static Future<_http.Response> post(
//       Uri uri, {
//         Map<String, String>? headers,
//         Object? body,
//         Encoding? encoding,
//       }) =>
//       _client.post(uri, headers: headers, body: body, encoding: encoding);
//
//   // ★ 여기에 patch, put, delete 등도 추가 ★
//   static Future<_http.Response> patch(
//       Uri uri, {
//         Map<String, String>? headers,
//         Object? body,
//         Encoding? encoding,
//       }) =>
//       _client.patch(uri, headers: headers, body: body, encoding: encoding);
//
//   static Future<_http.Response> put(
//       Uri uri, {
//         Map<String, String>? headers,
//         Object? body,
//         Encoding? encoding,
//       }) =>
//       _client.put(uri, headers: headers, body: body, encoding: encoding);
//
//   static Future<_http.Response> delete(
//       Uri uri, {
//         Map<String, String>? headers,
//         Object? body,
//         Encoding? encoding,
//       }) async {
//     // 1) Request 객체 생성
//     final req = _http.Request('DELETE', uri);
//
//     // 2) 헤더 추가
//     if (headers != null) req.headers.addAll(headers);
//
//     // 3) body 추가 (JSON 인코딩 가정)
//     if (body != null) {
//       req.headers['Content-Type'] ??= 'application/json';
//       req.body = body is String ? body : json.encode(body);
//     }
//
//     // 4) send 후 Response로 변환
//     final streamed = await _client.send(req);
//     return _http.Response.fromStream(streamed);
//   }
//
// }
//
// // ———————————————————————————————————————
// // 최상단 래퍼 함수들 (import '.../http_client.dart' as http; 시 그대로 동작)
// Future<_http.Response> get(Uri uri, {Map<String, String>? headers}) =>
//     ApiHttp.get(uri, headers: headers);
//
// Future<_http.Response> post(
//     Uri uri, {
//       Map<String, String>? headers,
//       Object? body,
//       Encoding? encoding,
//     }) =>
//     ApiHttp.post(uri, headers: headers, body: body, encoding: encoding);
//
// // ★ patch·put·delete 래퍼도 추가 ★
// Future<_http.Response> patch(
//     Uri uri, {
//       Map<String, String>? headers,
//       Object? body,
//       Encoding? encoding,
//     }) =>
//     ApiHttp.patch(uri, headers: headers, body: body, encoding: encoding);
//
// Future<_http.Response> put(
//     Uri uri, {
//       Map<String, String>? headers,
//       Object? body,
//       Encoding? encoding,
//     }) =>
//     ApiHttp.put(uri, headers: headers, body: body, encoding: encoding);
//
// Future<_http.Response> delete(
//     Uri uri, {
//       Map<String, String>? headers,
//       Object? body,
//       Encoding? encoding,
//     }) =>
//     ApiHttp.delete(uri,
//         headers: headers, body: body, encoding: encoding);
//
