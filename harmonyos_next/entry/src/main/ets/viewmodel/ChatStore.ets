import { ModelClient } from '../../../common_network/src/main/ets/client/ModelClient';
import { ActionExecutor } from '../../../feature_automation/src/main/ets/action/ActionExecutor';
import { ScreenshotService } from '../../../feature_automation/src/main/ets/screenshot/ScreenshotService';
import { SettingsStore } from '../../../common_data/src/main/ets/preferences/SettingsStore';

export interface ChatMessage {
  id: string;
  role: 'USER' | 'ASSISTANT';
  content: string;
  thinking?: string;
  action?: string;
  timestamp: number;
}

export class ChatStore {
  messages: ChatMessage[] = [];
  isLoading: boolean = false;
  isPaused: boolean = false;
  currentApp?: string;
  taskCompletedMessage?: string;

  private readonly modelClient: ModelClient;
  private readonly actionExecutor: ActionExecutor;
  private readonly screenshotService: ScreenshotService;
  private readonly settingsStore: SettingsStore;

  constructor() {
    this.settingsStore = new SettingsStore();
    this.modelClient = new ModelClient(this.settingsStore);
    this.actionExecutor = new ActionExecutor();
    this.screenshotService = new ScreenshotService();
  }

  async sendPrompt(prompt: string): Promise<void> {
    if (this.isLoading) {
      return;
    }
    this.isLoading = true;
    this.taskCompletedMessage = undefined;
    this.messages.push({
      id: this.createId(),
      role: 'USER',
      content: prompt,
      timestamp: Date.now()
    });

    const screenshot = await this.screenshotService.capture();
    const response = await this.modelClient.request(prompt, screenshot, this.currentApp);
    this.messages.push({
      id: this.createId(),
      role: 'ASSISTANT',
      content: response.action,
      thinking: response.thinking,
      action: response.action,
      timestamp: Date.now()
    });

    await this.actionExecutor.execute(response.action);
    this.isLoading = false;
  }

  stopTask(): void {
    this.isPaused = false;
    this.isLoading = false;
  }

  togglePause(): void {
    if (!this.isLoading) {
      return;
    }
    this.isPaused = !this.isPaused;
  }

  private createId(): string {
    return `${Date.now()}-${Math.random().toString(16).slice(2)}`;
  }
}
