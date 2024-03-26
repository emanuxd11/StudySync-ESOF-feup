// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// The [Groups] class holds a list of Group items saved by the user.
class Groups extends ChangeNotifier {
  final List<int> _enteredGroups = [];

  List<int> get items => _enteredGroups;

  void add(int itemNo) {
    _enteredGroups.add(itemNo);
    notifyListeners();
  }

  void remove(int itemNo) {
    _enteredGroups.remove(itemNo);
    notifyListeners();
  }
}