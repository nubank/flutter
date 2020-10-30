// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file/file.dart';

import '../src/common.dart';
import 'test_data/hot_reload_project.dart';
import 'test_driver.dart';
import 'test_utils.dart';

void main() {
  Directory tempDir;
  final HotReloadProject project = HotReloadProject();
  FlutterRunTestDriver flutter;

  setUp(() async {
    tempDir = createResolvedTempDirectorySync('hot_reload_test.');
    await project.setUpIn(tempDir);
    flutter = FlutterRunTestDriver(tempDir);
  });

  tearDown(() async {
    await flutter?.stop();
    tryToDelete(tempDir);
  });

  testWithoutContext('hot restart works without error', () async {
    await flutter.run(chrome: true);
    await flutter.hotRestart();
  }, skip: platform.isMacOS);

  testWithoutContext('newly added code executes during hot restart', () async {
    final Completer<void> completer = Completer<void>();
    final StreamSubscription<String> subscription = flutter.stdout.listen((String line) {
      print(line);
      if (line.contains('(((((RELOAD WORKED)))))')) {
        completer.complete();
      }
    });
    await flutter.run(chrome: true);
    project.uncommentHotReloadPrint();
    try {
      await flutter.hotRestart();
      await completer.future;
    } finally {
      await subscription.cancel();
    }
  }, skip: platform.isMacOS);
}
