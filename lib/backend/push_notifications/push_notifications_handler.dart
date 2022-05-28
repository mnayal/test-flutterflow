import 'dart:async';
import 'dart:convert';

import 'serialization_util.dart';
import '../backend.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../index.dart';
import '../../main.dart';

class PushNotificationsHandler extends StatefulWidget {
  const PushNotificationsHandler({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  _PushNotificationsHandlerState createState() =>
      _PushNotificationsHandlerState();
}

class _PushNotificationsHandlerState extends State<PushNotificationsHandler> {
  bool _loading = false;

  Future handleOpenedPushNotification() async {
    if (isWeb) {
      return;
    }

    final notification = await FirebaseMessaging.instance.getInitialMessage();
    if (notification != null) {
      await _handlePushNotification(notification);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handlePushNotification);
  }

  Future _handlePushNotification(RemoteMessage message) async {
    setState(() => _loading = true);
    try {
      final initialPageName = message.data['initialPageName'] as String;
      final initialParameterData = getInitialParameterData(message.data);
      final pageBuilder = pageBuilderMap[initialPageName];
      if (pageBuilder != null) {
        final page = await pageBuilder(initialParameterData);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    handleOpenedPushNotification();
  }

  @override
  Widget build(BuildContext context) => _loading
      ? Container(
          color: FlutterFlowTheme.of(context).tertiaryColor,
          child: Center(
            child: Builder(
              builder: (context) => Image.asset(
                'assets/images/Adagio_Logo_TURQUOISE.png',
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
      : widget.child;
}

final pageBuilderMap = <String, Future<Widget> Function(Map<String, dynamic>)>{
  'Launch': (data) async => LaunchWidget(),
  'login': (data) async => LoginWidget(),
  'forgotPassword': (data) async => ForgotPasswordWidget(),
  'createAccount': (data) async => CreateAccountWidget(),
  'profile': (data) async => ProfileWidget(),
  'Paywall': (data) async => PaywallWidget(),
  'Disclaimer': (data) async => DisclaimerWidget(),
  'Success': (data) async => SuccessWidget(),
  'ChooseyourChallenge': (data) async => ChooseyourChallengeWidget(),
  'Challenge': (data) async => ChallengeWidget(),
  'Tutorials': (data) async => NavBarPage(initialPage: 'Tutorials'),
  'AboutUs': (data) async => NavBarPage(initialPage: 'AboutUs'),
  'Consult': (data) async => NavBarPage(initialPage: 'Consult'),
  'BLEM': (data) async => BlemWidget(),
  'Settings': (data) async => NavBarPage(initialPage: 'Settings'),
  'changePassword': (data) async => ChangePasswordWidget(),
  'notifications': (data) async => NotificationsWidget(),
  'Termsofservice': (data) async => TermsofserviceWidget(),
};

bool hasMatchingParameters(Map<String, dynamic> data, Set<String> params) =>
    params.any((param) => getParameter(data, param) != null);

Map<String, dynamic> getInitialParameterData(Map<String, dynamic> data) {
  try {
    final parameterDataStr = data['parameterData'];
    if (parameterDataStr == null ||
        parameterDataStr is! String ||
        parameterDataStr.isEmpty) {
      return {};
    }
    return jsonDecode(parameterDataStr) as Map<String, dynamic>;
  } catch (e) {
    print('Error parsing parameter data: $e');
    return {};
  }
}
