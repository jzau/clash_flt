import 'dart:io';

import 'package:clash_flt/util/health_checker.dart';
import 'package:clash_flt/util/profile_resolver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'entity/profile.dart';
import 'entity/proxy.dart';

export 'entity/profile.dart';

class ClashFlt {
  static ClashFlt? _instance;
  static ClashFlt get instance => _instance ??= ClashFlt._();

  Directory homeDir = Directory("");

  final profileFile = ValueNotifier<File?>(null);
  final profileDownloading = ValueNotifier<bool>(false);
  final countryDBFile = ValueNotifier<File?>(null);
  final countryDBDownloading = ValueNotifier<bool>(false);
  final profile = ValueNotifier<Profile?>(null);
  final profileResolving = ValueNotifier<bool>(false);
  final healthChecking = ValueNotifier<bool>(false);

  init(Directory homeDir) {
    this.homeDir = homeDir;
  }

  ClashFlt._();

  Future<bool> downloadProfile(String url, {bool isForce = false}) async {
    final uri = Uri.parse(url);
    final fileName = url.split("/").last;
    File target = File(
      "${homeDir.path}${Platform.pathSeparator}profile${Platform.pathSeparator}$fileName",
    );
    if (await target.exists() && !isForce) {
      profileFile.value = target;
      return true;
    }
    profileDownloading.value = true;
    await target.create(recursive: true);
    final downloaded = await _download(uri, target);
    profileDownloading.value = false;
    if (downloaded) {
      profileFile.value = target;
      return true;
    }
    return false;
  }

  Future<bool> resolveProfile([File? file]) async {
    final safeFile = file ?? profileFile.value;
    profileResolving.value = true;
    profile.value = await ProfileResolver.resolveProfile(safeFile);
    profileResolving.value = false;
    return profile.value != null;
  }

  Future<File> polluteCountryDB(String assetName) async {
    countryDBDownloading.value = true;
    final data = await rootBundle.load(assetName);
    File target = File(
      "${homeDir.path}${Platform.pathSeparator}country${Platform.pathSeparator}Country.mmdb",
    );
    if (!await target.exists()) target.create(recursive: true);
    await target.writeAsBytes(data.buffer.asUint8List());
    countryDBDownloading.value = false;
    return target;
  }

  Future<File?> downloadCountryDB({
    String url =
        "https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb",
    bool isForce = false,
  }) async {
    final uri = Uri.parse(url);
    final fileName = url.split("/").last;
    File target = File(
      "${homeDir.path}${Platform.pathSeparator}country${Platform.pathSeparator}$fileName",
    );
    if (await target.exists() && !isForce) {
      return target;
    }
    countryDBDownloading.value = true;
    await target.create(recursive: true);
    final downloaded = await _download(uri, target);
    countryDBDownloading.value = false;
    if (downloaded) {
      return target;
    }
    return null;
  }

  Proxy findProxy(String name) {
    final proxyGroups = profile.value?.proxyGroups ?? [];
    try {
      final group = proxyGroups.firstWhere((element) => element.name == name);
      return Proxy(name: group.name, type: "url-test", server: "");
    } catch (_) {}
    final proxies = profile.value?.proxies ?? [];
    return proxies.firstWhere((element) => element.name == name);
  }

  Future<bool> healthCheck(Proxy proxy) async {
    healthChecking.value = true;
    await HealthChecker.healthCheck(proxy);
    healthChecking.value = false;
    return proxy.delay != null;
  }

  Future<bool> healthCheckAll() async {
    final proxies = profile.value?.proxies;
    if (proxies == null) return false;
    if (proxies.isEmpty) return true;
    healthChecking.value = true;
    await HealthChecker.healthCheckAll(proxies);
    healthChecking.value = false;
    return true;
  }
}

HttpClient _httpClient = HttpClient()
  ..connectionTimeout = const Duration(seconds: 20);
Future<bool> _download(Uri uri, File file) async {
  try {
    var request = await _httpClient.getUrl(uri);
    var response = await request.close();
    if (response.statusCode ~/ 100 == 2) {
      var bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
      return true;
    } else {
      if (kDebugMode) {
        print("[ClashFlt]Download failed status: ${response.statusCode}");
      }
      return false;
    }
  } catch (ex, stackTrace) {
    debugPrintStack(stackTrace: stackTrace);
    return false;
  }
}
