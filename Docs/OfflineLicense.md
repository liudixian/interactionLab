# GenartLib 离线授权（Ed25519）

## 目标

- 许可证文件分发（JSON）
- 插件内置公钥进行离线验签（防篡改）
- `allowedMachineIds` 绑定机器指纹（machine fingerprint）

## 许可证字段（概览）

许可证为 JSON，关键字段如下（完整校验逻辑以 [GenartLicenseManager.cpp](file:///d:/Projects/p4Workspaces/InteractionToy_Main_ue5.7/InteractionToy/Plugins/GenartLib/Source/GenartLib/Private/GenartLicenseManager.cpp) 为准）：

- `version/product/licenseId/licensee/licenseType/machineLimit`
- `allowedMachineIds: string[]`（必须包含当前机器指纹）
- `issuedAt/expiresAt`（ISO8601，带 Z）
- `features: string[]`（功能点：`pointcloud`/`llm`/`offaxis`/`all`/`*`）
- `signature: "ed25519:<base64>"`（对 canonical payload 的 Ed25519 签名）

canonical payload 的拼接格式与字段顺序见：

- [BuildSignaturePayload](file:///d:/Projects/p4Workspaces/InteractionToy_Main_ue5.7/InteractionToy/Plugins/GenartLib/Source/GenartLib/Private/GenartLicenseManager.cpp#L446-L460)

## 获取机器指纹

在蓝图中调用：

- `GenartLib` → `Get Genart Machine Fingerprint`（对应 `UCommonFunctions::GetGenartMachineFingerprint()`）

代码位置：

- [CommonFunctions.h](file:///d:/Projects/p4Workspaces/InteractionToy_Main_ue5.7/InteractionToy/Plugins/GenartLib/Source/GenartLib/Public/CommonFunctions.h)
- [CommonFunctions.cpp](file:///d:/Projects/p4Workspaces/InteractionToy_Main_ue5.7/InteractionToy/Plugins/GenartLib/Source/GenartLib/Private/CommonFunctions.cpp)

## 生成密钥对（签发方）

在工程根目录执行：

```bash
node Scripts/genart-license-keygen.js
```

默认输出目录：`.genart-license-keys/`

- `genart_ed25519_public.pem`
- `genart_ed25519_private.pem`

## 在插件内配置公钥（验签方）

将 `genart_ed25519_public.pem` 的 PEM 内容填入：

- [GenartLicenseManager.cpp](file:///d:/Projects/p4Workspaces/InteractionToy_Main_ue5.7/InteractionToy/Plugins/GenartLib/Source/GenartLib/Private/GenartLicenseManager.cpp) 内部的 `PublicKeyPem` 字符串常量

## 生成并签名许可证（签发方）

1) 使用 Band 页面生成“未签名 JSON”（`signature` 为 `ed25519:` 占位）。
2) 在工程根目录执行签名：

```bash
node Scripts/genart-license-sign.js --in <license.json> --key .genart-license-keys/genart_ed25519_private.pem
```

输出文件默认覆盖输入文件（也可加 `--out` 指定新文件）。

## 放置许可证文件（被授权方）

将最终文件命名为 `GenartLicense.json`，并放到以下任一路径（插件会自动查找）：

- `<Project>/Config/GenartLicense.json`
- `<Project>/Saved/GenartLicense.json`
- `<Project>/Plugins/GenartLib/Config/GenartLicense.json`
- `<Project>/Plugins/GenartLib/Resources/GenartLicense.json`

