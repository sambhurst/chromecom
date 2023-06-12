import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:serial/serial.dart';
import 'package:chromecom/models/chromecom_model.dart';
//import 'package:chromecom/widgets/widgets.dart';

import '../models/settings.dart';

class Dialogs {
	SerialSettings _serialSettings = SerialSettings();
	Color titleBgColor = const Color(0xff500050);
	Color textColor = const Color(0xffffffff);
	Color statusBgColor = const Color(0xff740074);
	final TextEditingController _textFieldController =
		TextEditingController();

	Future<void> displayInfoDialog(BuildContext context) async {
		return showDialog(context: context, builder: (BuildContext context) {
			return AlertDialog(
				title: Text("Info"),
				content: Text("Nothing to save"),
				actions: <Widget>[
					MaterialButton(
						color: statusBgColor,
						textColor: Colors.white,
						child: const Text('OK'),
						onPressed: () {
							Navigator.pop(context);
						}
					),
				]
			);
		});
	}

	Future<void> displayOpenFailedDialog(BuildContext context) async {
		return showDialog(context: context, builder: (BuildContext context) {
			return AlertDialog(
				title: Text("Info"),
				content: Text("Can not open port. Check if it's in use."),
				actions: <Widget>[
					MaterialButton(
						color: statusBgColor,
						textColor: Colors.white,
						child: const Text('OK'),
						onPressed: () {
							Navigator.pop(context);
						}
					),
				]
			);
		});
	}

	Future<void> displayConnectionLostDialog(BuildContext context) async {
		return showDialog(context: context, builder: (BuildContext context) {
			return AlertDialog(
				title: Text("Info"),
				content: Text("Connection lost."),
				actions: <Widget>[
					MaterialButton(
						color: statusBgColor,
						textColor: Colors.white,
						child: const Text('OK'),
						onPressed: () {
							Navigator.pop(context);
						}
					),
				]
			);
		});
	}

	Future<void> displayAboutDialog(BuildContext context) async {
		return showDialog(context: context, builder: (BuildContext context) {
			return AlertDialog(
				title: Text("About"),
				content: Column(
					mainAxisSize: MainAxisSize.min,
					mainAxisAlignment: MainAxisAlignment.start,
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>[
						Text("ChromeCom"),
						Text("Version 0.1"),
						Text("Author: Sam Hurst"),
					]
				),
				actions: <Widget>[
					MaterialButton(
						color: statusBgColor,
						textColor: Colors.white,
						child: const Text('OK'),
						onPressed: () {
							Navigator.pop(context);
						}
					),
				]
			);
		});
	}

	Future<void> displaySaveDialog(BuildContext context) async {
		return showDialog(
			context: context,
			builder: (context) {
				return AlertDialog(
					title: Text('Save'),
					content: TextField(
						onChanged: (value) {
							Provider.of<ChromeComModel>(context, listen: false).setSaveFileName(value);
						},
						controller: _textFieldController,
						decoration: InputDecoration(
							hintText: "Filename"
						),
					),
					actions: <Widget>[
						MaterialButton(
							color: statusBgColor,
							textColor: Colors.white,
							child: const Text('CANCEL'),
							onPressed: () {
								Navigator.pop(context);
							}
						),
						MaterialButton(
							color: statusBgColor,
							textColor: Colors.white,
							child: Text('OK'),
							onPressed: () {
								Navigator.pop(context);
								Provider.of<ChromeComModel>(context, listen: false).save();
							},
						),
					],
				);
			}
		);
	}

	Future<void> displaySettingsDialog(BuildContext context) async {
		return showDialog(
			context: context,
			builder: (context) {
				return Dialog(
					child: DefaultTabController(
						length: 1,
						child: Scaffold(
							appBar: AppBar(
								primary: false,
								backgroundColor: titleBgColor,
								title: Text("Settings"),
							),
							body: TabBarView(
								children: [
									_serialSettings,
								],
							),
						),
					),

				);
			}
		);
	}
}

enum eBaudrate { B300, B600, B1200, B2400, B4800, B9600, B14400, B19200, B28800, B38400, B57600, B115200 }
enum eDatabits { DB7, DB8 }
enum eParity { NONE, EVEN, ODD }
enum eStopBits { SB1, SB2 }
enum eFlowcontrol { NONE, HARDWARE }

enum eDisplayMode { HEX, ASCII }
enum eLocalEcho { ON, OFF }
enum eEnterKey { NONE, CR, LF }

class SerialSettings extends StatefulWidget {
	@override
	State<SerialSettings> createState() => _SerialSettings();
}

class _SerialSettings extends State<SerialSettings> {
	eBaudrate? _baudrate = eBaudrate.B300;
	eDatabits? _databits = eDatabits.DB8;
	eParity? _parity = eParity.NONE;
	eStopBits? _stopbits = eStopBits.SB1;
	eFlowcontrol? _flowcontrol = eFlowcontrol.NONE;

	eDisplayMode? _displaymode = eDisplayMode.ASCII;
	eLocalEcho? _localEcho = eLocalEcho.OFF;
	eEnterKey? _enterKeyTransmit = eEnterKey.NONE;
	eEnterKey? _enterKeyReceive = eEnterKey.NONE;

	@override
	void initState() {
		int br = Provider.of<ChromeComModel>(this.context, listen:false).getBaudRate();
		DataBits db = Provider.of<ChromeComModel>(this.context, listen:false).getDataBits();
		StopBits sb = Provider.of<ChromeComModel>(this.context, listen:false).getStopBits();
		Parity p = Provider.of<ChromeComModel>(this.context, listen:false).getParity();
		FlowControl fc = Provider.of<ChromeComModel>(this.context, listen:false).getFlowControl();
		int dm = Provider.of<ChromeComModel>(this.context, listen:false).getDisplayMode();
		int le = Provider.of<ChromeComModel>(this.context, listen:false).getLocalEcho();
		int rx = Provider.of<ChromeComModel>(this.context, listen:false).getRxCrLn();
		int tx = Provider.of<ChromeComModel>(this.context, listen:false).getTxCrLn();

		switch (br) {
			case BaudRate.B300:	_baudrate = eBaudrate.B300; break;
			case BaudRate.B600:	_baudrate = eBaudrate.B600; break;
			case BaudRate.B1200:	_baudrate = eBaudrate.B1200; break;
			case BaudRate.B2400:	_baudrate = eBaudrate.B2400; break;
			case BaudRate.B4800:	_baudrate = eBaudrate.B4800; break;
			case BaudRate.B9600:	_baudrate = eBaudrate.B9600; break;
			case BaudRate.B14400:	_baudrate = eBaudrate.B14400; break;
			case BaudRate.B19200:	_baudrate = eBaudrate.B19200; break;
			case BaudRate.B28800:	_baudrate = eBaudrate.B28800; break;
			case BaudRate.B38400:	_baudrate = eBaudrate.B38400; break;
			case BaudRate.B57600:	_baudrate = eBaudrate.B57600; break;
			default:		_baudrate = eBaudrate.B115200; break;
		}

		switch (db) {
			case DataBits.seven:	_databits = eDatabits.DB7; break;
			default:		_databits = eDatabits.DB8; break;
		}

		switch (p) {
			case Parity.none:	_parity = eParity.NONE; break;
			case Parity.even:	_parity = eParity.EVEN; break;
			case Parity.odd:	_parity = eParity.ODD; break;
		}

		switch (sb) {
			case StopBits.one:	_stopbits = eStopBits.SB1; break;
			case StopBits.two:	_stopbits = eStopBits.SB2; break;
		}

		switch (fc) {
			case FlowControl.none:	_flowcontrol = eFlowcontrol.NONE; break;
			case FlowControl.hardware: _flowcontrol = eFlowcontrol.HARDWARE; break;
		}

		switch (dm) {
			case DisplayMode.ASCII:	_displaymode = eDisplayMode.ASCII; break;
			case DisplayMode.HEX:	_displaymode = eDisplayMode.HEX; break;
		}

		switch (le) {
			case LocalEcho.ON:	_localEcho = eLocalEcho.ON; break;
			case LocalEcho.OFF:	_localEcho = eLocalEcho.OFF; break;
		}

		switch (tx) {
			case EnterKey.NONE:	_enterKeyTransmit = eEnterKey.NONE; break;
			case EnterKey.CR:	_enterKeyTransmit = eEnterKey.CR; break;
			case EnterKey.LF:	_enterKeyTransmit = eEnterKey.LF; break;
		}

		switch (rx) {
			case EnterKey.NONE:	_enterKeyReceive = eEnterKey.NONE; break;
			case EnterKey.CR:	_enterKeyReceive = eEnterKey.CR; break;
			case EnterKey.LF:	_enterKeyReceive = eEnterKey.LF; break;
		}
	}

	@override
	Widget build(BuildContext context) {
		return	Column (
				mainAxisSize: MainAxisSize.min,
				mainAxisAlignment: MainAxisAlignment.center,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: <Widget> [
					_serialSettings(context),
					_terminalSettings(context),
					Center(
						child: _buttonRow(context),
					),
				]
			);
	}

	Widget _serialSettings(BuildContext context) {
		return Stack(
		children: <Widget>[
			Container (
				width: 600,
				height: 380,
				margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
				padding: EdgeInsets.only(top: 10),
				decoration: BoxDecoration(
					border: Border.all(
						color: Color(0xff500050),
						width: 1),
					borderRadius: BorderRadius.circular(5),
					shape: BoxShape.rectangle,
				),
				child:  Row (
					children: <Widget>[
						Column (
							children: <Widget>[
								_baudRateGroupBox(context),
							]
						),
						Column (
							children: <Widget>[
								_dataBitsGroupBox(context),
								_parityGroupBox(context),
							]
						),
						Column (
							children: <Widget>[
								_stopBitsGroupBox(context),
								_flowControlGroupBox(context),
							]
						)
					]
				),
			),
			Positioned(
				left: 50,
				top: 9,
				child: Container(
					padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
					color: const Color(0xf9f9f9f9),
					child: Text('Serial Settings'),
				),
			),
		]);
	}

	Widget _terminalSettings(BuildContext context) {
		return Stack(
		children: <Widget>[
			Container (
				width: 600,
				height: 230,
				margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
				padding: EdgeInsets.only(top: 10),
				decoration: BoxDecoration(
					border: Border.all(
						color: Color(0xff500050),
						width: 1),
					borderRadius: BorderRadius.circular(5),
					shape: BoxShape.rectangle,
				),
				child:  Row (
					children: <Widget>[
						Column (
							children: <Widget>[
								_displayModeGroupBox(context),
								_localEchoGroupBox(context),
							]
						),
						Column (
							children: <Widget>[
								_enterKeyTransmitGroupBox(context),
									]
						),
						Column (
							children: <Widget>[
								_enterKeyReceiveGroupBox(context),
							],
						)
					]
				),
			),
			Positioned(
				left: 50,
				top: 9,
				child: Container(
					padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
					color: const Color(0xf9f9f9f9),
					child: Text('Terminal Settings'),
				),
			),
		]);
	}

	Widget _baudRateGroupBox(BuildContext context) {
		const double vd = -8;

		return Stack(
		children: <Widget>[
			Container (
				width: 160,
				height: 340,
				margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
				padding: EdgeInsets.only(top: 10),
				decoration: BoxDecoration(
					border: Border.all(
						color: Color(0xff500050),
						width: 1),
					borderRadius: BorderRadius.circular(5),
					shape: BoxShape.rectangle,
				),
				child: ListView(
					children: [
						RadioListTile<eBaudrate>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('300'),
								value: eBaudrate.B300,
							groupValue: _baudrate,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eBaudrate? value) {
								setState(() {
									_baudrate = value;
								});
							}
						),
						RadioListTile<eBaudrate>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('600'),
							value: eBaudrate.B600,
							groupValue: _baudrate,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eBaudrate? value) {
								setState(() {
									_baudrate = value;
								});
							}
						),
						RadioListTile<eBaudrate>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('1200'),
							value: eBaudrate.B1200,
							groupValue: _baudrate,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eBaudrate? value) {
								setState(() {
									_baudrate = value;
								});
							}
						),
						RadioListTile<eBaudrate>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('2400'),
							value: eBaudrate.B2400,
							groupValue: _baudrate,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eBaudrate? value) {
								setState(() {
									_baudrate = value;
								});
							}
						),
						RadioListTile<eBaudrate>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('4800'),
							value: eBaudrate.B4800,
							groupValue: _baudrate,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eBaudrate? value) {
								setState(() {
									_baudrate = value;
								});
							}
						),
						RadioListTile<eBaudrate>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('9600'),
							value: eBaudrate.B9600,
							groupValue: _baudrate,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eBaudrate? value) {
								setState(() {
									_baudrate = value;
								});
							}
						),
						RadioListTile<eBaudrate>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('14400'),
							value: eBaudrate.B14400,
							groupValue: _baudrate,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eBaudrate? value) {
								setState(() {
									_baudrate = value;
								});
							}
						),
						RadioListTile<eBaudrate>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('19200'),
							value: eBaudrate.B19200,
							groupValue: _baudrate,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eBaudrate? value) {
								setState(() {
									_baudrate = value;
								});
							}
						),
						RadioListTile<eBaudrate>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('28800'),
							value: eBaudrate.B28800,
							groupValue: _baudrate,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eBaudrate? value) {
								setState(() {
									_baudrate = value;
								});
							}
						),
						RadioListTile<eBaudrate>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('38400'),
							value: eBaudrate.B38400,
							groupValue: _baudrate,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eBaudrate? value) {
								setState(() {
									_baudrate = value;
								});
							}
						),
						RadioListTile<eBaudrate>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('57600'),
							value: eBaudrate.B57600,
							groupValue: _baudrate,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eBaudrate? value) {
								setState(() {
									_baudrate = value;
								});
							}
						),
						RadioListTile<eBaudrate>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('115200'),
							value: eBaudrate.B115200,
							groupValue: _baudrate,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eBaudrate? value) {
								setState(() {
									_baudrate = value;
								});
							}
						),
					]
				),
			),
			Positioned(
				left: 50,
				top: 9,
				child: Container(
					padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
					color: const Color(0xf9f9f9f9),
					child: Text('Baud Rate'),
				),
			),
		]);
	}

	Widget _dataBitsGroupBox(BuildContext context) {
		const double vd = -8;

		return Stack(
		children: <Widget>[
			Container (
				width: 160,
				height: 120,
				margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
				padding: EdgeInsets.only(top: 10),
				decoration: BoxDecoration(
					border: Border.all(
						color: Color(0xff500050),
						width: 1),
					borderRadius: BorderRadius.circular(5),
					shape: BoxShape.rectangle,
				),
				child: ListView(
					children: [
						RadioListTile<eDatabits>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('7'),
							value: eDatabits.DB7,
							groupValue: _databits,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eDatabits? value) {
								setState(() {
									_databits = value;
								});
							}
						),
						RadioListTile<eDatabits>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('8'),
							value: eDatabits.DB8,
							groupValue: _databits,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eDatabits? value) {
								setState(() {
									_databits = value;
								});
							}
						),
					]
				),
			),
			Positioned(
				left: 50,
				top: 9,
				child: Container(
					padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
					color: const Color(0xf9f9f9f9),
					child: Text('Data Bits'),
				),
			),
		]);
	}

	Widget _parityGroupBox(BuildContext context) {
		const double vd = -8;

		return Stack(
		children: <Widget>[
			Container (
				width: 160,
				height: 100,
				margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
				padding: EdgeInsets.only(top: 10),
				decoration: BoxDecoration(
					border: Border.all(
						color: Color(0xff500050),
						width: 1),
					borderRadius: BorderRadius.circular(5),
					shape: BoxShape.rectangle,
				),
				child: ListView(
					children: [
						RadioListTile<eParity>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('None'),
							value: eParity.NONE,
							groupValue: _parity,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eParity? value) {
								setState(() {
									_parity = value;
								});
							}
						),
						RadioListTile<eParity>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('Even'),
							value: eParity.EVEN,
							groupValue: _parity,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eParity? value) {
								setState(() {
									_parity = value;
								});
							}
						),
						RadioListTile<eParity>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
								controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('Odd'),
							value: eParity.ODD,
							groupValue: _parity,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eParity? value) {
								setState(() {
									_parity = value;
								});
							}
						),
					]
				),
			),
			Positioned(
				left: 50,
				top: 9,
				child: Container(
					padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
					color: const Color(0xf9f9f9f9),
					child: Text('Parity'),
				),
			),
		]);
	}

	Widget _stopBitsGroupBox(BuildContext context) {
		const double vd = -8;

		return Stack(
		children: <Widget>[
			Container (
				width: 160,
				height: 80,
				margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
				padding: EdgeInsets.only(top: 10),
				decoration: BoxDecoration(
					border: Border.all(
						color: Color(0xff500050),
						width: 1),
					borderRadius: BorderRadius.circular(5),
					shape: BoxShape.rectangle,
				),
				child: ListView(
					children: [
						RadioListTile<eStopBits>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('1'),
							value: eStopBits.SB1,
							groupValue: _stopbits,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eStopBits? value) {
								setState(() {
									_stopbits = value;
								});
							}
						),
						RadioListTile<eStopBits>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('2'),
							value: eStopBits.SB2,
							groupValue: _stopbits,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eStopBits? value) {
								setState(() {
									_stopbits = value;
								});
							}
						),
					]
				),
			),
			Positioned(
				left: 50,
				top: 9,
				child: Container(
					padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
					color: const Color(0xf9f9f9f9),
					child: Text('Stop Bits'),
				),
			),
		]);
	}

	Widget _flowControlGroupBox(BuildContext context) {
		const double vd = -8;

		return Stack(
		children: <Widget>[
			Container (
				width: 160,
				height: 80,
				margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
				padding: EdgeInsets.only(top: 10),
				decoration: BoxDecoration(
					border: Border.all(
						color: Color(0xff500050),
						width: 1),
					borderRadius: BorderRadius.circular(5),
					shape: BoxShape.rectangle,
				),
				child: ListView(
					children: [
						RadioListTile<eFlowcontrol>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('None'),
							value: eFlowcontrol.NONE,
							groupValue: _flowcontrol,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eFlowcontrol? value) {
								setState(() {
									_flowcontrol = value;
								});
							}
						),
						RadioListTile<eFlowcontrol>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('Hardware'),
							value: eFlowcontrol.HARDWARE,
							groupValue: _flowcontrol,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eFlowcontrol? value) {
								setState(() {
									_flowcontrol = value;
								});
							}
						),
					]
				),
			),
			Positioned(
				left: 50,
				top: 9,
				child: Container(
					padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
					color: const Color(0xf9f9f9f9),
					child: Text('Flow Control'),
				),
			),
		]);
	}

	Widget _displayModeGroupBox(BuildContext context) {
		const double vd = -8;

		return Stack(
		children: <Widget>[
			Container (
				width: 160,
				height: 80,
				margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
				padding: EdgeInsets.only(top: 10),
				decoration: BoxDecoration(
					border: Border.all(
						color: Color(0xff500050),
						width: 1),
					borderRadius: BorderRadius.circular(5),
					shape: BoxShape.rectangle,
				),
				child: ListView(
					children: [
						RadioListTile<eDisplayMode>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('HEX'),
							value: eDisplayMode.HEX,
							groupValue: _displaymode,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eDisplayMode? value) {
								setState(() {
									_displaymode = value;
								});
							}
						),
						RadioListTile<eDisplayMode>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('ASCII'),
							value: eDisplayMode.ASCII,
							groupValue: _displaymode,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eDisplayMode? value) {
								setState(() {
									_displaymode = value;
								});
							}
						),

					]
				),
			),
			Positioned(
				left: 50,
				top: 9,
				child: Container(
					padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
					color: const Color(0xf9f9f9f9),
					child: Text('Display Mode'),
				),
			),
		]);
	}

	Widget _localEchoGroupBox(BuildContext context) {
		const double vd = -8;

		return Stack(
		children: <Widget>[
			Container (
				width: 160,
				height: 80,
				margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
				padding: EdgeInsets.only(top: 10),
				decoration: BoxDecoration(
					border: Border.all(
						color: Color(0xff500050),
						width: 1),
					borderRadius: BorderRadius.circular(5),
					shape: BoxShape.rectangle,
				),
				child: ListView(
					children: [
						RadioListTile<eLocalEcho>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('On'),
							value: eLocalEcho.ON,
							groupValue: _localEcho,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eLocalEcho? value) {
								setState(() {
									_localEcho = value;
								});
							}
						),
						RadioListTile<eLocalEcho>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('Off'),
							value: eLocalEcho.OFF,
							groupValue: _localEcho,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eLocalEcho? value) {
								setState(() {
									_localEcho = value;
								});
							}
						),

					]
				),
			),
			Positioned(
				left: 50,
				top: 9,
				child: Container(
					padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
					color: const Color(0xf9f9f9f9),
					child: Text('Local Echo'),
				),
			),
		]);
	}

	Widget _enterKeyTransmitGroupBox(BuildContext context) {
		const double vd = -8;

		return Stack(
		children: <Widget>[
			Container (
				width: 160,
				height: 90,
				margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
				padding: EdgeInsets.only(top: 10),
				decoration: BoxDecoration(
					border: Border.all(
						color: Color(0xff500050),
						width: 1),
					borderRadius: BorderRadius.circular(5),
					shape: BoxShape.rectangle,
				),
				child: ListView(
					children: [
						RadioListTile<eEnterKey>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('None'),
							value: eEnterKey.NONE,
							groupValue: _enterKeyTransmit,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eEnterKey? value) {
								setState(() {
									_enterKeyTransmit = value;
								});
							}
						),
						RadioListTile<eEnterKey>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('CR'),
							value: eEnterKey.CR,
							groupValue: _enterKeyTransmit,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eEnterKey? value) {
								setState(() {
									_enterKeyTransmit = value;
								});
							}
						),
						RadioListTile<eEnterKey>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('LF'),
							value: eEnterKey.LF,
							groupValue: _enterKeyTransmit,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eEnterKey? value) {
								setState(() {
									_enterKeyTransmit = value;
								});
							}
						),
					]
				),
			),
			Positioned(
				left: 50,
				top: 9,
				child: Container(
					padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
					color: const Color(0xf9f9f9f9),
					child: Text('Enter Key TX'),
				),
			),
		]);
	}

	Widget _enterKeyReceiveGroupBox(BuildContext context) {
		const double vd = -8;

		return Stack(
		children: <Widget>[
			Container (
				width: 160,
				height: 90,
				margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
				padding: EdgeInsets.only(top: 10),
				decoration: BoxDecoration(
					border: Border.all(
						color: Color(0xff500050),
						width: 1),
					borderRadius: BorderRadius.circular(5),
					shape: BoxShape.rectangle,
				),
				child: ListView(
					children: [
						RadioListTile<eEnterKey>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('NONE'),
							value: eEnterKey.NONE,
							groupValue: _enterKeyReceive,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eEnterKey? value) {
								setState(() {
									_enterKeyReceive = value;
								});
							}
						),
						RadioListTile<eEnterKey>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('CR'),
							value: eEnterKey.CR,
							groupValue: _enterKeyReceive,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eEnterKey? value) {
								setState(() {
									_enterKeyReceive = value;
								});
							}
						),
						RadioListTile<eEnterKey>(
							visualDensity: VisualDensity(horizontal: 0, vertical: vd),
							controlAffinity: ListTileControlAffinity.trailing,
							title: const Text('LF'),
							value: eEnterKey.LF,
							groupValue: _enterKeyReceive,
							activeColor: MaterialStateColor.resolveWith((state) => Color(0xff500050)),
							onChanged: (eEnterKey? value) {
								setState(() {
									_enterKeyReceive = value;
								});
							}
						),
					]
				),
			),
			Positioned(
				left: 50,
				top: 9,
				child: Container(
					padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
					color: const Color(0xf9f9f9f9),
					child: Text('Enter Key RX'),
				),
			),
		]);
	}

	Widget _buttonRow(BuildContext context) {
		return Container(
			child: Row (
				mainAxisAlignment: MainAxisAlignment.center,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: <Widget>[
					MaterialButton(
						color: Color(0xff500050),
						textColor: Colors.white,
						child: const Text('OK'),
						onPressed: () {
							_setSettings(false);
							Navigator.pop(context);
						}
					),
					SizedBox(width: 10),
					MaterialButton(
						color: Color(0xff500050),
						textColor: Colors.white,
						child: const Text('SAVE'),
						onPressed: () {
							_setSettings(true);
							Navigator.pop(context);
						}
					),
					SizedBox(width: 10),
					MaterialButton(
						color: Color(0xff500050),
						textColor: Colors.white,
						child: const Text('CANCEL'),
						onPressed: () {
							Navigator.pop(context);	
						}
					),
				]
			)
		);
	}

	Future<void> _setSettings(bool shouldSave) async {
		int br; 
		DataBits db; 
		StopBits sb; 
		Parity p; 
		FlowControl fc; 
		int dm; 
		int le; 
		int rx; 
		int tx; 

		switch (_baudrate) {
			case eBaudrate.B300:	br = BaudRate.B300; break;
			case eBaudrate.B600:	br = BaudRate.B600; break;
			case eBaudrate.B1200:	br = BaudRate.B1200; break;
			case eBaudrate.B2400:	br = BaudRate.B2400; break;
			case eBaudrate.B4800:	br = BaudRate.B4800; break;
			case eBaudrate.B9600:	br = BaudRate.B9600; break;
			case eBaudrate.B14400:	br = BaudRate.B14400; break;
			case eBaudrate.B19200:	br = BaudRate.B19200; break;
			case eBaudrate.B28800:	br = BaudRate.B28800; break;
			case eBaudrate.B38400:	br = BaudRate.B38400; break;
			case eBaudrate.B57600:	br = BaudRate.B57600; break;
			default:		br = BaudRate.B115200; break;
		}
		Provider.of<ChromeComModel>(this.context, listen:false).setBaudRate(br);

		switch (_databits) {
			case eDatabits.DB7:	db = DataBits.seven; break;
			default:		db = DataBits.eight; break;
		}
		Provider.of<ChromeComModel>(this.context, listen:false).setDataBits(db);

		switch (_parity) {
			case eParity.EVEN:	p = Parity.even; break;
			case eParity.ODD:	p = Parity.odd; break;
			default:		p = Parity.none; break;
		}
		Provider.of<ChromeComModel>(this.context, listen:false).setParity(p);

		switch (_stopbits) {
			case eStopBits.SB2:	sb = StopBits.two; break;
			default:		sb = StopBits.one; break;
		}
		Provider.of<ChromeComModel>(this.context, listen:false).setStopBits(sb);

		switch (_flowcontrol) {
			case eFlowcontrol.HARDWARE: 	fc = FlowControl.hardware; break;
			default:			fc = FlowControl.none; break;
		}
		Provider.of<ChromeComModel>(this.context, listen:false).setFlowControl(fc);

		switch (_displaymode) {
			case eDisplayMode.HEX:	dm = DisplayMode.HEX; break;
			default:		dm = DisplayMode.ASCII; break;
		}
		Provider.of<ChromeComModel>(this.context, listen:false).setDisplayMode(dm);

		switch (_localEcho) {
			case eLocalEcho.ON:	le = LocalEcho.ON; break;
			default:		le = LocalEcho.OFF; break;
		}
		Provider.of<ChromeComModel>(this.context, listen:false).setLocalEcho(le);

		switch (_enterKeyTransmit) {
			case eEnterKey.CR:	tx = EnterKey.CR; break;
			case eEnterKey.LF:	tx = EnterKey.LF; break;
			default:		tx = EnterKey.NONE; break;
		}
		Provider.of<ChromeComModel>(this.context, listen:false).setTxCrLn(tx);

		switch (_enterKeyReceive) {
			case eEnterKey.CR:	rx = EnterKey.CR; break;
			case eEnterKey.LF:	rx = EnterKey.LF; break;
			default:		rx = EnterKey.NONE; break;
		}
		Provider.of<ChromeComModel>(this.context, listen:false).setRxCrLn(rx);

		if (shouldSave) {
			Provider.of<ChromeComModel>(this.context, listen:false).saveSettings();
		}
		await Provider.of<ChromeComModel>(this.context, listen:false).updateSettings();
	}
}
