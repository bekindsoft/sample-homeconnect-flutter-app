import 'package:flutter/material.dart';
import 'package:flutter_home_connect_sdk/src/auth.dart';
import '../components/login.dart' show showLogin;

class HomeConnectOauth extends HomeConnectAuth {
  final BuildContext context;

  HomeConnectOauth({
    required this.context,
  });

  @override
  Future<HomeConnectAuthCredentials> authorize(HomeConnectClientCredentials credentials) async {
    print("received credentials $credentials");
    final response = await showLogin(
      context: context,
      clientId: credentials.clientId,
      redirectUrl: credentials.redirectUri,
    );

    if (response == null) {
      throw Exception("Login failed");
    }
    return HomeConnectAuthCredentials(
      accessToken: "",
      refreshToken: "",
      //expirationDate: DateTime.now().add(const Duration(days: 1)),
    );
  }

  //@override
  //String getAuthUrl() {
    //return 'https://simulator.home-connect.com/security/oauth/authorize?client_id=$clientId&redirect_uri=$redirectUri&response_type=code&scope=IdentifyAppliance+Monitor+ControlCooking+ControlLaundry&state=123456789';
  //}
}
