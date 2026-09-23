# GRYolo advanced YOLO models

`UGRYoloComponent` supports standard YOLO11 layouts and YOLO26 end-to-end ONNX outputs for detection, pose, oriented boxes (OBB), and instance segmentation.

Place models in `Source/ThirdParty/OnnxRuntime/models`.  A same-name `.names` file is optional and contains one class name per line.  Built-in models include YOLO11/YOLO26 detection and pose, YOLO11/YOLO26 OBB, YOLO26 segmentation, and `facen`.

Use `MaxDetections`, `PoseConfidenceThreshold`, `SegConfidenceThreshold`, and `ForceModelType` to control decoding. `bEnableTracking` assigns persistent IDs; `ResetTracking`, `StopDetection`, and `SwitchModel` clear the tracker.  Input is transformed by `bFlipHorizontal`, `bFlipVertical`, and `InputRotation` before inference, so the returned coordinates use the transformed frame.

OBB detections expose `Angle` and `Corners`. Segmentation detections expose proto-resolution `MaskPixels`; `GetLatestMaskRenderTarget` returns a source-resolution RGBA target where R is `ClassId + 1` and A is mask alpha.
