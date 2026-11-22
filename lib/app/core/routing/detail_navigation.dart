import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

void handleDetailClose(BuildContext context, {required String fallbackRoute}) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallbackRoute);
  }
}
