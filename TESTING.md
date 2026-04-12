# Testing Guide for Next Bus Frontend

Welcome to the testing guide! If you are new to testing, this document will help you understand how testing works in this project and how you can add your own tests.

## Why Do We Test?
Testing helps us make sure our code works exactly how we expect it to. It acts as a safety net: when we add new features or change existing code, tests help us catch bugs early so they don't reach our users.

## Types of Tests
In Flutter, there are usually three types of tests:
1. **Unit Tests**: Test a single piece of logic (like a function or a single class) to make sure it works correctly on its own.
2. **Widget Tests**: Test a single widget (a piece of the UI) to make sure it looks right and interacts properly (e.g., a button changes color when tapped).
3. **Integration Tests**: Test a large part of the app or the whole app together, simulating a real user clicking around.

For now, we have a sample **Widget Test** set up in `test/widget_test.dart`.

## How to Run Tests Locally
You can run all tests in the project with a single command. Open your terminal, navigate to the root of the project, and run:

```bash
flutter test
```

If everything works, you will see an output like `All tests passed!`.

## What is Mockito?
Sometimes, your code depends on external things like a database, a network request, or an API. We don't want our tests to actually make network requests because that would be slow and unreliable (e.g., what if the internet is down?).

That's where **Mockito** comes in! Mockito is a tool that lets us create "fake" (mock) versions of those external dependencies.
We have added `mockito` and `build_runner` to the project. You can use them to generate mock classes for testing network requests or other complex services later on.

## Writing Your First Test
Take a look at `test/widget_test.dart` for a basic example:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextbus/main.dart';

void main() {
  testWidgets('AppInitializer shows loading indicator initially', (WidgetTester tester) async {
    // 1. Build our app and trigger a frame.
    await tester.pumpWidget(const AppInitializer());

    // 2. Verify that our initial state shows the loading indicator.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);
  });
}
```

1. **`testWidgets`**: Tells Flutter this is a test involving the UI.
2. **`tester.pumpWidget`**: Loads the widget we want to test.
3. **`expect`**: Checks if something is true. Here, we check if there is exactly one `CircularProgressIndicator` and exactly one text saying "Loading...".

Happy testing!
