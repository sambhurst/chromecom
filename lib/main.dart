import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chromecom/pages/home.dart';
import 'package:chromecom/models/chromecom_model.dart';

void main() {
	runApp(
		MultiProvider(
			providers: [
				ChangeNotifierProvider(create: (_) => ChromeComModel()),
			],
			child: const ChromeComApp(),
		),
	);
}

class ChromeComApp extends StatelessWidget {
	const ChromeComApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			debugShowCheckedModeBanner: false,
			title: "ChromeCom",
			home: Home()
		);
	}
}
