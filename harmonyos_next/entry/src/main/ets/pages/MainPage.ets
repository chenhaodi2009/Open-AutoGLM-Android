import router from '@ohos.router';
import { ChatStore } from '../viewmodel/ChatStore';
import { AppsStore } from '../viewmodel/AppsStore';
import { SettingsViewModel } from '../viewmodel/SettingsViewModel';
import { Routes } from '../router/Routes';

@Entry
@Component
struct MainPage {
  @State private selectedIndex: number = 0;
  @State private messageInput: string = '';
  private readonly chatStore: ChatStore = new ChatStore();
  private readonly appsStore: AppsStore = new AppsStore();
  private readonly settingsViewModel: SettingsViewModel = new SettingsViewModel();

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          this.buildChatPage();
        }.tabBar('首页');
        TabContent() {
          AppsPage({ store: this.appsStore });
        }.tabBar('应用');
        TabContent() {
          PromptLogPage();
        }.tabBar('日志');
        TabContent() {
          SettingsPage({ viewModel: this.settingsViewModel });
        }.tabBar('设置');
      }
      .onChange((index: number) => {
        this.selectedIndex = index;
      });
    }
    .padding(16);
  }

  private buildChatPage() {
    Column() {
      Text('AutoGLM HarmonyOS').fontSize(20).fontWeight(FontWeight.Bold);
      List() {
        ForEach(this.chatStore.messages, (message) => {
          ListItem() {
            Column() {
              Text(message.role === 'USER' ? '我' : '助手')
                .fontSize(12)
                .fontColor(message.role === 'USER' ? '#1976D2' : '#2E7D32');
              Text(message.content).fontSize(14);
              if (message.thinking) {
                Text(message.thinking).fontSize(12).fontColor('#666666');
              }
            }
            .padding(8)
            .backgroundColor('#F5F5F5')
            .borderRadius(8);
          }
        });
      }
      .layoutWeight(1);

      Row() {
        TextInput({ placeholder: '输入任务描述', text: this.messageInput })
          .onChange((value: string) => {
            this.messageInput = value;
          })
          .layoutWeight(1)
          .margin({ right: 8 });
        Button('发送').onClick(async () => {
          if (this.messageInput.trim().length === 0) {
            return;
          }
          const prompt = this.messageInput;
          this.messageInput = '';
          await this.chatStore.sendPrompt(prompt);
        });
      }
      .margin({ top: 8 });
    }
    .layoutWeight(1);
  }
}

@Component
struct AppsPage {
  store: AppsStore;

  build() {
    Column() {
      Text('应用列表').fontSize(18).fontWeight(FontWeight.Bold);
      List() {
        ForEach(this.store.apps, (app) => {
          ListItem() {
            Row() {
              Text(app.label).layoutWeight(1);
              Toggle({ type: ToggleType.Switch, isOn: app.enabled })
                .onChange((value: boolean) => {
                  this.store.toggleApp(app.bundleName, value);
                });
            }
            .padding(8);
          }
        });
      }
      .layoutWeight(1);
    }
  }
}

@Component
struct PromptLogPage {
  build() {
    Column() {
      Text('Prompt 日志').fontSize(18).fontWeight(FontWeight.Bold);
      Text('在这里展示模型请求与响应日志。');
    }
  }
}

@Component
struct SettingsPage {
  viewModel: SettingsViewModel;

  build() {
    Column() {
      Text('设置').fontSize(18).fontWeight(FontWeight.Bold);
      TextInput({ placeholder: 'API Key', text: this.viewModel.apiKey })
        .onChange((value: string) => { this.viewModel.apiKey = value; });
      TextInput({ placeholder: 'Base URL', text: this.viewModel.baseUrl })
        .onChange((value: string) => { this.viewModel.baseUrl = value; });
      TextInput({ placeholder: 'Model Name', text: this.viewModel.modelName })
        .onChange((value: string) => { this.viewModel.modelName = value; });
      Button('保存设置')
        .margin({ top: 12 })
        .onClick(async () => {
          await this.viewModel.save();
        });
      Button('模型配置')
        .margin({ top: 8 })
        .onClick(() => {
          router.pushUrl({ url: Routes.MODEL_CONFIG });
        });
    }
  }
}
