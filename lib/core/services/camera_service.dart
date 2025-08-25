import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  List<CameraDescription> get cameras => _cameras;

  Future<bool> initialize() async {
    try {
      debugPrint('利用可能なカメラを取得中...');
      // 利用可能なカメラを取得（これ自体が権限要求をトリガー）
      _cameras = await availableCameras();
      debugPrint('発見されたカメラ数: ${_cameras.length}');
      
      if (_cameras.isEmpty) {
        debugPrint('利用可能なカメラがありません');
        return false;
      }

      // バックカメラを優先的に選択
      final camera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );
      debugPrint('選択されたカメラ: ${camera.name}, 向き: ${camera.lensDirection}');

      debugPrint('カメラコントローラーを初期化中...');
      // カメラコントローラーを初期化
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
      debugPrint('カメラ初期化が正常に完了しました');
      return true;
    } catch (e) {
      debugPrint('カメラ初期化エラー: $e');
      debugPrint('エラーの詳細: ${e.runtimeType}');
      
      // CameraExceptionの場合、権限関連かチェック
      if (e is CameraException) {
        debugPrint('CameraException コード: ${e.code}');
        debugPrint('CameraException 説明: ${e.description}');
        
        if (e.code == 'CameraAccessDenied' || e.code == 'camera_access_denied') {
          debugPrint('カメラアクセスが拒否されました');
        }
      }
      
      return false;
    }
  }

  Future<XFile?> takePicture() async {
    if (!_isInitialized || _controller == null) {
      debugPrint('Camera not initialized');
      return null;
    }

    try {
      return await _controller!.takePicture();
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  Future<void> startImageStream(Function(CameraImage) onLatestImageAvailable) async {
    if (!_isInitialized || _controller == null) {
      debugPrint('Camera not initialized for image stream');
      return;
    }

    try {
      _controller!.startImageStream(onLatestImageAvailable);
    } catch (e) {
      debugPrint('Error starting image stream: $e');
    }
  }

  Future<void> stopImageStream() async {
    if (!_isInitialized || _controller == null) {
      return;
    }

    try {
      await _controller!.stopImageStream();
    } catch (e) {
      debugPrint('Error stopping image stream: $e');
    }
  }

  Future<bool> switchCamera() async {
    if (_cameras.length <= 1) return false;

    try {
      final currentCamera = _controller?.description;
      final newCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection != currentCamera?.lensDirection,
        orElse: () => _cameras.first,
      );

      dispose();
      _controller = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Error switching camera: $e');
      return false;
    }
  }
}