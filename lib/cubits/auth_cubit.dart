// auth_state.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_store/services/store_service.dart';
import 'package:mobile_store/utils/shared_prefs_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import 'auth_state.dart';

// auth_cubit.dart
class AuthCubit extends Cubit<AuthState> {
  final StoreService storeService = StoreService();

  AuthCubit() : super(const AuthState()) {
    checkAuthStatus();
  }

  int? currentUserId() => state.user?.id;
  User? get currentUser => state.user;

  Future<void> checkAuthStatus() async {
    try {
      emit(state.copyWith(isLoading: true));
      final token = await SharedPrefsUtil().getToken();

      if (token != null) {
        await _fetchUserData(token);
      } else {
        emit(state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to check auth status: ${e.toString()}',
      ));
    }
  }



  Future<void> _fetchUserData(String token) async {
    try {
      final http.Response response = await storeService.fetchUserData(token);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final user = User.fromJson(userData);

        emit(state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          error: null,
        ));
      } else {
        await logout();
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to fetch user data: ${e.toString()}',
      ));
    }
  }

  Future<void> login(String username, String password) async {

    try {
      emit(state.copyWith(
        isLoading: true,
        error: null,
      ));

      final response = await storeService.login(username, password);
      if (response.statusCode == 200) {
        final token = response.body;
        await SharedPrefsUtil().saveToken(token);
        await _fetchUserData(token);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Login failed';
        emit(state.copyWith(
          isLoading: false,
          error: errorMessage,
          isAuthenticated: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Login failed: ${e.toString()}',
        isAuthenticated: false,
      ));
    }
  }

  Future<void> register(String name, String username, String password) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        error: null,
      ));

      final response = await storeService.register(name, username, password);

      if (response.statusCode == 200) {
        // Automatically login after successful registration
        await login(username, password);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Registration failed';
        emit(state.copyWith(
          isLoading: false,
          error: errorMessage,
          isAuthenticated: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Registration failed: ${e.toString()}',
        isAuthenticated: false,
      ));
    }
  }

  Future<void> logout() async {
    try {
      emit(state.copyWith(isLoading: true));

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      emit(const AuthState());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Logout failed: ${e.toString()}',
      ));
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
