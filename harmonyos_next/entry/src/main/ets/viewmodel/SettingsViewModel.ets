import { SettingsStore } from '../../../common_data/src/main/ets/preferences/SettingsStore';

export class SettingsViewModel {
  apiKey: string = '';
  baseUrl: string = '';
  modelName: string = '';
  inputMode: number = 0;
  accessibilityEnabled: boolean = false;

  private readonly store: SettingsStore;

  constructor() {
    this.store = new SettingsStore();
  }

  async load(): Promise<void> {
    const settings = await this.store.load();
    this.apiKey = settings.apiKey;
    this.baseUrl = settings.baseUrl;
    this.modelName = settings.modelName;
    this.inputMode = settings.inputMode;
  }

  async save(): Promise<void> {
    await this.store.save({
      apiKey: this.apiKey,
      baseUrl: this.baseUrl,
      modelName: this.modelName,
      inputMode: this.inputMode
    });
  }
}
