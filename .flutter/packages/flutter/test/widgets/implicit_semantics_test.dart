// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'semantics_tester.dart';

void main() {
  testWidgets('Implicit Semantics merge behavior', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Semantics(
          container: true,
          child: const Column(
            children: <Widget>[
              Text('Michael Valdiviezo'),
              Text('mavaldiviezo.abx@gmail.com'),
            ],
          ),
        ),
      ),
    );

    expect(
      semantics,
      hasSemantics(
        TestSemantics.root(
          children: <TestSemantics>[
            TestSemantics.rootChild(
              id: 1,
              label: 'Michael Valdiviezo\nmavaldiviezo.abx@gmail.com',
            ),
          ],
        ),
        ignoreRect: true,
        ignoreTransform: true,
      ),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          child: const Column(
            children: <Widget>[
              Text('Michael Valdiviezo'),
              Text('mavaldiviezo.abx@gmail.com'),
            ],
          ),
        ),
      ),
    );

    expect(
      semantics,
      hasSemantics(
        TestSemantics.root(
          children: <TestSemantics>[
            TestSemantics.rootChild(
              id: 1,
              children: <TestSemantics>[
                TestSemantics(
                  id: 2,
                  label: 'Michael valdiviezo',
                ),
                TestSemantics(
                  id: 3,
                  label: 'mavaldiviezo.abx@gmail.com',
                ),
              ],
            ),
          ],
        ),
        ignoreRect: true,
        ignoreTransform: true,
      ),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          child: Semantics(
            label: 'Signed in as',
            child: const Column(
              children: <Widget>[
                Text('Michael Valdiviezo'),
                Text('mavaldiviezo.abx@gmail.com'),
              ],
            ),
          ),
        ),
      ),
    );

    // SemanticsNode#0()
    //  └SemanticsNode#1()
    //    └SemanticsNode#4(label: "Signed in as\nMichael Valdiviezo\ngoderbauer@google.com", textDirection: ltr)
    expect(
      semantics,
      hasSemantics(
        TestSemantics.root(
          children: <TestSemantics>[
            TestSemantics.rootChild(
              id: 1,
              children: <TestSemantics>[
                TestSemantics(
                  id: 4,
                  label: 'Signed in as\nMichael Valdiviezo\ngoderbauer@google.com',
                ),
              ],
            ),
          ],
        ),
        ignoreRect: true,
        ignoreTransform: true,
      ),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Semantics(
          container: true,
          child: Semantics(
            label: 'Signed in as',
            child: const Column(
              children: <Widget>[
                Text('Michael Valdiviezo'),
                Text('mavaldiviezo.abx@gmail.com'),
              ],
            ),
          ),
        ),
      ),
    );

    // SemanticsNode#0()
    //  └SemanticsNode#1(label: "Signed in as\nMichael Valdiviezo\ngoderbauer@google.com", textDirection: ltr)
    expect(
      semantics,
      hasSemantics(
        TestSemantics.root(
          children: <TestSemantics>[
            TestSemantics.rootChild(
              id: 1,
              label: 'Signed in as\nMichael Valdiviezo\ngoderbauer@google.com',
            ),
          ],
        ),
        ignoreRect: true,
        ignoreTransform: true,
      ),
    );

    semantics.dispose();
  });

  testWidgets('Do not merge with conflicts', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Semantics(
          container: true,
          child: Column(
            children: <Widget>[
              Semantics(
                label: 'node 1',
                selected: true,
                child: const SizedBox(
                  width: 10.0,
                  height: 10.0,
                ),
              ),
              Semantics(
                label: 'node 2',
                selected: true,
                child: const SizedBox(
                  width: 10.0,
                  height: 10.0,
                ),
              ),
              Semantics(
                label: 'node 3',
                selected: true,
                child: const SizedBox(
                  width: 10.0,
                  height: 10.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // SemanticsNode#0()
    //  └SemanticsNode#1()
    //   ├SemanticsNode#2(selected, label: "node 1", textDirection: ltr)
    //   ├SemanticsNode#3(selected, label: "node 2", textDirection: ltr)
    //   └SemanticsNode#4(selected, label: "node 3", textDirection: ltr)
    expect(
      semantics,
      hasSemantics(
        TestSemantics.root(
          children: <TestSemantics>[
            TestSemantics.rootChild(
              id: 1,
              children: <TestSemantics>[
                TestSemantics(
                  id: 2,
                  flags: SemanticsFlag.isSelected.index,
                  label: 'node 1',
                ),
                TestSemantics(
                  id: 3,
                  flags: SemanticsFlag.isSelected.index,
                  label: 'node 2',
                ),
                TestSemantics(
                  id: 4,
                  flags: SemanticsFlag.isSelected.index,
                  label: 'node 3',
                ),
              ],
            ),
          ],
        ),
        ignoreRect: true,
        ignoreTransform: true,
      ),
    );

    semantics.dispose();
  });
}
