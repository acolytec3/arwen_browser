import 'package:arweave/appState.dart';
import 'package:file_picker/file_picker.dart';
import 'package:libarweave/libarweave.dart' as Ar;
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Wallet extends StatefulWidget {
  final Function(int index, String url) notifyParent;

  const Wallet({Key key, @required this.notifyParent}) : super(key: key);

  @override
  WalletState createState() => WalletState();
}

class WalletState extends State<Wallet> {
  var _myWallet;
  var _balance;
  List _txHistory;
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    Ar.setPeer();
    readStorage();
  }

  void readStorage() async {
    final storage = FlutterSecureStorage();
    var _wallet = await storage.read(key: 'walletString');
    if (_wallet != null) {
      _myWallet = Ar.Wallet(_wallet);
      _balance = await _myWallet.balance();
      Provider.of<WalletData>(context, listen: false)
          .updateWallet(_wallet, _balance);
    }
  }

  void _openWallet() async {
    final _fileName = await FilePicker.getFile();
    final walletString = _fileName.readAsStringSync();

    await storage.write(key: "walletString", value: walletString);

    try {
      _myWallet = Ar.Wallet(walletString);
    } catch (__) {
      print("Invalid Wallet File");
    }

    _balance = await _myWallet.balance();

    Provider.of<WalletData>(context, listen: false)
        .updateWallet(walletString, _balance);
    setState(() {});
  }

  void _removeWallet() async {
    await storage.deleteAll();
    Provider.of<WalletData>(context, listen: false).updateWallet(null, 0);
    _balance = 0;
    _txHistory = null;
  }

  void _loadTxHistory() async {
    try {
      final txHistory = await _myWallet.transactionHistory();
      _txHistory = txHistory;
      setState(() {});
    } catch (__) {
      print("Something went wrong trying to load transaction history");
    }
  }

  Widget transactionItem(transaction) {
    print(transaction['tags']);
    var contentType;
    try {
      contentType = transaction['tags'].singleWhere(
          (tag) => tag['name'] == 'Content-Type',
          orElse: () => "No content-type specified");
    } catch (__) {
      contentType = "No content-type specified";
    }
    return ListTile(
        title: Text(transaction['id']),
        subtitle: Text("Content type: ${contentType['value']}"),
        enabled: contentType != "No content-type specified",
        onTap: () {
          widget.notifyParent(1, "https://arweave.net/${transaction['id']}");
        });
  }

  List<Widget> buildTxHistory() {
    var txnList = <Widget>[];
    for (var txn in _txHistory) {
      txnList.add(transactionItem(txn));
    }
    return txnList;
  }

  List<Widget> buildWallet() {
    List<Widget> widgetList = [];
    if (Provider.of<WalletData>(context, listen: true).walletString == null) {
      widgetList.add(Center(
          child: RaisedButton(
        onPressed: () => _openWallet(),
        child: Text("Load Wallet"),
      )));
    } else {
      widgetList.add(Center(
          child: RaisedButton(
              onPressed: () => _removeWallet(), child: Text("Remove Wallet"))));
    }

    if (_txHistory == null) {
      widgetList.add(Center(
          child: RaisedButton(
        onPressed: (_myWallet != null) ? () => _loadTxHistory() : null,
        child: Text("Load Transaction History"),
      )));
    } else {
      widgetList.add(Expanded(child: ListView(children: buildTxHistory())));
    }

    return widgetList;
  }

  @override
  Widget build(context) {
    return Column(children: buildWallet());
  }
}
