import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/utilities/change_notifiers.dart';

class DashboardUnassigned extends StatelessWidget {
  const DashboardUnassigned({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getLang();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          Consumer<User>(
            builder: (context, user, child) {
              return ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(RouteNames.login);
                    user.uuid = null;
                  },
                  child: Icon(Icons.logout));
            },
          ),
          ElevatedButton(onPressed: () {}, child: Icon(Icons.flag)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Text('You are currently not a part of any organisation\nAsk '
                  'your supervisor to add you to an organisation'),
            ],
          ),
        ),
      ),
    );
  }
}
