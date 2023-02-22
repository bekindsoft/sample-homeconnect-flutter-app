import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_home_connect_sdk/src/auth.dart';
import '../components/login.dart' show showLogin;

class HomeConnectOauth extends HomeConnectAuth {
  final BuildContext context;

  HomeConnectOauth({
    required this.context,
  });

  @override
  Future<HomeConnectAuthCredentials> authorize(
      HomeConnectClientCredentials credentials) async {
    print("received credentials $credentials");
    final response = await showLogin(
      context: context,
      clientId: credentials.clientId,
      redirectUrl: credentials.redirectUri,
    );

    if (response == null) {
      throw Exception("Login failed");
    }
    final tokenResponse = await http.post(
      Uri.parse('https://simulator.home-connect.com/security/oauth/token'),
      body: {
        'grant_type': 'authorization_code',
        'code': response['token'],
        'client_id': credentials.clientId,
        'redirect_uri': credentials.redirectUri,
      },
    );
    final res = jsonDecode(utf8.decode(tokenResponse.bodyBytes)) as Map;
    // final accessToken = tokenResponse.body['accessToken'];
    return HomeConnectAuthCredentials(
      accessToken: res['access_token'],
      refreshToken: res['access_token'],
      //expirationDate: DateTime.now().add(const Duration(days: 1)),
    );
  }

  @override
  Future<HomeConnectAuthCredentials> refresh(String refreshToken) {
    // TODO: implement refresh
    throw UnimplementedError();
  }

  //@override
  //String getAuthUrl() {
  //return 'https://simulator.home-connect.com/security/oauth/authorize?client_id=$clientId&redirect_uri=$redirectUri&response_type=code&scope=IdentifyAppliance+Monitor+ControlCooking+ControlLaundry&state=123456789';
  //}
}
