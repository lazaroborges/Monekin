import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pluggy_connect/flutter_pluggy_connect.dart';

import 'common_widget_and_methods.dart';

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   // final String apiKey = 'YOUR_API_KEY';
//   // PluggySDK pluggySDK;
//   //
//   // List<Institution> institutions = [];
//   // String selectedInstitutionId;
//   // String connectionId;
//   // bool isLoading = false;
//   //
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   pluggySDK = PluggySDK(apiKey: apiKey);
//   //   fetchInstitutions();
//   // }
//   //
//   // Future<void> fetchInstitutions() async {
//   //   try {
//   //     setState(() {
//   //       isLoading = true;
//   //     });
//   //     // Fetch the list of institutions
//   //     institutions = await pluggySDK.getInstitutions();
//   //     setState(() {
//   //       isLoading = false;
//   //     });
//   //   } catch (e) {
//   //     print('Error fetching institutions: $e');
//   //     setState(() {
//   //       isLoading = false;
//   //     });
//   //   }
//   // }
//   //
//   // Future<void> createBankOfAmericaConnection() async {
//   //   try {
//   //     // Get Bank of America institution ID
//   //     Institution bankOfAmerica = institutions.firstWhere((institution) =>
//   //     institution?.name.toLowerCase() == 'bank of america');
//   //
//   //     selectedInstitutionId = bankOfAmerica.id;
//   //
//   //     // Hardcoded user credentials for the demo purpose
//   //     // In a real app, ask the user for credentials securely
//   //     String user = 'demo_user';
//   //     String password = 'demo_password';
//   //
//   //     // Create the connection
//   //     Connection connection = await pluggySDK.createConnection(
//   //         selectedInstitutionId, user, password);
//   //     setState(() {
//   //       connectionId = connection.id;
//   //     });
//   //
//   //     print('Connection created successfully with ID: $connectionId');
//   //   } catch (e) {
//   //     print('Error creating connection: $e');
//   //   }
//   // }
//   //
//   // Future<void> fetchBankOfAmericaData() async {
//   //   try {
//   //     // Fetch connection data (accounts, transactions, etc.)
//   //     if (connectionId != null) {
//   //       var connectionData = await pluggySDK.getConnectionData(connectionId);
//   //       print('Connection Data: ${connectionData.accounts}');
//   //     } else {
//   //       print('No connection created yet.');
//   //     }
//   //   } catch (e) {
//   //     print('Error fetching connection data: $e');
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Bank of America Data'),
//         ),
//         body: PluggyConnect(connectToken: "",),
//       ),
//     );
//   }
// }
class HomePageState extends State<HomePage> {
  bool _showPluggyConnect = false;

  void _togglePluggyConnect() {
    setState(() {
      _showPluggyConnect = !_showPluggyConnect;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PluggyConnect(
      includeSandbox: true,
      onSuccess: (data) {
        print('Success');
        print(jsonEncode(data));
      },
      onClose: () {
        print('Closed');
        _togglePluggyConnect();
      },
      onError: (error) {
        print('Error');
        print(jsonEncode(error));
      },
      onOpen: () {
        print('Opened');
      },
      onEvent: (payload) {
        print('Event');
        print(jsonEncode(payload));
      },
      connectToken: widget.connectionToken ?? pluggyConnectToken,
    );
  }
}

class HomePage extends StatefulWidget {
  final String connectionToken;
  HomePage({super.key, required this.connectionToken,});

  @override
  HomePageState createState() => HomePageState();
}
