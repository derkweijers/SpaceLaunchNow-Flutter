import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacelaunchnow_flutter/colors/app_theme.dart';
import 'package:spacelaunchnow_flutter/injection/dependency_injection.dart';
import 'package:spacelaunchnow_flutter/models/launch.dart';
import 'package:spacelaunchnow_flutter/models/launch_list.dart';
import 'package:spacelaunchnow_flutter/models/launches.dart';
import 'package:spacelaunchnow_flutter/models/launches_list.dart';
import 'package:spacelaunchnow_flutter/repository/sln_repository.dart';
import 'package:spacelaunchnow_flutter/util/ads.dart';
import 'package:spacelaunchnow_flutter/views/launchdetails/launch_detail_page.dart';
import 'package:material_search/material_search.dart';
import 'package:spacelaunchnow_flutter/views/settings/app_settings.dart';
import 'package:spacelaunchnow_flutter/views/widgets/countdown.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeListPage extends StatefulWidget {
  HomeListPage(this._configuration);

  final AppConfiguration _configuration;

  @override
  _HomeListPageState createState() => new _HomeListPageState();
}

class _HomeListPageState extends State<HomeListPage> {
  List<Launch> _launches = [];
  int nextOffset = 0;
  int totalCount = 0;
  int offset = 0;
  int limit = 5;
  bool loading = false;
  String lsps;
  String locations;
  bool subscribeALL;
  bool subscribeSpaceX;
  bool subscribeRussia;
  bool subscribeWallops;
  bool subscribeNZ;
  bool subscribeJapan;
  bool subscribeFG;
  bool subscribeCAPE;
  bool subscribePLES;
  bool subscribeISRO;
  bool subscribeKSC;
  bool subscribeVAN;
  bool subscribeChina;
  bool subscribeNASA;
  bool subscribeArianespace;
  bool subscribeULA;
  bool subscribeRoscosmos;
  bool subscribeRocketLab;
  bool subscribeBlueOrigin;
  bool subscribeNorthrop;
  SLNRepository _repository = new Injector().slnRepository;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    print("Initing state of Upcoming!");

    List<Launch> launches =
        PageStorage.of(context).readState(context, identifier: 'homeLaunches');
    if (launches != null) {
      _launches = launches;
    }

    if (launches != null) {
      _launches = launches;
    } else {
      lockedLoadNext();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(HomeListPage oldWidget) {
    setState(() {
      _handleRefresh();
    });
    super.didUpdateWidget(oldWidget);
  }

  void onLoadLaunchesComplete(Launches launches, [bool reload = false]) {
    loading = false;
    print(
        "Next: " + nextOffset.toString() + " Total: " + totalCount.toString());
    if (reload) {
      _launches.clear();
    }
    setState(() {
      _launches.addAll(launches.launches);
      PageStorage.of(context)
          .writeState(context, _launches, identifier: 'homeLaunches');
    });
  }

  void onLoadContactsError([bool search]) {
    print("Error occured");
    loading = false;
    if (search == true) {
      setState(() {
        _launches.clear();
      });
      Scaffold.of(context).showSnackBar(new SnackBar(
        duration: new Duration(seconds: 10),
        content: new Text('Unable to load launches.'),
        action: new SnackBarAction(
          label: 'Refresh',
          onPressed: () {
            // Some code to undo the change!
            _handleRefresh();
          },
        ),
      ));
    }
  }

  ThemeData get appBarTheme {
    if (widget._configuration.nightMode) {
      return kIOSThemeDarkAppBar;
    } else {
      return kIOSThemeAppBar;
    }
  }

  Widget _buildLaunchTile(BuildContext context, Launch launch) {
    var formatter = new DateFormat("EEEE, MMMM d, yyyy");

    return new Padding(
      padding:
          const EdgeInsets.only(top: 0.0, bottom: 8.0, left: 8.0, right: 8.0),
      child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: FadeInImage(
                  placeholder: new AssetImage('assets/placeholder.png'),
                  image: new CachedNetworkImageProvider(_getLaunchImage(launch)),
                  fit: BoxFit.cover,
                  height: 175.0,
                  alignment: Alignment.center,
                  fadeInDuration: new Duration(milliseconds: 75),
                  fadeInCurve: Curves.easeIn,
                ),
              ),
              _buildCountDown(launch),
              Padding(
                padding: const EdgeInsets.only(
                    top: 4.0, bottom: 4.0, left: 16.0, right: 16.0),
                child: new Text(launch.name,
                    style: Theme.of(context).textTheme.headline.copyWith(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: new Text(launch.pad.location.name,
                    style: Theme.of(context).textTheme.body2),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: new Text(formatter.format(launch.net.toLocal()),
                    style: Theme.of(context).textTheme.body2),
              ),
              Container(
                padding: const EdgeInsets.only(
                    top: 4.0, bottom: 4.0, left: 16.0, right: 16.0),
                child: new Text(launch.mission.description ?? "",
                    style: Theme.of(context).textTheme.body1,
                    textAlign: TextAlign.left),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
                  child: _buildLaunchButtons(launch),
                ),
              )
            ],
          )),
    );
  }

  void _navigateToLaunchDetails(
      {Launch launch, Object avatarTag, String launchId}) {
    Ads.hideBannerAd();
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (c) {
          return new LaunchDetailPage(
            widget._configuration,
            launch: null,
            launchId: launchId,
          );
        },
      ),
    );
  }

  Widget _buildCountDown(Launch mLaunch) {
    DateTime net = mLaunch.net;
    DateTime current = new DateTime.now();
    var diff = net.difference(current);
    if (diff.inSeconds > 0) {
      return new Countdown(mLaunch);
    } else {
      return new Container(width: 0.0, height: 0.0);
    }
  }

  Widget _buildLaunchButtons(Launch launch) {
    List<Widget> eventButtons = [];

    if (launch != null) {
      eventButtons.add(new Padding(
        padding: const EdgeInsets.all(4.0),
        child: new CupertinoButton(
          child: const Text(
            'Explore',
            style: TextStyle(),
          ),
          onPressed: () {
            _navigateToLaunchDetails(launch: launch, launchId: launch.id);
          }, //
        ),
      ));
    }
    if (launch.vidURL != null) {
      eventButtons.add(new Padding(
          padding: const EdgeInsets.all(4.0),
          child: new CupertinoButton(
            child: const Text(
              'Watch',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              _openBrowser(launch.vidURL);
            }, //
          )));
    }
    return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: eventButtons
    );
  }

  _openBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    print("Upcoming build!");

    if (_launches.isEmpty && loading) {
      content = new Center(
        child: new CircularProgressIndicator(),
      );
    } else if (_launches.isEmpty) {
      content = new Center(
        child: new Text("No Launches Loaded"),
      );
    } else {
      List<Widget> widgets = new List<Widget>();
      for (var item in _launches){
          widgets.add(_buildLaunchTile(context, item));
      }
      widgets.add(new SizedBox(height: 50));


      content = new Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _handleRefresh();
              },
            )
          ],
          title: new Text(
            "Favorited Launches",
            style: Theme.of(context)
                .textTheme
                .headline
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: new Column(
            children: widgets,
          ),
        ),
      );
    }
    return content;
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  void lockedLoadNext() {
    if (loading == false) {
      loadNext();
    }
  }

  Future<Null> loadNext() async {
    loading = true;
    print("Checking Filters!");
    await checkFilters();
    print("Loading Next!");
    if (totalCount == 0 || nextOffset != null) {
      _repository
          .fetchUpcomingHome(
              limit: limit.toString(),
              offset: nextOffset.toString(),
              lsps: lsps,
              locations: locations)
          .then((launches) => onLoadLaunchesComplete(launches))
          .catchError((onError) {
        print(onError);
        onLoadContactsError();
      });
    }
  }

  Future<Null> _handleRefresh() async {
    _launches.clear();
    totalCount = 0;
    limit = 5;
    nextOffset = 0;
    loading = true;
    await checkFilters();
    Launches responseLaunches = await _repository
        .fetchUpcomingHome(
            limit: limit.toString(),
            offset: nextOffset.toString(),
            lsps: lsps,
            locations: locations)
        .catchError((onError) {
      onLoadContactsError();
    });
    onLoadLaunchesComplete(responseLaunches);
    return null;
  }

  String _buildLSPFilter() {
    var lsp_ids = List<int>();
    if (subscribeNASA) {
      lsp_ids.add(44);
    }

    if (subscribeArianespace) {
      lsp_ids.add(115);
    }

    if (subscribeSpaceX) {
      lsp_ids.add(121);
    }

    if (subscribeULA) {
      lsp_ids.add(124);
    }

    if (subscribeRoscosmos) {
      lsp_ids.add(111);
      lsp_ids.add(163);
      lsp_ids.add(63);
    }

    if (subscribeISRO) {
      lsp_ids.add(31);
    }

    if (subscribeBlueOrigin) {
      lsp_ids.add(141);
    }

    if (subscribeRocketLab) {
      lsp_ids.add(147);
    }

    if (subscribeNorthrop) {
      lsp_ids.add(257);
    }
    String lsp_string_list = "";
    var index = 0;
    for (var id in lsp_ids) {
      lsp_string_list = lsp_string_list + id.toString();
      index = index + 1;
      if (index != lsp_ids.length) {
        lsp_string_list = lsp_string_list + ",";
      }
    }
    return lsp_string_list;
  }

  String _buildLocationFilter() {
    var locationIds = List<int>();
    if (subscribeChina) {
      locationIds.add(17);
      locationIds.add(19);
      locationIds.add(8);
      locationIds.add(16);
    }

    if (subscribeISRO) {
      locationIds.add(14);
    }

    if (subscribeCAPE) {
      locationIds.add(27);
      locationIds.add(12);
    }

    if (subscribeRussia) {
      locationIds.add(15);
      locationIds.add(5);
      locationIds.add(6);
      locationIds.add(18);
    }

    if (subscribeVAN) {
      locationIds.add(11);
    }

    if (subscribeWallops) {
      locationIds.add(21);
    }

    if (subscribeNZ) {
      locationIds.add(10);
    }

    if (subscribeJapan) {
      locationIds.add(24);
      locationIds.add(26);
    }

    if (subscribeFG) {
      locationIds.add(13);
    }
    String stringList = "";
    var index = 0;
    for (var id in locationIds) {
      stringList = stringList + id.toString();
      index = index + 1;
      if (index != locationIds.length) {
        stringList = stringList + ",";
      }
    }
    return stringList;
  }

  Future<void> checkFilters() async {
    _prefs.then((SharedPreferences prefs) {
      subscribeALL = prefs.getBool("subscribeALL") ?? true;

      subscribeSpaceX = prefs.getBool("subscribeSpaceX") ?? true;
      subscribeNASA = prefs.getBool("subscribeNASA") ?? true;
      subscribeArianespace = prefs.getBool("subscribeArianespace") ?? true;
      subscribeRoscosmos = prefs.getBool("subscribeRoscosmos") ?? true;
      subscribeULA = prefs.getBool("subscribeULA") ?? true;
      subscribeRocketLab = prefs.getBool("subscribeRocketLab") ?? true;
      subscribeBlueOrigin = prefs.getBool("subscribeBlueOrigin") ?? true;
      subscribeNorthrop = prefs.getBool("subscribeNorthrop") ?? true;
      subscribeCAPE = prefs.getBool("subscribeCAPE") ?? true;
      subscribePLES = prefs.getBool("subscribePLES") ?? true;
      subscribeISRO = prefs.getBool("subscribeISRO") ?? true;

      subscribeKSC = prefs.getBool("subscribeKSC") ?? true;
      subscribeVAN = prefs.getBool("subscribeVAN") ?? true;
      subscribeChina = prefs.getBool("subscribeChina") ?? true;

      subscribeRussia = prefs.getBool("subscribeRussia") ?? true;
      subscribeWallops = prefs.getBool("subscribeWallops") ?? true;
      subscribeNZ = prefs.getBool("subscribeNZ") ?? true;
      subscribeJapan = prefs.getBool("subscribeJapan") ?? true;

      subscribeFG = prefs.getBool("subscribeFG") ?? true;
      if (!subscribeALL) {
        lsps = _buildLSPFilter();
        locations = _buildLocationFilter();
      }
    });
  }

  String _getLaunchImage(Launch launch) {
    if (launch.image != null){
      return launch.image;
    } else if (launch.infographic != null){
      return launch.infographic;
    } else if (launch.rocket.configuration.image != null && launch.rocket.configuration.image.length > 0){
      return launch.rocket.configuration.image;
    } else if (launch.launchServiceProvider.imageURL != null && launch.rocket.configuration.image.length > 0){
      return launch.launchServiceProvider.imageURL;
    } else {
      return "";
    }
  }
}
