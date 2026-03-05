import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:linkedin_clone/core/config/env.dart';
import 'package:linkedin_clone/core/services/token_storage.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class InvitationUser {
  final int id;
  final String firstName;
  final String lastName;
  final String? avatar;

  InvitationUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatar,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final List<String> n = fullName.trim().split(' ');
    return n.map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
  }

  factory InvitationUser.fromJson(Map<String, dynamic> json) {
    final av = json['avatar'] as String?;
    return InvitationUser(
      id: json['id'] ?? 0,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      avatar: (av != null && av.isNotEmpty) ? av : null,
    );
  }
}

class InvitationModel {
  final int id;
  final int fromUserId;
  final int toUserId;
  final String message;
  final String status; // pending | accepted | rejected
  final int? conversationId;
  final DateTime createdAt;
  final InvitationUser? fromUser;
  final InvitationUser? toUser;

  InvitationModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.message,
    required this.status,
    this.conversationId,
    required this.createdAt,
    this.fromUser,
    this.toUser,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'] ?? 0,
      fromUserId: json['fromUserId'] ?? 0,
      toUserId: json['toUserId'] ?? 0,
      message: json['message'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      conversationId: json['conversationId'] as int?,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      fromUser: json['fromUser'] != null ? InvitationUser.fromJson(json['fromUser']) : null,
      toUser: json['toUser'] != null ? InvitationUser.fromJson(json['toUser']) : null,
    );
  }
}

// ─── State ────────────────────────────────────────────────────────────────────

class InvitationsState {
  final List<InvitationModel> received;
  final List<InvitationModel> sent;
  final bool isLoadingReceived;
  final bool isLoadingSent;
  final String? error;

  InvitationsState({
    this.received = const [],
    this.sent = const [],
    this.isLoadingReceived = false,
    this.isLoadingSent = false,
    this.error,
  });

  InvitationsState copyWith({
    List<InvitationModel>? received,
    List<InvitationModel>? sent,
    bool? isLoadingReceived,
    bool? isLoadingSent,
    String? error,
  }) {
    return InvitationsState(
      received: received ?? this.received,
      sent: sent ?? this.sent,
      isLoadingReceived: isLoadingReceived ?? this.isLoadingReceived,
      isLoadingSent: isLoadingSent ?? this.isLoadingSent,
      error: error,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class InvitationsNotifier extends StateNotifier<InvitationsState> {
  InvitationsNotifier() : super(InvitationsState());

  Future<Map<String, String>> _headers() async {
    const s = TokenStorage();
    final String? token = await s.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> loadAll() async {
    await Future.wait([loadReceived(), loadSent()]);
  }

  Future<void> loadReceived() async {
    state = state.copyWith(isLoadingReceived: true, error: null);
    try {
      final String url = '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/invitations/received?skip=0&limit=100';
      final http.Response response = await http.get(Uri.parse(url), headers: await _headers());
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List<InvitationModel> items = (data['items'] as List? ?? [])
            .map((e) => InvitationModel.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(received: items, isLoadingReceived: false);
      } else {
        state = state.copyWith(isLoadingReceived: false, error: 'Xatolik yuz berdi');
      }
    } catch (e) {
      state = state.copyWith(isLoadingReceived: false, error: e.toString());
    }
  }

  Future<void> loadSent() async {
    state = state.copyWith(isLoadingSent: true, error: null);
    try {
      final String url = '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/invitations?received=false&sent=true&limit=100';
      final http.Response response = await http.get(Uri.parse(url), headers: await _headers());
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List<InvitationModel> items = (data['items'] as List? ?? [])
            .map((e) => InvitationModel.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(sent: items, isLoadingSent: false);
      } else {
        state = state.copyWith(isLoadingSent: false, error: 'Xatolik yuz berdi');
      }
    } catch (e) {
      state = state.copyWith(isLoadingSent: false, error: e.toString());
    }
  }

  Future<bool> accept(int invitationId) async {
    try {
      final String url = '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/invitations/$invitationId/accept';
      final http.Response response = await http.post(Uri.parse(url), headers: await _headers());
      if (response.statusCode == 200) {
        await loadReceived();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> reject(int invitationId) async {
    try {
      final String url = '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/invitations/$invitationId/reject';
      final http.Response response = await http.post(Uri.parse(url), headers: await _headers());
      if (response.statusCode == 200) {
        await loadReceived();
        return true;
      }
    } catch (_) {}
    return false;
  }
}

final invitationsProvider =
    StateNotifierProvider<InvitationsNotifier, InvitationsState>((ref) {
  return InvitationsNotifier();
});
