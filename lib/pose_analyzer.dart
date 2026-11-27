import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseAnalysisResult {
  final bool detected;
  final String statusMessage;
  final double shoulderScore;      // 0.0 - 1.0
  final double waistScore;         // 0.0 - 1.0
  final double slouchScore;        // 0.0 - 1.0
  final double lowerBodyScore;     // 0.0 - 1.0
  final double shoulderToHipRatio;
  final double shoulderTiltDegrees;
  final Size? imageSize;
  final Map<String, Offset> normalizedLandmarks;

  const PoseAnalysisResult({
    required this.detected,
    required this.statusMessage,
    this.shoulderScore = 0.72,
    this.waistScore = 0.52,
    this.slouchScore = 0.40,
    this.lowerBodyScore = 0.50,
    this.shoulderToHipRatio = 1.38,
    this.shoulderTiltDegrees = 0.0,
    this.imageSize,
    this.normalizedLandmarks = const {},
  });
}

class SculptPoseEngine {
  static Future<PoseAnalysisResult> analyzeImage(String filePath) async {
    if (kIsWeb) {
      return const PoseAnalysisResult(
        detected: false,
        statusMessage: 'Web PWA preview loaded — adjust proportion markers below.',
      );
    }

    final options = PoseDetectorOptions(mode: PoseDetectionMode.single);
    final detector = PoseDetector(options: options);

    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final poses = await detector.processImage(inputImage);

      if (poses.isEmpty) {
        return const PoseAnalysisResult(
          detected: false,
          statusMessage: 'No full body detected. Stand 5–6 ft back in good lighting or use sliders.',
        );
      }

      final pose = poses.first;
      final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final lHip = pose.landmarks[PoseLandmarkType.leftHip];
      final rHip = pose.landmarks[PoseLandmarkType.rightHip];
      final lKnee = pose.landmarks[PoseLandmarkType.leftKnee];
      final rKnee = pose.landmarks[PoseLandmarkType.rightKnee];
      final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
      final rAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
      final lEar = pose.landmarks[PoseLandmarkType.leftEar];
      final rEar = pose.landmarks[PoseLandmarkType.rightEar];

      if (lShoulder == null || rShoulder == null || lHip == null || rHip == null) {
        return const PoseAnalysisResult(
          detected: false,
          statusMessage: 'Shoulders or hips partially out of frame — adjust sliders manually.',
        );
      }

      // Compute pixel widths
      final double shoulderWidth = _dist(lShoulder.x, lShoulder.y, rShoulder.x, rShoulder.y);
      final double hipWidth = math.max(1.0, _dist(lHip.x, lHip.y, rHip.x, rHip.y));
      final double rawRatio = shoulderWidth / hipWidth;

      // Shoulder level symmetry (tilt angle in degrees)
      final double dy = (lShoulder.y - rShoulder.y).abs();
      final double dx = math.max(1.0, (lShoulder.x - rShoulder.x).abs());
      final double tiltDeg = math.atan2(dy, dx) * 180 / math.pi;

      // Torso length vs leg length
      final double midShoulderY = (lShoulder.y + rShoulder.y) / 2;
      final double midHipY = (lHip.y + rHip.y) / 2;
      final double torsoHeight = math.max(1.0, (midHipY - midShoulderY).abs());

      double lowerBodyScore = 0.50;
      if (lKnee != null && rKnee != null && lAnkle != null && rAnkle != null) {
        final double midAnkleY = (lAnkle.y + rAnkle.y) / 2;
        final double legLength = (midAnkleY - midHipY).abs();
        final double legToTorso = legLength / torsoHeight;
        lowerBodyScore = (legToTorso / 2.2).clamp(0.25, 0.90);
      }

      // Estimate forward neck/shoulder compression using ear-to-shoulder vertical distance
      double slouchScore = 0.35;
      if (lEar != null && rEar != null) {
        final double midEarY = (lEar.y + rEar.y) / 2;
        final double neckExtension = (midShoulderY - midEarY).abs() / torsoHeight;
        slouchScore = (1.0 - (neckExtension * 2.4)).clamp(0.15, 0.85);
      }

      // Normalize scores for UI sliders
      final double shoulderScore = ((rawRatio - 0.95) / 0.85).clamp(0.35, 0.95);
      final double waistScore = (1.15 - (rawRatio * 0.45)).clamp(0.30, 0.85);

      // Estimate bounding box to normalize skeletal overlay coordinates (0.0 to 1.0)
      final allPts = pose.landmarks.values.toList();
      double minX = allPts.first.x, maxX = allPts.first.x;
      double minY = allPts.first.y, maxY = allPts.first.y;
      for (final p in allPts) {
        if (p.x < minX) minX = p.x;
        if (p.x > maxX) maxX = p.x;
        if (p.y < minY) minY = p.y;
        if (p.y > maxY) maxY = p.y;
      }
      final double spanX = math.max(1.0, maxX - minX);
      final double spanY = math.max(1.0, maxY - minY);

      Offset norm(PoseLandmark? lm) {
        if (lm == null) return Offset.zero;
        return Offset(
          ((lm.x - minX) / spanX).clamp(0.05, 0.95),
          ((lm.y - minY) / spanY).clamp(0.05, 0.95),
        );
      }

      final landmarks = <String, Offset>{
        'lShoulder': norm(lShoulder),
        'rShoulder': norm(rShoulder),
        'lHip': norm(lHip),
        'rHip': norm(rHip),
        if (lKnee != null) 'lKnee': norm(lKnee),
        if (rKnee != null) 'rKnee': norm(rKnee),
        if (lAnkle != null) 'lAnkle': norm(lAnkle),
        if (rAnkle != null) 'rAnkle': norm(rAnkle),
      };

      return PoseAnalysisResult(
        detected: true,
        statusMessage:
            'AI Scan Complete • Shoulder-to-Hip Ratio: ${rawRatio.toStringAsFixed(2)} • Tilt: ${tiltDeg.toStringAsFixed(1)}°',
        shoulderScore: shoulderScore,
        waistScore: waistScore,
        slouchScore: slouchScore,
        lowerBodyScore: lowerBodyScore,
        shoulderToHipRatio: rawRatio,
        shoulderTiltDegrees: tiltDeg,
        normalizedLandmarks: landmarks,
      );
    } catch (e) {
      return const PoseAnalysisResult(
        detected: false,
        statusMessage: 'Could not scan photo — use the proportion sliders below.',
      );
    } finally {
      await detector.close();
    }
  }

  static double _dist(double x1, double y1, double x2, double y2) {
    return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2));
  }
}
