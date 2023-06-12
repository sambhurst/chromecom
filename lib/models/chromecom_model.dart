import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:core';
import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:serial/serial.dart';

import 'settings.dart';
import 'flags.dart';

/*
BAUD_OFFSET:
	A - 300
	B - 600
	C - 1200
	D - 2400
	E - 4800
	F - 9600
	G - 14400
	H - 19200
	I - 28800
	J - 38400
	K - 57600
	L - 115200
	
DATA_OFFSET:
	A - DataBits.seven
	B - DataBits.eight

STOP_OFFSET:
	A - StopBits.one
	B - StopBits.two

FLOW_OFFSET:
	A - Parity.none
	B - Parity.even
	C - Parity.odd

MODE_OFFSET:
	A - DisplayMode.ASCII
	B - DisplayMode.HEX

ECHO_OFFSET:
	A - LocalEcho.OFF
	B - LocalEcho.ON

RXCL_OFFSET:
	A - EnterKey.NONE
	B - EnterKey.CR
	C - EnterKey.LF

TXCL_OFFSET:
	A - EnterKey.NONE
	B - EnterKey.CR
	C - EnterKey.LF
*/

class ChromeComModel extends ChangeNotifier {
	SerialPort? _port;
	ReadableStreamReader? _reader;
	bool	_connected = false;
	int _errorFlags = 0;

	final int BAUD_OFFSET = 0;
	final int DATA_OFFSET = 1;
	final int STOP_OFFSET = 2;
	final int PARITY_OFFSET = 3;
	final int FLOW_OFFSET = 4;
	final int MODE_OFFSET = 5;
	final int ECHO_OFFSET = 6;
	final int RXCL_OFFSET = 7;
	final int TXCL_OFFSET = 8;

	int _baudRate = BaudRate.B115200;
	DataBits _dataBits = DataBits.eight;
	StopBits _stopBits = StopBits.one;
	Parity _parity = Parity.none;
	FlowControl _flowControl = FlowControl.none;
	int _bufferSize = 2048;
	String? _saveFileName;

	final int TX_DATA_LEN = 40;
	int _txDataIn = 0;
	int _txDataOut = 0;
	List<int> _txData = List<int>.filled(40, 0);

	int _displayMode = DisplayMode.ASCII;
	int _localEchoFlag = LocalEcho.OFF;
	int _addRxCrLnFlag = EnterKey.NONE;
	int _addTxCrLnFlag = EnterKey.NONE;

	bool _showCursorFlag = true;

	Color transmitCharColor = Color(0xffffffff);
	Color receiveCharColor = Color(0xffffff77);

	List<TextSpan> _displayData = [];

	final ScrollController _scrollController = ScrollController();
	bool _shouldScroll = false;

	ChromeComModel() {
		_loadSettings();
	}

	String getSetup() {
		String? conn;
		String? db;
		String? sb;
		String? p;

		if (_connected) {
			conn = "Online";
		} else {
			conn = "Offline";
		}

		switch (_dataBits) {
		case DataBits.eight:
			db = "8";
			break;
		case DataBits.seven:
			db = "7";
			break;
		}

		switch (_parity) {
		case Parity.none:
			p = "N";
			break;
		case Parity.even:
			p = "E";
			break;
		case Parity.odd:
			p = "O";
			break;
		}

		switch (_stopBits) {
		case StopBits.one:
			sb = "1";
			break;
		case StopBits.two:
			sb = "2";
			break;
		}
		return "$conn $_baudRate $db$p$sb";
	}

	int getBaudRate() {
		return _baudRate;
	}

	DataBits getDataBits() {
		return _dataBits;
	}

	StopBits getStopBits() {
		return _stopBits;
	}

	Parity getParity() {
		return _parity;
	}

	FlowControl getFlowControl() {
		return _flowControl;
	}

	int getDisplayMode() {
		return _displayMode;
	}
	
	int getLocalEcho() {
		return _localEchoFlag;
	}

	int getRxCrLn() {
		return _addRxCrLnFlag;
	}

	int getTxCrLn() {
		return _addTxCrLnFlag;
	}

	void setBaudRate(int v) {
		_baudRate = v;
	}

	bool isConnected() {
		return _connected;
	}

	void setDataBits(DataBits v) {
		_dataBits = v;
	}

	void setStopBits(StopBits v) {
		_stopBits = v;
	}

	void setParity(Parity v) {
		_parity = v;
	}

	void setFlowControl(FlowControl v) {
		_flowControl = v;
	}

	void setDisplayMode(int v) {
		_displayMode = v;
	}
	
	void setLocalEcho(int v) {
		_localEchoFlag = v;
	}

	void setRxCrLn(int v) {
		_addRxCrLnFlag = v;
	}

	void setTxCrLn(int v) {
		_addTxCrLnFlag = v;
	}

	void _loadDefaultSettings() {
		_baudRate = BaudRate.B115200;
		_dataBits = DataBits.eight;
		_stopBits = StopBits.one;
		_parity = Parity.none;
		_flowControl = FlowControl.none;

		_displayMode = DisplayMode.ASCII;
		_localEchoFlag = LocalEcho.OFF;
		_addRxCrLnFlag = EnterKey.NONE;
		_addTxCrLnFlag = EnterKey.NONE;
		
		_bufferSize = 2048;
	}

	void _loadSettings() {
		if (window.localStorage.containsKey('chromeTermSettings')) {
			String? cts = window.localStorage['chromeTermSettings'];

			if (cts == null) {
				_loadDefaultSettings();
				return;
			}

			List settings = cts.split('').toList();

			_baudRate = loadToBaudRate(settings[BAUD_OFFSET]);
			_dataBits = loadToDataBits(settings[DATA_OFFSET]);
			_stopBits = loadToStopBits(settings[STOP_OFFSET]);
			_parity = loadToParity(settings[PARITY_OFFSET]);
			_flowControl = loadToFlowControl(settings[FLOW_OFFSET]);

			_displayMode = loadToDisplayMode(settings[MODE_OFFSET]);
			_localEchoFlag = loadToLocalEcho(settings[ECHO_OFFSET]);
			_addRxCrLnFlag = loadToCrLn(settings[RXCL_OFFSET]);
			_addTxCrLnFlag = loadToCrLn(settings[TXCL_OFFSET]);
		} else {
			_loadDefaultSettings();
		}
	}

	int loadToBaudRate(String c) {
		switch (c) {
			case 'A': 	return BaudRate.B300;
			case 'B': 	return BaudRate.B600;
			case 'C': 	return BaudRate.B1200;
			case 'D': 	return BaudRate.B2400;
			case 'E': 	return BaudRate.B4800;
			case 'F': 	return BaudRate.B9600;
			case 'G': 	return BaudRate.B14400;
			case 'H': 	return BaudRate.B19200;
			case 'I': 	return BaudRate.B28800;
			case 'J': 	return BaudRate.B38400;
			case 'K':	return BaudRate.B57600;
			default:	return BaudRate.B115200;
		}
	}

	DataBits loadToDataBits(String c) {
		switch (c) {
			case 'A':	return DataBits.seven;
			default:	return DataBits.eight;
		}
	}

	StopBits loadToStopBits(String c) {
		switch (c) {
			case 'A':	return StopBits.one;
			default:	return StopBits.two;
		}
	}

	Parity loadToParity(String c) {
		switch (c) {
			case 'A':	return Parity.none;
			case 'B':	return Parity.even;
			default:	return Parity.odd;
		}
	}

	FlowControl loadToFlowControl(String c) {
		switch (c) {
			case 'A':	return FlowControl.none;
			default:	return FlowControl.hardware;
		}
	}

	int loadToDisplayMode(String c) {
		switch (c) {
			case 'A':	return DisplayMode.ASCII;
			default:	return DisplayMode.HEX;
		}
	}

	int loadToLocalEcho(String c) {
		switch (c) {
			case 'A':	return LocalEcho.OFF;
			default:	return LocalEcho.ON;
		}
	}

	int loadToCrLn(String c) {
		switch (c) {
			case 'A':	return EnterKey.NONE;
			case 'B':	return EnterKey.CR;
			default:	return EnterKey.LF;
		}
	}

	String _baudRateToSave() {
		switch (_baudRate) {
			case BaudRate.B300:	return 'A';
			case BaudRate.B600:	return 'B';
			case BaudRate.B1200:	return 'C';
			case BaudRate.B2400:	return 'D';
			case BaudRate.B4800:	return 'E';
			case BaudRate.B9600:	return 'F';
			case BaudRate.B14400:	return 'G';
			case BaudRate.B19200:	return 'H';
			case BaudRate.B28800:	return 'I';
			case BaudRate.B38400:	return 'J';
			case BaudRate.B57600:	return 'K';
			default: return 'L';
		}
	}

	String _dataBitsToSave() {
		switch (_dataBits) {
			case DataBits.seven:	return 'A';
			default:		return 'B';
		}
	}

	String _stopBitsToSave() {
		switch (_stopBits) {
			case StopBits.one:	return 'A';
			default:		return 'B';
		}
	}

	String _parityToSave() {
		switch (_parity) {
			case Parity.none:	return 'A';
			case Parity.even:	return 'B';
			default:		return 'C';
		}
	}

	String _flowControlToSave() {
		switch (_flowControl) {
			case FlowControl.none:	return 'A';
			default:		return 'B';
		}
	}

	String _displayModeToSave() {
		switch (_displayMode) {
			case DisplayMode.ASCII: return 'A';
			default:		return 'B';
		}
	}

	String _localEchoToSave() {
		switch (_localEchoFlag) {
			case LocalEcho.OFF:	return 'A';
			default:		return 'B';
		}
	}

	String _rxCrLnToSave() {
		switch (_addRxCrLnFlag) {
			case EnterKey.NONE:	return 'A';
			case EnterKey.CR:	return 'B';
			default:		return 'C';
		}
	}

	String _txCrLnToSave() {
		switch (_addTxCrLnFlag) {
			case EnterKey.NONE:	return 'A';
			case EnterKey.CR:	return 'B';
			default:		return 'C';
		}
	}

	void saveSettings() {
		List <String> ss = ['', '', '', '', '', '', '', '', ''];
		
		ss[BAUD_OFFSET] = _baudRateToSave();
		ss[DATA_OFFSET] = _dataBitsToSave();
		ss[STOP_OFFSET] = _stopBitsToSave();
		ss[PARITY_OFFSET] = _parityToSave();
		ss[FLOW_OFFSET] = _flowControlToSave();
		ss[MODE_OFFSET] = _displayModeToSave();
		ss[ECHO_OFFSET] = _localEchoToSave();
		ss[RXCL_OFFSET] = _rxCrLnToSave();
		ss[TXCL_OFFSET] = _txCrLnToSave();
		
		window.localStorage['chromeTermSettings'] = ss.join("");
	}

	Future<void> updateSettings() async {
		_connected = false;
		const delay1 = Duration(milliseconds:50);
		const delay2 = Duration(milliseconds:100);

		Timer(delay1, () async {
			if (_port != null && _reader != null) {
				try {
					_reader!.releaseLock();
				} catch(e) {
					print(e);
				}
			}
		});

		Timer(delay2, () async {
			if (_port != null) {
				try {
					await _port!.close();
				} catch(e) {
					print(e);
				}
			}
			_port = null;
			await _startup();
		});
	}

	void setSaveFileName(String filename) {
		_saveFileName = filename;
	}

	ScrollController getScrollController() {
		return _scrollController;
	}

	void _showCursor() {
		if (_showCursorFlag == false) {
			return;
		}

		_displayData.add(TextSpan(text: "C",
			style: GoogleFonts.robotoMono(textStyle: TextStyle(fontSize: 20, color: Colors.white, backgroundColor: Colors.white))));
	}

	void _removeCursor() {
		if (_showCursorFlag == false) {
			return;
		}

		_displayData.removeLast();
	}

	Future<void> _writeToPort(List<int> ch) async {
		if (_port == null) {
			return;
		}

		try {
			WritableStreamDefaultWriter writer = _port!.writable.writer;

			await writer.ready;
			await writer.write(Uint8List.fromList(ch));

			await writer.ready;
			await writer.close();
		} catch (e) {
			print(e);
		}
	}

	Future<void> _readFromPort() async {
		_reader = _port!.readable.reader;

		while (_connected == true && _port != null && _port!.readable != null) {
//			final _reader = _port!.readable.reader;

			try {
				ReadableStreamDefaultReadResult result = await _reader!.read();
				_removeCursor();			 
				
				for (int i = 0; i < result.value.length; i++) {
					_displayData.add(TextSpan(text: (_displayMode == DisplayMode.HEX) ? result.value[i].toRadixString(16) : String.fromCharCode(result.value[i]),
				 		style: GoogleFonts.robotoMono(textStyle: TextStyle(fontSize: 20, color: receiveCharColor))));

					if ((_addRxCrLnFlag == EnterKey.CR) && result.value[i] == 0x0d) {
						_displayData.add(TextSpan(text: String.fromCharCode(0x0a),
							style: GoogleFonts.robotoMono(textStyle: TextStyle(fontSize: 20, color: receiveCharColor)))); 
					} else if ((_addRxCrLnFlag == EnterKey.LF) && result.value[i] == 0x0a) {
						_displayData.add(TextSpan(text: String.fromCharCode(0x0d),
							style: GoogleFonts.robotoMono(textStyle: TextStyle(fontSize: 20, color: receiveCharColor)))); 
					}
				}

				_showCursor(); // show cursor
				_shouldScroll = true;
				notifyListeners();
			} catch (e) {
				print(e);
				print("lost");
				_connected = false;
				_errorFlags |= Flags.CONNECTION_LOST;
				notifyListeners();
			}
		}
	}

	void startup() {
		_startup();
	}

	int getError() {
		int retVal = _errorFlags;

		_errorFlags = 0;
		return retVal;
	}

	Future<void> _startup() async {
		_errorFlags &= ~Flags.OPEN_ERROR;

		try {
			_port = await window.navigator.serial.requestPort();
			await _port!.open(baudRate: _baudRate,
					dataBits: _dataBits,
					stopBits: _stopBits,
					parity: _parity,
					bufferSize: _bufferSize,
					flowControl: _flowControl);
			 
			_connected = true;
			_readFromPort();
			//notifyListeners();
			clearData();
		} catch (e) {
			_errorFlags |= Flags.OPEN_ERROR;
			print(e);
			notifyListeners();	
		}
		
		final periodicTimer = Timer.periodic(
			const Duration(milliseconds: 35), (timer) {
				List<int> d = [];
				if (_connected == false) {
					timer.cancel();
				} else if (_txDataOut != _txDataIn) {
					d.add(_txData[_txDataOut]);
					_writeToPort(d);
					_txDataOut++;
					if (_txDataOut == TX_DATA_LEN) {
						_txDataOut = 0;
					}
				}
			}
		);
	}

	void _addToTxData(int byte) {
		_txData[_txDataIn] = byte;
		_txDataIn++;
		if (_txDataIn == TX_DATA_LEN) {
			_txDataIn = 0;
		}
	}

	void addKeyPress(int? byte) {
		if (_port == null || byte == null) {
			return;
		}

		// Remove cursor
		_removeCursor();

		// Local echo
		if (_localEchoFlag == LocalEcho.ON) {
			if (byte == 0x0d && (_displayMode == DisplayMode.HEX)) {
				_displayData.add(TextSpan(text: String.fromCharCode(byte),
					  style: GoogleFonts.robotoMono(textStyle: TextStyle(fontSize: 20, color: transmitCharColor)) ));
			} else {
				_displayData.add(TextSpan(text: (_displayMode == DisplayMode.HEX) ? byte.toRadixString(16) : String.fromCharCode(byte),
					  style: GoogleFonts.robotoMono(textStyle: TextStyle(fontSize: 20, color: transmitCharColor)) ));
			}
		}

		_addToTxData(byte);

		if ((_addTxCrLnFlag == EnterKey.CR) && byte == 0x0d) { // send carriage return
			// local echo line  carriage return
			if (_localEchoFlag == LocalEcho.ON) {
				_displayData.add(TextSpan(text: String.fromCharCode(0x0a),
					 style: GoogleFonts.robotoMono(textStyle: TextStyle(fontSize: 20)) )); // local echo
			}
			_addToTxData(0x0a);
		} else if ((_addTxCrLnFlag == EnterKey.LF) && byte == 0x0a) {
			// local echo line feed
			if (_localEchoFlag == LocalEcho.ON) {
				_displayData.add(TextSpan(text: String.fromCharCode(0x0a),
					 style: GoogleFonts.robotoMono(textStyle: TextStyle(fontSize: 20)) )); // local echo
			}
			_addToTxData(0x0d);
		}

		// Show cursor
		_showCursor();

		_shouldScroll = true;
		notifyListeners();
	}

	void clearData() {
		_displayData.clear();
		_showCursor();
		notifyListeners();
	}

	int getSize() {
		if (_port == null) {
			return 0;
		}

		return _displayData.length == 0 ? 0 : _displayData.length - 1;
	}

	List<TextSpan> getData() {
		return _displayData;
	}

	void scrollConsole() {
		if (_shouldScroll) {
			WidgetsBinding.instance.addPostFrameCallback(
				(_) => 	_scrollConsole());
			_shouldScroll = false;
		}
	}

	_scrollConsole() {
		_scrollController.animateTo(
			_scrollController.position.maxScrollExtent,
			duration: Duration(milliseconds: 100),
			curve: Curves.easeInOut
		);
	}

	Future<void> save() async {
		List <int> saveData = [];

		if (_saveFileName == null) {
			return;
		}

		_removeCursor();

		for (int i = 0; i < _displayData.length; i++) {
			var ch = _displayData[i];
			var cu = ch.toPlainText().codeUnits;

			for (int k = 0; k < cu.length; k++) {
				saveData.add(cu[k]);
			}
		}

		String str = utf8.decode(saveData);
		var blob = Blob(str.split(''), 'text/plain', 'native');
		var anchorElement = AnchorElement(
			href: Url.createObjectUrlFromBlob(blob).toString(),
		)..setAttribute("download", _saveFileName!)..click();

		_showCursor();
	}
}
