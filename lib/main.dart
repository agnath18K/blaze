import 'dart:io';

import 'package:blaze/dashboard_screen.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> initSystemTray() async {
  String path =
      Platform.isWindows ? 'assets/images/icon.ico' : 'assets/images/icon.ico';

  final AppWindow appWindow = AppWindow();
  final SystemTray systemTray = SystemTray();

  await systemTray.initSystemTray(
    title: "Blaze",
    iconPath: path,
  );

  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(label: 'Show', onClicked: (menuItem) => appWindow.show()),
    MenuItemLabel(label: 'Hide', onClicked: (menuItem) => appWindow.hide()),
    MenuItemLabel(
        label: 'Exit',
        onClicked: (menuItem) async {
          await windowManager.destroy();
        }),
  ]);

  await systemTray.setContextMenu(menu);

  systemTray.registerSystemTrayEventHandler((eventName) {
    debugPrint("eventName: $eventName");
    if (eventName == kSystemTrayEventClick) {
      Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
    } else if (eventName == kSystemTrayEventRightClick) {
      Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  launchAtStartup.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
    // Set packageName parameter to support MSIX.
    packageName: 'blaze',
  );

  await launchAtStartup.enable();
  await launchAtStartup.disable();
  bool isEnabled = await launchAtStartup.isEnabled();
  await initSystemTray();
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    await DesktopWindow.setWindowSize(const Size(800, 500));
    await windowManager.setMinimumSize(const Size(800, 500));
    await windowManager.show();
    await windowManager.focus();
  });

  windowManager.setPreventClose(true);
  windowManager.addListener(MyWindowListener());

  runApp(const MyApp());
}

class MyWindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    await windowManager.hide();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blaze',
      theme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(
        textTheme: GoogleFonts.quicksandTextTheme(
          Theme.of(context)
              .textTheme
              .apply(bodyColor: Colors.white, displayColor: Colors.white),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
