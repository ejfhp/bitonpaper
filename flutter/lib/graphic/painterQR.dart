/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:qr/qr.dart';

const _finderPatternLimit = 7;

// default color for the qr code pixels
const Color _qrDefaultColor = null;

/// A [CustomPainter] object that you can use to paint a QR code.
class QrPainter extends CustomPainter {
  /// Create a new QRPainter with passed options (or defaults).
  QrPainter({
    @required String data,
    @required this.version,
    this.errorCorrectionLevel = QrErrorCorrectLevel.L,
    this.color = _qrDefaultColor,
    this.emptyColor,
    this.gapless = false,
    this.embeddedImage,
    this.embeddedImageStyle,
    this.eyeStyle = const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: Color(0xFF000000),
    ),
    this.dataModuleStyle = const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: Color(0xFF000000),
    ),
  }) : assert(QrVersions.isSupportedVersion(version)) {
    _init(data);
  }

  /// Create a new QrPainter with a pre-validated/created [QrCode] object. This
  /// constructor is useful when you have a custom validation / error handling
  /// flow or for when you need to pre-validate the QR data.
  QrPainter.withQr({
    QrCode qr,
    this.color = _qrDefaultColor,
    this.emptyColor,
    this.gapless = false,
    this.embeddedImage,
    this.embeddedImageStyle,
    this.eyeStyle = const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: Color(0xFF000000),
    ),
    this.dataModuleStyle = const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: Color(0xFF000000),
    ),
  })  : _qr = qr,
        version = qr.typeNumber,
        errorCorrectionLevel = qr.errorCorrectLevel {
    _calcVersion = version;
    _initPaints();
  }

  /// The QR code version.
  final int version; // the qr code version

  /// The error correction level of the QR code.
  final int errorCorrectionLevel; // the qr code error correction level

  /// The color of the squares.
  @Deprecated('use colors in eyeStyle and dataModuleStyle instead')
  final Color color; // the color of the dark squares

  /// The color of the non-squares (background).
  @Deprecated('You should us the background color value of your container widget')
  final Color emptyColor; // the other color
  /// If set to false, the painter will leave a 1px gap between each of the
  /// squares.
  final bool gapless;

  /// The image data to embed (as an overlay) in the QR code. The image will
  /// be added to the center of the QR code.
  final ui.Image embeddedImage;

  /// Styling options for the image overlay.
  final QrEmbeddedImageStyle embeddedImageStyle;

  /// Styling option for QR Eye ball and frame.
  final QrEyeStyle eyeStyle;

  /// Styling option for QR data module.
  final QrDataModuleStyle dataModuleStyle;

  /// The base QR code data
  QrCode _qr;

  /// This is the version (after calculating) that we will use if the user has
  /// requested the 'auto' version.
  int _calcVersion;

  /// Cache for all of the [Paint] objects.
  final _paintCache = PaintCache();

  /// The size of the 'gap' between the pixels
  final double _gapSize = 0.25;

  void _init(String data) {
    if (!QrVersions.isSupportedVersion(version)) {
      throw Exception("Unsupported version: " + version.toString());
    }
    // configure and make the QR code data
    final validationResult = QrValidator.validate(
      data: data,
      version: version,
      errorCorrectionLevel: errorCorrectionLevel,
    );
    if (!validationResult.isValid) {
      throw validationResult.error;
    }
    _qr = validationResult.qrCode;
    _calcVersion = _qr.typeNumber;
    _initPaints();
  }

  void _initPaints() {
    // Cache the pixel paint object. For now there is only one but we might
    // expand it to multiple later (e.g.: different colours).
    _paintCache.cache(Paint()..style = PaintingStyle.fill, QrCodeElement.codePixel);
    // Cache the empty pixel paint object. Empty color is deprecated and will go
    // away.
    _paintCache.cache(Paint()..style = PaintingStyle.fill, QrCodeElement.codePixelEmpty);
    // Cache the finder pattern painters. We'll keep one for each one in case
    // we want to provide customization options later.
    for (final position in FinderPatternPosition.values) {
      _paintCache.cache(Paint()..style = PaintingStyle.stroke, QrCodeElement.finderPatternOuter, position: position);
      _paintCache.cache(Paint()..style = PaintingStyle.stroke, QrCodeElement.finderPatternInner, position: position);
      _paintCache.cache(Paint()..style = PaintingStyle.fill, QrCodeElement.finderPatternDot, position: position);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // if the widget has a zero size side then we cannot continue painting.
    if (size.shortestSide == 0) {
      print("[QR] WARN: width or height is zero. You should set a 'size' value "
          "or nest this painter in a Widget that defines a non-zero size");
      return;
    }

    final paintMetrics = _PaintMetrics(
      containerSize: size.shortestSide,
      moduleCount: _qr.moduleCount,
      gapSize: (gapless ? 0 : _gapSize),
    );

    // draw the finder pattern elements
    _drawFinderPatternItem(FinderPatternPosition.topLeft, canvas, paintMetrics);
    _drawFinderPatternItem(FinderPatternPosition.bottomLeft, canvas, paintMetrics);
    _drawFinderPatternItem(FinderPatternPosition.topRight, canvas, paintMetrics);

    // DEBUG: draw the inner content boundary
//    final paint = Paint()..style = ui.PaintingStyle.stroke;
//    paint.strokeWidth = 1;
//    paint.color = const Color(0x55222222);
//    canvas.drawRect(
//        Rect.fromLTWH(paintMetrics.inset, paintMetrics.inset,
//            paintMetrics.innerContentSize, paintMetrics.innerContentSize),
//        paint);

    double left;
    double top;
    final gap = !gapless ? _gapSize : 0;
    // get the painters for the pixel information
    final pixelPaint = _paintCache.firstPaint(QrCodeElement.codePixel);
    if (color != null) {
      pixelPaint.color = color;
    } else {
      pixelPaint.color = dataModuleStyle.color;
    }
    Paint emptyPixelPaint;
    if (emptyColor != null) {
      emptyPixelPaint = _paintCache.firstPaint(QrCodeElement.codePixelEmpty);
      emptyPixelPaint.color = emptyColor;
    }
    for (var x = 0; x < _qr.moduleCount; x++) {
      for (var y = 0; y < _qr.moduleCount; y++) {
        // draw the finder patterns independently
        if (_isFinderPatternPosition(x, y)) continue;
        final paint = _qr.isDark(y, x) ? pixelPaint : emptyPixelPaint;
        if (paint == null) continue;
        // paint a pixel
        left = paintMetrics.inset + (x * (paintMetrics.pixelSize + gap));
        top = paintMetrics.inset + (y * (paintMetrics.pixelSize + gap));
        var pixelHTweak = 0.0;
        var pixelVTweak = 0.0;
        if (gapless && _hasAdjacentHorizontalPixel(x, y, _qr.moduleCount)) {
          pixelHTweak = 0.5;
        }
        if (gapless && _hasAdjacentVerticalPixel(x, y, _qr.moduleCount)) {
          pixelVTweak = 0.5;
        }
        final squareRect = Rect.fromLTWH(
          left,
          top,
          paintMetrics.pixelSize + pixelHTweak,
          paintMetrics.pixelSize + pixelVTweak,
        );
        if (dataModuleStyle.dataModuleShape == QrDataModuleShape.square) {
          canvas.drawRect(squareRect, paint);
        } else {
          final roundedRect = RRect.fromRectAndRadius(squareRect, Radius.circular(paintMetrics.pixelSize + pixelHTweak));
          canvas.drawRRect(roundedRect, paint);
        }
      }
    }

    if (embeddedImage != null) {
      final originalSize = Size(
        embeddedImage.width.toDouble(),
        embeddedImage.height.toDouble(),
      );
      final requestedSize = embeddedImageStyle != null ? embeddedImageStyle.size : null;
      final imageSize = _scaledAspectSize(size, originalSize, requestedSize);
      final position = Offset(
        (size.width - imageSize.width) / 2.0,
        (size.height - imageSize.height) / 2.0,
      );
      // draw the image overlay.
      _drawImageOverlay(canvas, position, imageSize, embeddedImageStyle);
    }
  }

  bool _hasAdjacentVerticalPixel(int x, int y, int moduleCount) {
    if (y + 1 >= moduleCount) return false;
    return _qr.isDark(y + 1, x);
  }

  bool _hasAdjacentHorizontalPixel(int x, int y, int moduleCount) {
    if (x + 1 >= moduleCount) return false;
    return _qr.isDark(y, x + 1);
  }

  bool _isFinderPatternPosition(int x, int y) {
    final isTopLeft = (y < _finderPatternLimit && x < _finderPatternLimit);
    final isBottomLeft = (y < _finderPatternLimit && (x >= _qr.moduleCount - _finderPatternLimit));
    final isTopRight = (y >= _qr.moduleCount - _finderPatternLimit && (x < _finderPatternLimit));
    return isTopLeft || isBottomLeft || isTopRight;
  }

  void _drawFinderPatternItem(
    FinderPatternPosition position,
    Canvas canvas,
    _PaintMetrics metrics,
  ) {
    final totalGap = (_finderPatternLimit - 1) * metrics.gapSize;
    final radius = ((_finderPatternLimit * metrics.pixelSize) + totalGap) - metrics.pixelSize;
    final strokeAdjust = (metrics.pixelSize / 2.0);
    final edgePos = (metrics.inset + metrics.innerContentSize) - (radius + strokeAdjust);

    Offset offset;
    if (position == FinderPatternPosition.topLeft) {
      offset = Offset(metrics.inset + strokeAdjust, metrics.inset + strokeAdjust);
    } else if (position == FinderPatternPosition.bottomLeft) {
      offset = Offset(metrics.inset + strokeAdjust, edgePos);
    } else {
      offset = Offset(edgePos, metrics.inset + strokeAdjust);
    }

    // configure the paints
    final outerPaint = _paintCache.firstPaint(QrCodeElement.finderPatternOuter, position: position);
    outerPaint.strokeWidth = metrics.pixelSize;
    if (color != null) {
      outerPaint.color = color;
    } else {
      outerPaint.color = eyeStyle.color;
    }

    final innerPaint = _paintCache.firstPaint(QrCodeElement.finderPatternInner, position: position);
    innerPaint.strokeWidth = metrics.pixelSize;
    innerPaint.color = emptyColor ?? Color(0x00ffffff);

    final dotPaint = _paintCache.firstPaint(QrCodeElement.finderPatternDot, position: position);
    if (color != null) {
      dotPaint.color = color;
    } else {
      dotPaint.color = eyeStyle.color;
    }

    final outerRect = Rect.fromLTWH(offset.dx, offset.dy, radius, radius);

    final innerRadius = radius - (2 * metrics.pixelSize);
    final innerRect = Rect.fromLTWH(offset.dx + metrics.pixelSize, offset.dy + metrics.pixelSize, innerRadius, innerRadius);

    final gap = metrics.pixelSize * 2;
    final dotSize = radius - gap - (2 * strokeAdjust);
    final dotRect = Rect.fromLTWH(offset.dx + metrics.pixelSize + strokeAdjust, offset.dy + metrics.pixelSize + strokeAdjust, dotSize, dotSize);

    if (eyeStyle.eyeShape == QrEyeShape.square) {
      canvas.drawRect(outerRect, outerPaint);
      canvas.drawRect(innerRect, innerPaint);
      canvas.drawRect(dotRect, dotPaint);
    } else {
      final roundedOuterStrokeRect = RRect.fromRectAndRadius(outerRect, Radius.circular(radius));
      canvas.drawRRect(roundedOuterStrokeRect, outerPaint);

      final roundedInnerStrokeRect = RRect.fromRectAndRadius(outerRect, Radius.circular(innerRadius));
      canvas.drawRRect(roundedInnerStrokeRect, innerPaint);

      final roundedDotStrokeRect = RRect.fromRectAndRadius(dotRect, Radius.circular(dotSize));
      canvas.drawRRect(roundedDotStrokeRect, dotPaint);
    }
  }

  bool _hasOneNonZeroSide(Size size) => size.longestSide > 0;

  Size _scaledAspectSize(Size widgetSize, Size originalSize, Size requestedSize) {
    if (requestedSize != null && !requestedSize.isEmpty) {
      return requestedSize;
    } else if (requestedSize != null && _hasOneNonZeroSide(requestedSize)) {
      final maxSide = requestedSize.longestSide;
      final ratio = maxSide / originalSize.longestSide;
      return Size(ratio * originalSize.width, ratio * originalSize.height);
    } else {
      final maxSide = 0.25 * widgetSize.shortestSide;
      final ratio = maxSide / originalSize.longestSide;
      return Size(ratio * originalSize.width, ratio * originalSize.height);
    }
  }

  void _drawImageOverlay(Canvas canvas, Offset position, Size size, QrEmbeddedImageStyle style) {
    final paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
    if (style != null) {
      if (style.color != null) {
        paint.colorFilter = ColorFilter.mode(style.color, BlendMode.srcATop);
      }
    }
    final srcSize = Size(embeddedImage.width.toDouble(), embeddedImage.height.toDouble());
    final src = Alignment.center.inscribe(srcSize, Offset.zero & srcSize);
    final dst = Alignment.center.inscribe(size, position & size);
    canvas.drawImageRect(embeddedImage, src, dst, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldPainter) {
    if (oldPainter is QrPainter) {
      return errorCorrectionLevel != oldPainter.errorCorrectionLevel ||
          _calcVersion != oldPainter._calcVersion ||
          _qr != oldPainter._qr ||
          gapless != oldPainter.gapless ||
          embeddedImage != oldPainter.embeddedImage ||
          embeddedImageStyle != oldPainter.embeddedImageStyle ||
          eyeStyle != oldPainter.eyeStyle ||
          dataModuleStyle != oldPainter.dataModuleStyle;
    }
    return true;
  }

  /// Returns a [ui.Picture] object containing the QR code data.
  ui.Picture toPicture(double size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    paint(canvas, Size(size, size));
    return recorder.endRecording();
  }

  /// Returns the raw QR code [ui.Image] object.
  Future<ui.Image> toImage(double size, {ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    return await toPicture(size).toImage(size.toInt(), size.toInt());
  }

  /// Returns the raw QR code image byte data.
  Future<ByteData> toImageData(double size, {ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    final image = await toImage(size, format: format);
    return image.toByteData(format: format);
  }
}

class _PaintMetrics {
  _PaintMetrics({@required this.containerSize, @required this.gapSize, @required this.moduleCount}) {
    _calculateMetrics();
  }

  final int moduleCount;
  final double containerSize;
  final double gapSize;

  double _pixelSize;
  double get pixelSize => _pixelSize;

  double _innerContentSize;
  double get innerContentSize => _innerContentSize;

  double _inset;
  double get inset => _inset;

  void _calculateMetrics() {
    final gapTotal = (moduleCount - 1) * gapSize;
    var pixelSize = (containerSize - gapTotal) / moduleCount;
    _pixelSize = (pixelSize * 2).roundToDouble() / 2;
    _innerContentSize = (_pixelSize * moduleCount) + gapTotal;
    _inset = (containerSize - _innerContentSize) / 2;
  }
}

class QrVersions {
  /// Automatically determine the QR code version based on input and an
  /// error correction level.
  static const int auto = -1;

  /// The minimum supported version code.
  static const int min = 1;

  /// The maximum supported version code.
  static const int max = 40;

  /// Checks to see if the supplied version is a valid QR code version
  static bool isSupportedVersion(int version) => version == auto || (version >= min && version <= max);
}

/// Represents a specific element / part of a QR code. This is used to isolate
/// the different parts so that we can style and modify specific parts
/// independently.
enum QrCodeElement {
  /// The 'stroke' / outer square of the QR code finder pattern element.
  finderPatternOuter,

  /// The inner/in-between square of the QR code finder pattern element.
  finderPatternInner,

  /// The "dot" square of the QR code finder pattern element.
  finderPatternDot,

  /// The individual pixels of the QR code
  codePixel,

  /// The "empty" pixels of the QR code
  codePixelEmpty,
}

/// Enumeration representing the three finder pattern (square 'eye') locations.
enum FinderPatternPosition {
  /// The top left position.
  topLeft,

  /// The top right position.
  topRight,

  /// The bottom left position.
  bottomLeft,
}

/// Enumeration representing the finder pattern eye's shape.
enum QrEyeShape {
  /// Use square eye frame.
  square,

  /// Use circular eye frame.
  circle,
}

/// Enumeration representing the shape of Data modules inside QR.
enum QrDataModuleShape {
  /// Use square dots.
  square,

  /// Use circular dots.
  circle,
}

/// Styling options for finder pattern eye.
class QrEyeStyle {
  /// Create a new set of styling options for QR Eye.
  const QrEyeStyle({this.eyeShape, this.color});

  /// Eye shape.
  final QrEyeShape eyeShape;

  /// Color to tint the eye.
  final Color color;

  @override
  int get hashCode => eyeShape.hashCode ^ color.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is QrEyeStyle) {
      return eyeShape == other.eyeShape && color == other.color;
    }
    return false;
  }
}

/// Styling options for data module.
class QrDataModuleStyle {
  /// Create a new set of styling options for data modules.
  const QrDataModuleStyle({
    this.dataModuleShape,
    this.color,
  });

  /// Eye shape.
  final QrDataModuleShape dataModuleShape;

  /// Color to tint the data modules.
  final Color color;

  @override
  int get hashCode => dataModuleShape.hashCode ^ color.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is QrDataModuleStyle) {
      return dataModuleShape == other.dataModuleShape && color == other.color;
    }
    return false;
  }
}

/// Styling options for any embedded image overlay
class QrEmbeddedImageStyle {
  /// Create a new set of styling options.
  QrEmbeddedImageStyle({
    this.size,
    this.color,
  });

  /// The size of the image. If one dimension is zero then the other dimension
  /// will be used to scale the zero dimension based on the original image
  /// size.
  Size size;

  /// Color to tint the image.
  Color color;

  /// Check to see if the style object has a non-null, non-zero size.
  bool get hasDefinedSize => size != null && size.longestSide > 0;

  @override
  int get hashCode => size.hashCode ^ color.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is QrEmbeddedImageStyle) {
      return size == other.size && color == other.color;
    }
    return false;
  }
}

/// A utility class for validating and pre-rendering QR code data.
class QrValidator {
  /// Attempt to parse / generate the QR code data and check for any errors. The
  /// resulting [QrValidationResult] object will hold the status of the QR code
  /// as well as the generated QR code data.
  static QrValidationResult validate({
    @required String data,
    int version = QrVersions.auto,
    int errorCorrectionLevel = QrErrorCorrectLevel.L,
  }) {
    QrCode qrCode;
    try {
      if (version != QrVersions.auto) {
        qrCode = QrCode(version, errorCorrectionLevel);
        qrCode.addData(data);
      } else {
        qrCode = QrCode.fromData(
          data: data,
          errorCorrectLevel: errorCorrectionLevel,
        );
      }
      qrCode.make();
      return QrValidationResult(status: QrValidationStatus.valid, qrCode: qrCode);
    } on InputTooLongException catch (itle) {
      return QrValidationResult(status: QrValidationStatus.contentTooLong, error: itle);
    } on Exception catch (ex) {
      return QrValidationResult(status: QrValidationStatus.error, error: ex);
    }
  }
}

/// Captures the status or a QR code validation operations, as well as the
/// rendered and validated data / object so that it can be used in any
/// secondary operations (to avoid re-rendering). It also keeps any exception
/// that was thrown.
class QrValidationResult {
  /// Create a new validation result instance.
  QrValidationResult({@required this.status, this.qrCode, this.error});

  /// The status of the validation operation.
  QrValidationStatus status;

  /// The rendered QR code data / object.
  QrCode qrCode;

  /// The exception that was thrown in the event of a non-valid result (if any).
  Exception error;

  /// The validation result returned a status of valid;
  bool get isValid => status == QrValidationStatus.valid;
}

/// The status of the QR code data you requested to be validated.
enum QrValidationStatus {
  /// The QR code data is valid for the provided parameters.
  valid,

  /// The QR code data is too long for the provided version + error check
  /// configuration or too long to be contained in a QR code.
  contentTooLong,

  /// An unknown / unexpected error occurred when we tried to validate the QR
  /// code data.
  error,
}

class PaintCache {
  final List<Paint> _pixelPaints = <Paint>[];
  final Map<String, Paint> _keyedPaints = <String, Paint>{};

  String _cacheKey(QrCodeElement element, {FinderPatternPosition position}) {
    final posKey = position != null ? position.toString() : 'any';
    return '${element.toString()}:$posKey';
  }

  /// Save a [Paint] for the provided element and position into the cache.
  void cache(Paint paint, QrCodeElement element, {FinderPatternPosition position}) {
    if (element == QrCodeElement.codePixel) {
      _pixelPaints.add(paint);
    } else {
      _keyedPaints[_cacheKey(element, position: position)] = paint;
    }
  }

  /// Retrieve the first [Paint] object from the paint cache for the provided
  /// element and position.
  Paint firstPaint(QrCodeElement element, {FinderPatternPosition position}) {
    if (element == QrCodeElement.codePixel) {
      return _pixelPaints.first;
    } else {
      return _keyedPaints[_cacheKey(element, position: position)];
    }
  }

  /// Retrieve all [Paint] objects from the paint cache for the provided
  /// element and position. Note: Finder pattern elements can only have a max
  /// one [Paint] object per position. As such they will always return a [List]
  /// with a fixed size of `1`.
  List<Paint> paints(QrCodeElement element, {FinderPatternPosition position}) {
    if (element == QrCodeElement.codePixel) {
      return _pixelPaints;
    } else {
      return <Paint>[_keyedPaints[_cacheKey(element, position: position)]];
    }
  }
}
