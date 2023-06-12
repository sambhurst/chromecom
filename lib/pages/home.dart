import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:serial/serial.dart';
import 'package:chromecom/models/chromecom_model.dart';
import 'package:chromecom/models/flags.dart';
//import 'package:chromecom/widgets/widgets.dart';

import 'package:chromecom/pages/dialogs.dart';

class Home extends StatelessWidget {
	Color titleBgColor = const Color(0xff000000);
	Color titleButtonColor = const Color(0xff500050);
	Color textColor = const Color(0xffffffff);
	Color consoleBgColor = const Color(0xff400040);
	Color statusBgColor = const Color(0xff740074);
	Dialogs dialogs = new Dialogs();

	@override
	Widget build(BuildContext context) {
		final ButtonStyle style = TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onPrimary,);

		return KeyboardListener(
			autofocus: true,
			focusNode: FocusNode(),
			onKeyEvent: (event) { keyboardListenerOnKeyEvent(context, event); },
			child: Scaffold(
				appBar: AppBar(
					title: Text('ChromeCom V0.1', style: TextStyle(color: textColor)),
					backgroundColor: titleBgColor,
					flexibleSpace: Container(
						decoration: BoxDecoration(
							gradient: LinearGradient(
								begin: Alignment.centerRight,
								end: Alignment.centerLeft,
								colors: <Color>[titleButtonColor, titleBgColor]
							),
						),
					),
					actions: <Widget>[
						TextButton(
							onPressed: () { connectOnPressed(context); },
							child: Text('Connect', style: TextStyle(color: textColor)),
						),
						TextButton(
							onPressed: () { setupOnPressed(context); },
							child: Text('Setup', style: TextStyle(color: textColor)),
						),
						TextButton(
							onPressed: () { saveOnPressed(context); },
							child: Text('Save', style: TextStyle(color: textColor)),
						),
						TextButton(
							onPressed: () { clearOnPressed(context); },
							child: Text('Clear', style: TextStyle(color: textColor)),
						),
						TextButton(
							onPressed: () { aboutOnPressed(context); },
							child: Text('About', style: TextStyle(color: textColor)),
						),
					],
				),
				body: Padding(
					padding: EdgeInsets.only(bottom: 14),
					child: Consumer<ChromeComModel>(builder: consoleBuilder),
				),
				bottomSheet: Consumer<ChromeComModel>(builder: statusBuilder),
			),
		);
	}

	void keyboardListenerOnKeyEvent(BuildContext context, KeyEvent event) {
		if (event is KeyDownEvent) {
			if (event.character != null) {
				Provider.of<ChromeComModel>(context, listen: false).addKeyPress(event.character?.codeUnits[0]);
			}
			else if (event.logicalKey == LogicalKeyboardKey.enter) {
				// ASCII carriage return
				Provider.of<ChromeComModel>(context, listen: false).addKeyPress(0x0D);
				// ASCII line feed
//				Provider.of<ChromeComModel>(context, listen: false).addKeyPress(0x0A);
			}
		}
	}

	void clearOnPressed(BuildContext context) {
		Provider.of<ChromeComModel>(context, listen: false).clearData();
	}

	void aboutOnPressed(BuildContext context) {
		dialogs.displayAboutDialog(context);
	}

	void saveOnPressed(BuildContext context) {
		if (Provider.of<ChromeComModel>(context, listen: false).getSize() > 0) {
			dialogs.displaySaveDialog(context);
		} else {
			dialogs.displayInfoDialog(context);
		}
	}

	void connectOnPressed(BuildContext context) {
		Provider.of<ChromeComModel>(context, listen: false).startup();
	}

	void setupOnPressed(BuildContext context) {
		dialogs.displaySettingsDialog(context);
	}

	Widget consoleBuilder(BuildContext context, ChromeComModel model, Widget? child) {
		final List<TextSpan> data = model.getData();
		final int errors = model.getError();

		if ((errors & Flags.CONNECTION_LOST) > 0) {
			dialogs.displayConnectionLostDialog(context);
		} else if ((errors & Flags.OPEN_ERROR) > 0) {
			dialogs.displayOpenFailedDialog(context);
		}

		model.scrollConsole();
		return Container(
			width: double.infinity,
			height: double.infinity,
			color: consoleBgColor,
			child: SingleChildScrollView(
				controller: model.getScrollController(),
				child: Row(children: [Flexible(
							child: RichText(text: TextSpan(children: List.from(data)), maxLines: null)),]),
			),
		);
	}

	Widget _statusString(BuildContext context) {
		bool connected = Provider.of<ChromeComModel>(context, listen: false).isConnected();
		String status = Provider.of<ChromeComModel>(context, listen: false).getSetup();

		return Text(status, style: TextStyle(color: textColor));
//		print("status update");
//		if (connected) {
//			return Text("Status: Online ", style: TextStyle(color: textColor));
//		} else {
//			return Text("Status: Offline ", style: TextStyle(color: textColor));
//		}
	}

	Widget statusBuilder(BuildContext context, ChromeComModel model, Widget? child) {
		return Container(
			color: titleBgColor,
			width: double.infinity,
			child: Row(children: [
				_statusString(context),
			])
		);
	}
}
