# GenartLib — 蓝图可用版本

> UE5.8 预编译插件，面向蓝图项目，无需 C++ 编译即可使用。

GenartLib 是一个面向生成艺术、交互装置与沉浸式投影的综合功能库，集成了 LLM 对话、Leap Motion 手部追踪、MediaPipe 视觉追踪、YOLO 目标检测、离轴投影、点云工具、生成艺术矩阵等功能模块。本仓库为**蓝图预编译版本**，仅包含二进制 DLL、模型文件、蓝图资产与插件描述文件，不含 C++ 源代码。

---

## 目录

- [环境要求](#环境要求)
- [安装方式](#安装方式)
- [授权机制](#授权机制)
- [模块功能一览](#模块功能一览)
- [各模块使用文档](#各模块使用文档)
  - [GRYolo — YOLO 目标检测](#gryolo--yolo-目标检测)
  - [MediapipeUE — 视觉追踪](#mediapipeue--视觉追踪)
  - [GRLeapMotion — Leap Motion 手部追踪](#grleapmotion--leap-motion-手部追踪)
  - [GRBodyState — 骨骼抽象层](#grbodystate--骨骼抽象层)
  - [OffAxisProjection — 离轴投影](#offaxisprojection--离轴投影)
  - [LLM — OpenAI 兼容对话](#llm--openai-兼容对话)
  - [PointCloud — 点云工具](#pointcloud--点云工具)
  - [GenartMatrixArt — 生成艺术矩阵](#genartmatrixart--生成艺术矩阵)
  - [GenartFZBase — 风筝物理](#genartfzbase--风筝物理)
- [示例场景](#示例场景)
- [常见问题](#常见问题)

---

## 环境要求

| 项目 | 要求 |
|------|------|
| Unreal Engine | 5.8（BuildId: 55116800） |
| 平台 | Windows 64-bit |
| 项目类型 | 蓝图项目或 C++ 项目均可 |
| 可选硬件 | Leap Motion 控制器、摄像头、NVIDIA GPU（用于 YOLO DirectML 加速） |

**依赖的引擎插件**（启用本插件时会自动启用）：XRBase、LidarPointCloud、GeometryProcessing、CableComponent、Niagara。

---

## 安装方式

1. 将整个 `genartlib` 文件夹复制到你 UE 项目的 `Plugins/` 目录下。
2. 重启 UE 编辑器，或在弹出的"发现新插件"对话框中选择"是"。
3. 在 `编辑 → 插件` 中确认 GenartLib 已启用。
4. 根据需要放置授权文件（见下文）。

```
YourProject/
└── Plugins/
    └── genartlib/          ← 本仓库内容
        ├── Binaries/        预编译 DLL
        ├── Content/         蓝图资产与示例地图
        ├── Config/          插件过滤器
        ├── Source/
        │   └── ThirdParty/
        │       ├── OnnxRuntime/models/    YOLO 模型
        │       └── MediapipeBridge/models/ MediaPipe 模型
        └── genartlib.uplugin
```

---

## 授权机制

GenartLib 采用基于 Ed25519 数字签名的授权系统，部分功能需要授权才能使用。

### 需要授权的功能

| 功能令牌 | 对应模块 |
|----------|----------|
| `pointcloud` | 点云工具 |
| `llm` | LLM 对话 |
| `offaxis` | 离轴投影 |
| `ultraleap` | Leap Motion 手部追踪 |
| `mediapipe` | MediaPipe 视觉追踪 |
| `yolo` | YOLO 目标检测 |
| `all` / `*` | 全部功能 |

### 授权文件放置

将 `GenartLicense.json` 放到以下任一路径（插件会自动扫描）：

1. `<项目>/Config/GenartLicense.json`
2. `<项目>/Saved/GenartLicense.json`
3. `<项目>/Plugins/genartlib/Config/GenartLicense.json`
4. `<项目>/Plugins/genartlib/Resources/GenartLicense.json`

> **提示**：可通过编辑器工具栏的 `GenartLib → License Manager` 查看当前机器指纹与授权状态，便于申请授权。

---

## 模块功能一览

| 模块 | 类型 | 功能简介 |
|------|------|----------|
| **GRYolo** | Runtime | YOLOv8 ONNX 目标检测 / 姿态估计，支持 CPU 与 DirectML GPU |
| **GenartLib** (MediapipeUE) | Runtime | MediaPipe 手部/人脸/人体/分割追踪 |
| **GRLeapMotion** | Runtime | Leap Motion 手部追踪与手势事件 |
| **GRBodyState** | Runtime | 设备无关的骨骼抽象层，支持自动绑骨 |
| **GenartLib** (OffAxis) | Runtime | 离轴投影（CAVE / 沙盘 / 畸变校正） |
| **GenartLib** (LLM) | Runtime | OpenAI 兼容的 LLM 对话（含流式） |
| **GenartLib** (PointCloud) | Runtime/Editor | 点云数据转纹理工具 |
| **GenartLib** (MatrixArt) | Runtime | 三维矩阵生成艺术 |
| **GenartLib** (FZBase) | Runtime | 风筝飞行物理模拟 |
| **GenartLibEditor** | Editor | 工具栏入口、点云右键菜单、授权管理 |
| **GRLeapMotionEditor** | Editor | 骨骼绑定节点 Details 面板定制 |

---

## 各模块使用文档

### GRYolo — YOLO 目标检测

基于 ONNX Runtime 的实时 YOLOv8 目标检测与姿态估计，支持 CPU 与 DirectML GPU 加速。

#### 核心组件

**`UGRYoloComponent`**（ClassGroup=GRYolo，BlueprintSpawnableComponent）

#### 快速开始（蓝图）

1. 给 Actor 添加 `GRYolo Component`。
2. 设置属性：
   - `Model Filename`：下拉选择模型（如 `yolov8n.onnx` 或 `yolov8n-pose.onnx`）。
   - `Device Type`：`CPU` 或 `DirectML (GPU)`（GPU 需要 DirectML 版 onnxruntime.dll）。
   - `b Use Camera`：勾选后直接使用摄像头；否则用 `Input Render Target`。
   - `Camera Device Name`：摄像头名称（部分匹配），留空则用 `Camera Device Index`。
   - `Confidence Threshold` / `NMS Threshold`：检测阈值。
   - `Inference Interval`：推理间隔（秒）。`>0` 时优先于 `Max Process FPS`，例如 `0.1` = 10FPS，`0.5` = 2FPS。
3. 调用 `Start Detection` 开始。
4. 绑定事件 `On Frame Processed` 获取 `Latest Detections` 数组。
5. 可选：勾选 `b Overlay Source Frame` 在 `Debug Overlay Render Target` 上叠加原始画面与边界框/骨架。

#### 关键蓝图函数

| 函数 | 说明 |
|------|------|
| `Start Detection` | 启动检测（含授权检查、模型加载、摄像头打开） |
| `Stop Detection` | 停止检测并释放会话 |
| `Switch Model` | 运行时切换模型文件 |
| `Get Available Models` | 列出 models 目录下所有 .onnx 文件 |
| `Process Render Target` | 手动处理一个 RenderTarget |
| `Get Model Type` | 返回当前模型类型（Detection / Pose / Segmentation） |
| `Get Num Keypoints` | 姿态模型的关键点数（COCO = 17） |
| `Get Active Device Type` | 当前推理设备（CPU / DirectML） |

#### 数据结构

- `FYoloDetection`：`Class Name`、`Class Id`、`Confidence`、`Bounding Box`（FBox2D）、`Keypoints`（姿态模型）
- `FYoloKeypoint`：`Position`（像素坐标）、`Visibility`
- `EYoloModelType`：`Detection` / `Pose` / `Segmentation` / `Unknown`
- `EYoloDeviceType`：`CPU` / `DirectML (GPU)`

#### 自定义模型

- 将 `.onnx` 文件放入 `Source/ThirdParty/OnnxRuntime/models/`。
- 可选：放置同名 `.names` 文件（每行一个类别名）用于自定义类别显示。
- 支持的模型格式：YOLOv8 Detection（`[1,84,8400]`）、YOLOv8 Pose（`[1,56,8400]`，COCO 17 关键点）。

---

### MediapipeUE — 视觉追踪

通过自带 `mediapipe_bridge.dll` 调用 Google MediaPipe，实现手部、人脸、人体、人像分割的实时追踪。

#### 核心组件

**`UMediapipeUEComponent`**（ClassGroup=MediaPipe，BlueprintSpawnableComponent）

#### 快速开始

1. 添加 `Mediapipe UE Component` 到 Actor。
2. 勾选需要的功能：`b Enable Hand Tracking` / `b Enable Face Tracking` / `b Enable Pose Tracking` / `b Enable Segmentation`。
3. 输入源：
   - 摄像头：勾选 `b Use Camera`，设置 `Camera Device Index` 或 `Camera Device Name`。
   - RenderTarget：指定 `Input Render Target`，勾选 `b Auto Process Render Target`。
4. `Delegate` 推荐选 `XNNPACK`（CPU 高性能）。
5. 调用 `Start Mediapipe`。
6. 读取结果属性：`Latest Hands` / `Latest Faces` / `Latest Pose` / `Latest Segmentation`。

#### 关键蓝图函数

| 函数 | 说明 |
|------|------|
| `Start Mediapipe` / `Stop Mediapipe` | 生命周期控制 |
| `Process Render Target` | 手动处理 RenderTarget |
| `Open Camera` / `Close Camera` / `Is Camera Open` | 摄像头控制 |
| `Enumerate Camera Devices` | 列出可用摄像头（静态） |
| `Switch Segment Model` | 切换分割模型 |
| `Get Available Segment Models` | 列出可用分割模型 |

#### 自带模型

| 模型文件 | 用途 |
|----------|------|
| `hand_landmarker.task` | 21 手部关键点 + 手势识别 |
| `face_landmarker.task` | 478 人脸关键点 + Blendshapes |
| `pose_landmarker.task` | 33 人体关键点 |
| `selfie_segmenter.tflite` | 人像分割 |
| `selfie_multiclass_256x256.tflite` | 多类分割（头发/皮肤/衣物等） |

#### 性能调优

- `Inference Interval`（秒）：`>0` 时优先于 `Max Process FPS`。
- `Max Process FPS`：推理帧率上限。
- 只勾选实际需要的功能开关，避免多余推理。

---

### GRLeapMotion — Leap Motion 手部追踪

基于 Ultraleap LeapSDK 的 Leap Motion 手部追踪，提供事件式数据回调。

#### 核心组件

**`UGRLeapComponent`**（ClassGroup=LeapMotion，BlueprintSpawnableComponent）

#### 快速开始

1. 添加 `GR Leap Component` 到 Actor 或 Pawn。
2. 设置 `Tracking Mode`：`VR` / `Desktop` / `Screentop`。
3. 绑定需要的事件。
4. Leap 服务运行后会自动开始追踪。

#### 关键事件

| 事件 | 说明 |
|------|------|
| `On Leap Tracking Data` | 每帧追踪数据（含双手） |
| `On Hand Grabbed` / `On Hand Released` | 抓取手势开始/结束 |
| `On Hand Pinched` / `On Hand Unpinched` | 捏合手势开始/结束 |
| `On Hand Begin Tracking` / `On Hand End Tracking` | 手进入/离开视野 |
| `On Leap Device Attached` / `Detached` | 设备插拔 |
| `On Image Event` | 设备图像（需开启 Images 策略） |
| `On Leap Service Connected` / `Disconnected` | 服务连接状态 |

#### 全局函数（`GRLeapBlueprintFunctionLibrary`）

| 函数 | 说明 |
|------|------|
| `Set Leap Mode` | 设置追踪模式与精度 |
| `Set Leap Options` / `Get Leap Options` | 完整选项（含手势阈值、插值、HMD 偏移） |
| `Set Leap Policy` | 策略开关（后台帧/图像/HMD 优化等） |
| `Get Leap Stats` | API 版本、设备信息、帧率 |
| `Get Attached Leap Devices` | 已连接设备列表 |

#### 数据结构

- `FGRLeapFrameData`：`Number Of Hands Visible`、`Frame Rate`、`Hands` 数组
- `FGRLeapHandData`：`Hand Type`、`Confidence`、`Grab Strength`、`Pinch Strength`、`Palm`、`Arm`、`Digits`
- `FGRLeapDigitData`：五指各关节骨骼数据

---

### GRBodyState — 骨骼抽象层

设备无关的骨骼数据中间层，支持多源追踪输入合并、自动绑骨、驱动任意 Skeletal Mesh。

#### 核心类

| 类 | 用途 |
|----|------|
| `UGRBodyStateBPLibrary` | 蓝图入口：设备注册、骨架查询 |
| `UGRBodyStateSkeleton` | 全身骨架数据（60+ 标准骨骼） |
| `UGRBodyStateAnimInstance` | 骨架 → Skeletal Mesh 映射动画实例 |
| `UGRBodyStateBoneComponent` | 跟随某根骨骼的 SceneComponent |

#### 典型用法

1. 追踪源（Leap / MediaPipe 等）通过 `Attach Device` 注册设备，获得 DeviceID。
2. `Skeleton For Device(DeviceID=0)` 获取合并骨架。
3. 在 Skeletal Mesh 的 AnimBlueprint 中使用 `GRBodyStateAnimInstance`。
4. 调用 `Auto Detect Hand Bones` 自动识别手部骨骼映射，或手动 `Add BSBone To Mesh Bone Link`。
5. AnimBP 的 `Modify Body State Mapped Bones` 节点会自动驱动网格骨骼。

#### 关键函数

| 函数 | 说明 |
|------|------|
| `Attach Device` | 注册追踪设备 |
| `Skeleton For Device` | 获取骨架（0 = 合并骨架） |
| `Auto Detect Hand Bones` | 自动识别手部骨骼映射 |
| `Add BSBone To Mesh Bone Link` | 手动添加骨骼映射 |
| `Bone Named` | 按名称获取骨骼 |

---

### OffAxisProjection — 离轴投影

在任意形状/朝向的物理屏幕上，根据观察者头部位置实时计算非对称投影矩阵。适用于 CAVE、投影沙盘、立体显示、畸变校正。

#### 核心类

| 类 | 用途 |
|----|------|
| `AGRGenartOffAxisProjectionActor` | 屏幕定义与投影计算 |
| `AGRGenartOffAxisCharacter` | 带相机切换的角色 |
| `UGRGenartOffAxisProjectionSubsystem` | World 子系统，管理多屏 |

#### 快速开始

1. 放置 `GRGenartOffAxisProjectionActor` 到场景，定义屏幕四角（`Set Screen Corner World Locations`）。
2. 使用 `AGRGenartOffAxisCharacter` 作为玩家角色。
3. 调用 `Switch To OffAxis View` 切换到离轴视角。
4. 角色移动时，观察者位置自动更新，投影矩阵实时调整。

#### 多屏管理

- `Add Screen` / `Update Screen` / `Remove Screen By Id`
- `Set Active Screen By Id` 切换当前激活屏幕
- 每个屏幕有独立 ScreenId 与四角坐标

---

### LLM — OpenAI 兼容对话

支持 OpenAI 协议的 LLM 对话，含一次性响应与流式响应。可通过自定义 `Base URL` 接入任意兼容服务。

#### 核心函数（`GRGenartFunctions`）

| 函数 | 说明 |
|------|------|
| `Send Chat Message` | 一次性对话（异步回调） |
| `Send Chat Message Stream` | 流式对话（增量回调 + 完成回调） |
| `Create Chat Context` | 创建带 System Prompt 的上下文 |
| `Append Message` | 追加消息到上下文 |

#### 配置

`FGROpenAIConfig`：
- `Base URL`：默认 `https://api.openai.com/v1`，可改为兼容服务
- `API Key`
- `Model`：默认 `gpt-3.5-turbo`
- `Temperature` / `Max Tokens`

---

### PointCloud — 点云工具

将 LiDAR 点云数据转换为颜色/位置纹理。

#### 编辑器右键菜单

在 Content Browser 中右键 `LidarPointCloud` 资产 → `GenartLib`：
- **Create Colors Texture**：生成颜色贴图
- **Create Positions Texture**：生成位置贴图（Editor-only）

#### 蓝图函数（`GRPointCloudFunctions`）

- `Data Table To Point Cloud Vectors`：DataTable → XYZ/RGB 数组
- `Create Point Cloud Colors Texture`：点云 → 颜色纹理

---

### GenartMatrixArt — 生成艺术矩阵

用模板组件生成三维网格矩阵，支持递归分裂/聚合。

#### 核心函数（`AGenartMatrixArtActor`）

| 函数 | 说明 |
|------|------|
| `Create Matrix` | 生成 Rows×Cols×Depth 矩阵 |
| `Split Cell By Index` | 分裂指定 cell |
| `Aggregate Cell By Index` | 聚合指定 cell |
| `Random Split Cell` / `Random Aggregate Cell` | 随机操作 |
| `Clear Matrix` | 清空 |

#### 关键属性

- `b Animate Cell Spawn`：生成动画
- `Spawn Anim Duration`：动画时长
- `Max Split Depth`：最大分裂深度（0 = 无限）

---

### GenartFZBase — 风筝物理

风筝飞行物理模拟，含风场、气动、牵引绳、轨道力、抓取检测。

#### 核心属性分组

| 分组 | 关键参数 |
|------|----------|
| 牵引 | Tether Length |
| 风场 | Wind Direction / Strength |
| 噪声 | Noise Strength / Frequency |
| 气动 | Lift / Drag Factor |
| 稳定 | Pitch / Roll / Yaw Stability |
| 轨道力 | Orbital Center / Strength / Radius |
| 抓取 | Grab Detect Range / Mode |

#### 事件

- `BP_On Grab Triggered`：抓取触发（蓝图实现）
- `BP_On Grab Released`：抓取释放

---

## 示例场景

`Content/` 目录下提供以下示例地图：

| 路径 | 内容 |
|------|------|
| `Yolo/NewMap` | YOLO 检测示例 |
| `MediapipeUE/MediapipeUEOverview` | MediaPipe 功能总览 |
| `MediapipeFaceTracking/MP_face_track` | 人脸追踪 |
| `LeapMotion/HandModules/ExampleScenes/HandsOverlapped` | Leap 手部叠加 |
| `OffAxisMapping/OffAxisActor` | 离轴投影示例 |
| `LLM/LLM_ChatTest` | LLM 对话测试 |
| `Generating/Generating` | 生成艺术示例 |

---

## 常见问题

### Q: 启动时提示"ONNX Runtime 不可用"？

确保 `Binaries/ThirdParty/OnnxRuntime/Win64/onnxruntime.dll` 存在。本仓库已包含。

### Q: YOLO GPU 推理不生效？

`Device Type` 设为 `DirectML (GPU)` 需要支持 DirectML 的 GPU 驱动。若加载失败会自动回退到 CPU，查看 Output Log 确认实际设备。

### Q: MediaPipe 摄像头打不开？

调用 `Enumerate Camera Devices` 查看可用设备列表，确认 `Camera Device Index` 或 `Camera Device Name` 正确。名称支持部分匹配。

### Q: Leap Motion 没有数据？

1. 确认 Ultraleap Tracking Service 已运行（系统托盘有图标）。
2. 确认设备已连接。
3. 查看 Output Log 的 `LogLeap` 类别日志。

### Q: 授权功能无法使用？

通过编辑器工具栏 `GenartLib → License Manager` 查看机器指纹，联系授权方获取 `GenartLicense.json`，放到 [授权文件放置](#授权文件放置) 中所述路径。

### Q: 可以在 C++ 项目中使用吗？

可以。本版本虽不含源代码，但预编译的 DLL 可直接被 C++ 项目加载使用。若需要源代码，请联系授权方获取完整开发版本。

---

## 技术规格

- **引擎版本**：Unreal Engine 5.8（BuildId: 55116800）
- **目标平台**：Windows 64-bit
- **ONNX Runtime**：1.18.1（CPU + DirectML）
- **MediaPipe**：Google MediaPipe Tasks
- **Leap SDK**：Ultraleap Gemini
- **许可**：本预编译版本受 GenartLib 授权协议约束，详见 [授权机制](#授权机制)
