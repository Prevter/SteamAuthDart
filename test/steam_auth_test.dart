// ignore_for_file: avoid_print, unused_import

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:steam_auth/steam_auth.dart';

void main() async {
  // Important to call this first
  await TimeAligner.alignTimeAsync();
}
