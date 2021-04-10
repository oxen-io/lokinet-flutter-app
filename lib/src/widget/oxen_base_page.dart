import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxen_service_node/src/utils/theme/theme_changer.dart';
import 'package:oxen_service_node/src/utils/theme/themes.dart';
import 'package:provider/provider.dart';

import 'oxen/oxen_app_bar.dart';

enum AppBarStyle { regular, withShadow }

abstract class OxenBasePage extends StatelessWidget {
  String get title => null;

  bool get isModalBackButton => false;

  Color get backgroundColor => Colors.white;

  bool get resizeToAvoidBottomPadding => true;

  AppBarStyle get appBarStyle => AppBarStyle.regular;

  void onClose(BuildContext context) => Navigator.of(context).pop();

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget leading(BuildContext context) {
    if (ModalRoute.of(context).isFirst) {
      return null;
    }

    final _backButton = Icon(Icons.arrow_back_ios_sharp, size: 25);
    final _closeButton = Icon(Icons.close_sharp, size: 25);

    return SizedBox(
      height: 37,
      width: isModalBackButton ? 37 : 20,
      child: ButtonTheme(
        minWidth: double.minPositive,
        child: FlatButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            padding: EdgeInsets.all(0),
            onPressed: () => onClose(context),
            child: isModalBackButton ? _closeButton : _backButton),
      ),
    );
  }

  Widget middle(BuildContext context) {
    return title == null
        ? null
        : Text(
            title,
            style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryTextTheme.headline6.color),
          );
  }

  Widget trailing(BuildContext context) => null;

  Widget floatingActionButton(BuildContext context) => null;

  ObstructingPreferredSizeWidget appBar(BuildContext context) {
    final _themeChanger = Provider.of<ThemeChanger>(context);
    final _isDarkTheme = _themeChanger.theme == Themes.darkTheme;

    switch (appBarStyle) {
      case AppBarStyle.regular:
        return OxenAppBar(
            context: context,
            leading: leading(context),
            middle: middle(context),
            trailing: trailing(context),
            backgroundColor: _isDarkTheme
                ? Theme.of(context).backgroundColor
                : backgroundColor);

      case AppBarStyle.withShadow:
        return OxenAppBar.withShadow(
            context: context,
            leading: leading(context),
            middle: middle(context),
            trailing: trailing(context),
            backgroundColor: _isDarkTheme
                ? Theme.of(context).backgroundColor
                : backgroundColor);

      default:
        return OxenAppBar(
            context: context,
            leading: leading(context),
            middle: middle(context),
            trailing: trailing(context),
            backgroundColor: _isDarkTheme
                ? Theme.of(context).backgroundColor
                : backgroundColor);
    }
  }

  Widget body(BuildContext context);

  Widget bottomNavigationBar(BuildContext context) => null;

  @override
  Widget build(BuildContext context) {
    final _themeChanger = Provider.of<ThemeChanger>(context);
    final _isDarkTheme = _themeChanger.theme == Themes.darkTheme;

    return Scaffold(
        key: scaffoldKey,
        backgroundColor:
            _isDarkTheme ? Theme.of(context).backgroundColor : backgroundColor,
        resizeToAvoidBottomPadding: resizeToAvoidBottomPadding,
        appBar: appBar(context),
        body: SafeArea(child: body(context)),
        floatingActionButton: floatingActionButton(context),
        bottomNavigationBar: bottomNavigationBar(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
