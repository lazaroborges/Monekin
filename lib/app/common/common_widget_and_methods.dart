import 'dart:convert';

import 'package:flutter/material.dart';
import '../../core/presentation/app_colors.dart';
import '../../core/routes/route_utils.dart';
import '../accounts/account_form.dart';
import 'connect_to_open_finance.dart';
import 'package:http/http.dart' as http;

Widget commonCreateAccountDialog(BuildContext context) {
  if (pluggyConnectToken.isEmpty) {
    getRequest();
  }
  return AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.all(8).copyWith(left: 12, right: 12),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0).copyWith(left: 4, right: 4),
              child: const Icon(
                Icons.close,
                size: 20,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Text(
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium!,
        ),
        const SizedBox(
          height: 14,
        ),
        commonButton(
          context,
          onTap: () {
            Navigator.pop(context);
            RouteUtils.pushRoute(context, const AccountFormPage());
          },
          backgroundColor: AppColors.of(context).primaryContainer,
          child: const Center(
            child: Text(
              'Manual Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: brandBlue),
            ),
          ),
        ),
        commonButton(
          context,
          onTap: () {
            if(pluggyConnectToken.isNotEmpty){
              Navigator.pop(context);

              RouteUtils.pushRoute(context, HomePage(connectionToken: pluggyConnectToken));
            }else{
              Navigator.pop(context);
              getRequest();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Something went to wrong, please try again later'),
              ));
            }

          },
          margin: const EdgeInsets.symmetric(vertical: 8),
          backgroundColor: brandBlue,
          child: const Center(
            child: Text(
              'Connect to Open Finance',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}

String pluggyConnectToken = '';

Future getRequest() async {
  var url = Uri.parse('http://app.parsa-ai.com.br:8000/open/connect/');
  http.Response response = await http.get(url);
  try {
    if (response.statusCode == 200) {
      String data = response.body;
      var decodedData = jsonDecode(data);
      pluggyConnectToken = decodedData['connect_token'];
    } else {
      return 'failed';
    }
  } catch (e) {
    return 'failed';
  }
}

Widget commonButton(BuildContext context, {required Function() onTap, required Widget child, Color? backgroundColor, EdgeInsetsGeometry? padding, EdgeInsetsGeometry? margin}) {
  return InkWell(
    onTap: onTap,
    // RouteUtils.pushRoute(context, const AccountFormPage());
    child: Container(
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? EdgeInsets.zero,
      height: 45,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: backgroundColor ?? AppColors.of(context).primaryContainer,
      ),
      child: child,
    ),
  );
}
