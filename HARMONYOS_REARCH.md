# HarmonyOS Next 6.0.2 (API12) ArkTS 重新架构方案

本文基于当前 Android 版本源码的结构与行为，输出在 HarmonyOS Next 6.0.2（API12）上使用 ArkTS + ArkUI 实现“同等功能与 UI”的重新架构方案。

## 1. 现有 Android 工程能力拆解（作为迁移基线）

### 1.1 UI 与导航
- 应用通过 `MainActivity` 组织底部四个主 Tab（首页/应用/日志/设置），并使用 Compose Navigation 进行页面跳转，包含设置与模型配置页面等子页面。【F:app/src/main/java/com/example/open_autoglm_android/MainActivity.kt†L46-L206】
- UI 采用 MVVM：`ChatViewModel` 持有 UI 状态与对话列表、当前任务状态、执行耗时等；页面通过 ViewModel 状态驱动渲染与交互。【F:app/src/main/java/com/example/open_autoglm_android/ui/viewmodel/ChatViewModel.kt†L33-L154】

### 1.2 自动化核心（可视化理解 + 操作）
- 自动化入口在 `AutoGLMAccessibilityService`：负责监听当前前台应用、截图、触控/滑动/返回等系统级手势与动作。【F:app/src/main/java/com/example/open_autoglm_android/service/AutoGLMAccessibilityService.kt†L24-L168】
- 动作解析与执行在 `ActionExecutor`：解析模型返回 JSON（或 `do/finish` 函数格式），并调度具体动作（点击、滑动、输入、返回、启动应用等）。【F:app/src/main/java/com/example/open_autoglm_android/domain/ActionExecutor.kt†L20-L165】

### 1.3 输入能力（输入法模式）
- 项目内置自定义输入法 `MyInputMethodService`，用于在特定输入模式下直接提交文本（IME 模式），并提供轻量 UI（状态 + 测试输入 + 切换输入法按钮）。【F:app/src/main/java/com/example/open_autoglm_android/service/MyInputMethodService.kt†L1-L146】
- `AutoGLMAccessibilityService` 在 `InputMode.IME` 时调用输入法进行文本提交，并与点击/粘贴策略互补。【F:app/src/main/java/com/example/open_autoglm_android/service/AutoGLMAccessibilityService.kt†L168-L219】

### 1.4 数据层
- 用户配置（API Key、Base URL、模型名、输入模式、压缩策略等）保存在 DataStore Preferences 中，由 `PreferencesRepository` 统一访问。【F:app/src/main/java/com/example/open_autoglm_android/data/PreferencesRepository.kt†L1-L170】
- 对话与模型配置存储在 Room 数据库（`Conversation`/`SavedChatMessage`/`ModelConfig`）。【F:app/src/main/java/com/example/open_autoglm_android/data/database/AppDatabase.kt†L1-L41】

### 1.5 模型请求
- `ModelClient` 负责构建系统 prompt、拼装图像 + 文本输入、调用 AutoGLM API，并解析 `thinking/action` 内容。【F:app/src/main/java/com/example/open_autoglm_android/network/ModelClient.kt†L1-L214】

---

## 2. HarmonyOS Next ArkTS 重新架构目标

目标是在 **HarmonyOS Next 6.0.2（API12）** 上复刻 Android 版本核心能力：
- **同等 UI 与交互流程**：底部主 Tab + 对话/日志/应用/设置等页面；保留“多轮对话 + 任务状态 + 停止/暂停”等体验。
- **同等自动化能力**：截图 + 屏幕理解 + 执行动作（点击/滑动/返回/启动应用）。
- **同等输入策略**：输入法能力 + “设置/粘贴/IME”多策略输入。
- **同等数据能力**：本地配置 + 对话历史。

---

## 3. HarmonyOS 目标架构（模块拆分）

### 3.1 模块划分

```
entry/                    # UIAbility + ArkUI 页面
├─ pages/                 # Main/Apps/PromptLog/Settings/ModelConfig
├─ viewmodel/             # 状态管理类（等价 ViewModel）
├─ router/                # 页面导航封装
feature_automation/       # 自动化能力
├─ accessibility/         # AccessibilityExtensionAbility
├─ action/                # ActionExecutor（ArkTS 解析 + 执行）
├─ screenshot/            # 截图 & 图像压缩
feature_ime/              # 输入法能力
├─ ime/                   # InputMethodExtensionAbility + 状态 UI
common_data/              # 数据层
├─ preferences/           # 配置持久化
├─ database/              # RDB 对话历史与模型配置
common_network/           # 模型请求
├─ client/                # AutoGLM 请求封装
```

### 3.2 对应关系（Android → HarmonyOS）

| Android 组件 | HarmonyOS Next 等价 | 备注 |
| --- | --- | --- |
| `MainActivity` + Compose Navigation | `UIAbility` + `ArkUI Router` | 负责底部 Tab 与页面跳转。【F:app/src/main/java/com/example/open_autoglm_android/MainActivity.kt†L46-L206】 |
| `ChatViewModel` | ArkTS 状态管理类（`@State`/`@Observed` + Store） | 管理对话状态/加载/暂停逻辑。【F:app/src/main/java/com/example/open_autoglm_android/ui/viewmodel/ChatViewModel.kt†L33-L154】 |
| `AutoGLMAccessibilityService` | `AccessibilityExtensionAbility` | 承载监听应用、截图、手势执行。【F:app/src/main/java/com/example/open_autoglm_android/service/AutoGLMAccessibilityService.kt†L24-L168】 |
| `MyInputMethodService` | `InputMethodExtensionAbility` | 维持 IME 输入 + 状态 UI。【F:app/src/main/java/com/example/open_autoglm_android/service/MyInputMethodService.kt†L1-L146】 |
| `PreferencesRepository` | `Preferences`/`DataPreferences` | 保存 API/输入模式等配置。【F:app/src/main/java/com/example/open_autoglm_android/data/PreferencesRepository.kt†L1-L170】 |
| Room (`AppDatabase`) | `RDBStore` | 保存对话历史与模型配置。【F:app/src/main/java/com/example/open_autoglm_android/data/database/AppDatabase.kt†L1-L41】 |
| `ModelClient` | ArkTS `HttpRequest`/`fetch` 客户端 | 构建系统 prompt & 图片上传。【F:app/src/main/java/com/example/open_autoglm_android/network/ModelClient.kt†L1-L214】 |

---

## 4. 核心能力在 HarmonyOS 的实现要点

### 4.1 UI 与导航
- 使用 ArkUI 构建 `Tabs` + `TabContent`（四大主页面）。
- 页面结构对齐 Android：`Main`（聊天）、`Apps`（应用列表）、`PromptLog`（日志）、`Settings`（配置/权限引导）。【F:app/src/main/java/com/example/open_autoglm_android/MainActivity.kt†L46-L206】
- 聊天页面保持结构：消息列表、输入框、发送按钮、任务状态、停止/暂停入口（对应 FloatingWindow 控制）。【F:app/src/main/java/com/example/open_autoglm_android/ui/viewmodel/ChatViewModel.kt†L33-L154】

### 4.2 自动化核心（AccessibilityExtensionAbility）
- **截图**：提供 `takeScreenshot()` API，返回 `PixelMap`；与 UIAbility 共享最新截图流（等价 `_latestScreenshot` 的 Flow）。【F:app/src/main/java/com/example/open_autoglm_android/service/AutoGLMAccessibilityService.kt†L53-L112】
- **手势执行**：封装 `tap/longPress/swipe/back/home`，供 ActionExecutor 调用。【F:app/src/main/java/com/example/open_autoglm_android/service/AutoGLMAccessibilityService.kt†L126-L166】
- **前台应用监听**：维护 `currentApp`（UI 即时展示）。【F:app/src/main/java/com/example/open_autoglm_android/service/AutoGLMAccessibilityService.kt†L33-L68】

### 4.3 输入法能力（InputMethodExtensionAbility）
- 实现与 Android 类似的轻量 IME UI：显示状态、测试输入、切换输入法按钮；可通过 ArkUI 布局直接构建输入法视图。【F:app/src/main/java/com/example/open_autoglm_android/service/MyInputMethodService.kt†L70-L146】
- 自动化时的输入策略：
  - `SET_TEXT` → Accessibility 直接设置文本
  - `PASTE` → 复制/粘贴
  - `IME` → 通过输入法提交文本
  （保持与 Android 的三策略一致）【F:app/src/main/java/com/example/open_autoglm_android/data/PreferencesRepository.kt†L18-L31】【F:app/src/main/java/com/example/open_autoglm_android/service/AutoGLMAccessibilityService.kt†L168-L219】

### 4.4 模型请求与响应解析
- ArkTS 端 `ModelClient` 模块保持与 Android 逻辑一致：
  - 组装系统 prompt + 用户消息
  - 截图 base64 处理
  - 解析 `thinking/action` 响应，并生成动作 JSON。【F:app/src/main/java/com/example/open_autoglm_android/network/ModelClient.kt†L1-L214】

### 4.5 动作解析与执行
- ArkTS `ActionExecutor` 复刻 Android 解析策略：
  - `do/finish` 函数格式
  - JSON 容错修复
  - 标准动作调度（点击/滑动/输入/返回/启动应用）。【F:app/src/main/java/com/example/open_autoglm_android/domain/ActionExecutor.kt†L20-L165】

---

## 5. HarmonyOS ArkTS 项目结构建议

### 5.1 目录结构
```
entry/src/main/ets/
├─ entryability/
│  └─ MainAbility.ets
├─ pages/
│  ├─ MainPage.ets
│  ├─ AppsPage.ets
│  ├─ PromptLogPage.ets
│  ├─ SettingsPage.ets
│  └─ ModelConfigPage.ets
├─ viewmodel/
│  ├─ ChatStore.ets
│  ├─ SettingsStore.ets
│  └─ AppsStore.ets
├─ router/
│  └─ Routes.ets
├─ common/
│  ├─ constants.ets
│  └─ ui/ (组件化 widget)

feature_automation/src/main/ets/
├─ accessibility/
│  └─ AutoGLMAccessibilityExt.ets
├─ action/
│  └─ ActionExecutor.ets
├─ screenshot/
│  └─ ScreenshotService.ets

feature_ime/src/main/ets/
└─ ime/
   └─ AutoGLMInputMethodExt.ets

common_data/src/main/ets/
├─ preferences/SettingsStore.ets
└─ database/ConversationStore.ets

common_network/src/main/ets/
└─ client/ModelClient.ets
```

### 5.2 状态管理范式
- 使用 `@State`/`@Observed` 管理 UI 状态，封装在 `ChatStore` 中。
- Store 内部维护对话列表/当前对话/是否执行中/暂停等状态，等价于 Android `ChatViewModel` 的职责。【F:app/src/main/java/com/example/open_autoglm_android/ui/viewmodel/ChatViewModel.kt†L33-L154】

---

## 6. 核心流程（HarmonyOS）

```
用户输入任务
  -> 截图 (AccessibilityExt)
  -> ModelClient 请求
  -> ActionExecutor 解析 JSON
  -> 执行动作 (AccessibilityExt)
  -> 继续截图/执行，直到 finish
```

该流程与 Android `ChatViewModel` 的主逻辑一致：由 UI 驱动模型请求，再通过 ActionExecutor 进行执行并回写状态。【F:app/src/main/java/com/example/open_autoglm_android/ui/viewmodel/ChatViewModel.kt†L33-L154】【F:app/src/main/java/com/example/open_autoglm_android/domain/ActionExecutor.kt†L20-L165】

---

## 7. 迁移里程碑建议

1. **UI/导航对齐**：ArkUI 建立四大主页面 + 路由逻辑。
2. **数据层落地**：Preferences + RDB 对话存储。
3. **模型请求封装**：实现 ArkTS `ModelClient`。
4. **Accessibility Extension**：完成截图与动作执行。
5. **IME Extension**：输入法 UI 与文本提交能力。
6. **端到端验证**：与 Android 等价的任务执行流程。

---

## 8. 风险与注意事项

- **系统权限**：HarmonyOS 的 Accessibility 与截图权限需走系统授权与上架审核流程。
- **输入法前台限制**：IME 触发与输入焦点需要明确的系统权限与用户授权。
- **多线程/并发**：ArkTS 任务调度与 Android Coroutines 不完全等价，需基于 `TaskPool` 或 `Promise` 设计异步流程。

---

如需下一步，我可以基于该方案进一步输出 **ArkTS 目录模板**、**关键 Ability 的伪代码骨架**，以及 **UI 组件映射表（Compose → ArkUI）**。

---

## 9. 已补充的 ArkTS 代码模板（本仓库内）

为便于直接复用/二次开发，仓库已新增 `harmonyos_next/` 目录，包含以下可运行的 ArkTS 代码骨架（UI、自动化、输入法、数据与网络模块），可作为 HarmonyOS Next 6.0.2 的工程起点：

- `entry/`：主 UIAbility 与 ArkUI 页面（含 Tabs + 聊天页 + 设置页）。【F:harmonyos_next/entry/src/main/ets/entryability/MainAbility.ets†L1-L7】【F:harmonyos_next/entry/src/main/ets/pages/MainPage.ets†L1-L157】
- `feature_automation/`：Accessibility 扩展与动作解析执行器（ActionExecutor）。【F:harmonyos_next/feature_automation/src/main/ets/accessibility/AutoGLMAccessibilityExt.ets†L1-L56】【F:harmonyos_next/feature_automation/src/main/ets/action/ActionExecutor.ets†L1-L104】
- `feature_ime/`：输入法扩展能力骨架（InputMethodExtensionAbility）。【F:harmonyos_next/feature_ime/src/main/ets/ime/AutoGLMInputMethodExt.ets†L1-L14】
- `common_data/`：配置持久化与对话数据存储骨架。【F:harmonyos_next/common_data/src/main/ets/preferences/SettingsStore.ets†L1-L51】【F:harmonyos_next/common_data/src/main/ets/database/ConversationStore.ets†L1-L40】
- `common_network/`：模型请求封装与响应解析（ModelClient）。【F:harmonyos_next/common_network/src/main/ets/client/ModelClient.ets†L1-L80】
