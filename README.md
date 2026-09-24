# InteractionLab

> UE5.8 预编译插件（蓝图可用，无需 C++ 编译）。本仓库仅含二进制 DLL、模型、蓝图资产与插件描述文件，**不含 C++ 源代码**。

InteractionLab 是面向生成艺术、交互装置与沉浸式投影的综合功能库，集成人体追踪（MediaPipe / Kinect / Leap）、目标检测（YOLO）、实时抠像（MODNet）、离轴投影、点云与生成艺术等能力。

## 环境要求

| 项目 | 要求 |
|------|------|
| Unreal Engine | 5.8（Windows x64） |
| 项目类型 | 蓝图项目或 C++ 项目 |

依赖引擎插件：Niagara、LidarPointCloud、GeometryProcessing、ProceduralMeshComponent、CableComponent、XRBase 等。

## 安装

1. 将整个 `InteractionLab` 目录复制到 UE 项目 `Plugins/` 下。
2. 启动 UE 编辑器，在“插件”中启用 InteractionLab。
3. 按需放入授权文件（见下文）。



## 模块功能一览

| 模块 | 类型 | 功能简介 |
|------|------|----------|
| **GRYolo** | Runtime | YOLOv8 / YOLO11 / YOLO26 ONNX 目标检测、姿态、分割、OBB、**单目深度**；支持 CPU 与 DirectML GPU；可通过 `UGRYoloComponent` 直接采集摄像头 |
| **GRMediapipe** | Runtime | MediaPipe 手部/人脸/人体/人像分割追踪；相机 Debug 画面可选 Texture2D / RenderTarget 输出；`UMediapipeUEComponent` 蓝图组件 |
| **GRMatting** | Runtime | MODNet 实时人像抠像（ONNX Runtime + DirectML GPU），输出前景 Alpha 遮罩；`UGRMattingComponent` 支持摄像头输入 |
| **GRKinectAzure** | Runtime | Kinect Azure 深度/相机/骨架追踪 |
| **GRLeapMotion** | Runtime | Leap Motion 手部追踪与手势事件 |
| **GRBodyState** | Runtime | 设备无关的骨骼抽象层，支持自动绑骨 |
| **GRVSTHost** | Runtime | VST 音频插件宿主（含 MetaSound 节点） |
| **GRTuio20** | Runtime | TUIO 2.0 触控协议 |
| **InteractiveLab** | Runtime | LLM 对话、离轴投影、点云工具、生成艺术矩阵、风筝物理 |
| **InteractiveLabEditor** | Editor | 工具栏入口、授权管理、点云右键菜单 |
| **GRLeapMotionEditor** | Editor | 骨骼绑定节点定制面板 |
| **GRVSTHostEditor** | Editor | VST 节点引擎 |

## 常见问题

- **ONNX Runtime 不可用**：确认 `Binaries/ThirdParty/OnnxRuntime/Win64/onnxruntime.dll` 存在。
- **GPU 不生效**：`DirectML` 需支持 DirectML 的显卡驱动，失败自动回退 CPU。
- **授权无效**：通过编辑器工具栏 `InteractiveLab → License Manager` 查看机器指纹，获取 `GenartLicense.json` 后放至 `Config/`。