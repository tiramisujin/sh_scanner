import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

import 'qr.scan.box.painter.dart';

class ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with TickerProviderStateMixin {
  bool _camState = false;
  bool _camReady = false;
  bool _camPause = false;

  AnimationController _animationController;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _scanCode();
    _initAnimation();
  }

  @override
  void dispose() {
    _clearAnimation();
    super.dispose();
  }

  void _clearAnimation() {
    _timer?.cancel();
    if (_animationController != null) {
      _animationController?.dispose();
      _animationController = null;
    }
  }

  void _qrCallback(String code) async {
    if (_camPause) return;

    _camPause = true;
    Navigator.pop(context, code);
  }

  void _scanCode() {
    _camReady = true;
    setState(() {
      _camState = true;
    });
  }

  void _upState() {
    setState(() {});
  }

  void _initAnimation() {
    setState(() {
      _animationController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 1000));
    });
    _animationController
      ..addListener(_upState)
      ..addStatusListener((state) {
        if (state == AnimationStatus.completed) {
          _timer = Timer(Duration(seconds: 1), () {
            _animationController?.reverse(from: 1.0);
          });
        } else if (state == AnimationStatus.dismissed) {
          _timer = Timer(Duration(seconds: 1), () {
            _animationController?.forward(from: 0.0);
          });
        }
      });
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return _camState
        ? Material(
            color: Colors.black,
            child: LayoutBuilder(builder: (context, constraints) {
              final qrScanSize = constraints.maxWidth * 0.85;

              return Stack(children: <Widget>[
                Center(
                  child: AspectRatio(
                    aspectRatio: size.aspectRatio,
                    child:
                        // QRBarScannerCamera(
                        QrCamera(
                      fit: BoxFit.fitWidth,
                      onError: (context, error) => Text(
                        error.toString(),
                        style: TextStyle(color: Colors.red),
                      ),
                      qrCodeCallback: (code) {
                        if (_camReady) {
                          _camReady = false;
                          _qrCallback(code);
                        }
                      },
                    ),
                  ),
                ),
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                ),
                Positioned(
                  left: (constraints.maxWidth - qrScanSize) / 2,
                  top: (constraints.maxHeight - qrScanSize) * 0.333333,
                  child: CustomPaint(
                    painter: QrScanBoxPainter(
                      boxLineColor: Colors.cyanAccent,
                      animationValue: _animationController?.value ?? 0,
                      isForward: _animationController?.status ==
                          AnimationStatus.forward,
                    ),
                    child: SizedBox(
                      width: qrScanSize,
                      height: qrScanSize,
                    ),
                  ),
                ),
                Positioned(
                  top: (constraints.maxHeight - qrScanSize) * 0.333333 +
                      qrScanSize +
                      24,
                  width: constraints.maxWidth,
                  child: Align(
                    alignment: Alignment.center,
                    child: DefaultTextStyle(
                      style: TextStyle(color: Colors.white),
                      child: Text(
                        "请将一或二维码置于方框中 \n Please place the QR code inside the frame",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ]);
            }))
        : Material(
            color: Colors.black,
            child: Container(
              color: Colors.black,
            ),
          );
  }
}
