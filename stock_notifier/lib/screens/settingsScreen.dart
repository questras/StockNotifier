import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';

import 'package:stocknotifier/services/sharedPreferencesHandler.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          notificationThresholdTile(),
        ],
      ),
    );
  }

  FutureBuilder<int> notificationThresholdTile() {
    final threshold = notificationThresholdRead();
    return FutureBuilder<int>(
        future: threshold,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListTile(
              leading: Container(
                child: Text('Notification threshold'),
                width: 100,
              ),
              title: Text(snapshot.data.toString() + ' minutes'),
              trailing: FlatButton(
                child: Text('change'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NotificationThresholdForm()));
                },
              ),
            );
          }
          else
          if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          return CircularProgressIndicator();
        });
  }
}

class NotificationThresholdForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NotificationThresholdFormState();
  }
}

class _NotificationThresholdFormState extends State<NotificationThresholdForm> {
  @override
  Widget build(BuildContext context) {
    final _formKey = new GlobalKey<FormState>();

    return Scaffold(
        appBar: AppBar(
          title: Text('Change notification threshold'),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextFormField(
                  onSaved: (String value) {
                    notificationThresholdSave(int.parse(value));
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20.0),
                    border: OutlineInputBorder(),
                    labelText: 'Enter time in minutes',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (String value) {
                    if (!isInt(value)) {
                      return 'Enter a number.';
                    }
                    else
                    if (int.parse(value) < 1) {
                      return 'Enter a positive number';
                    }

                    return null;
                  },
                ),
              ),
              RaisedButton(
                child: Text('save'),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    FocusScope.of(context).unfocus();
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          ),
        ));
  }
}
