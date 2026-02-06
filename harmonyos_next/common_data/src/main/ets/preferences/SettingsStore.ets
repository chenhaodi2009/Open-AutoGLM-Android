import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

export interface SettingsData {
  apiKey: string;
  baseUrl: string;
  modelName: string;
  inputMode: number;
}

export class SettingsStore {
  private prefs?: preferences.Preferences;
  private readonly inMemory: SettingsData = {
    apiKey: '',
    baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
    modelName: 'autoglm-phone',
    inputMode: 0
  };

  constructor(context?: common.Context) {
    if (context) {
      preferences.getPreferences(context, 'settings').then((prefs) => {
        this.prefs = prefs;
      }).catch(() => {
        this.prefs = undefined;
      });
    }
  }

  async load(): Promise<SettingsData> {
    if (!this.prefs) {
      return { ...this.inMemory };
    }
    return {
      apiKey: await this.prefs.get('apiKey', this.inMemory.apiKey) as string,
      baseUrl: await this.prefs.get('baseUrl', this.inMemory.baseUrl) as string,
      modelName: await this.prefs.get('modelName', this.inMemory.modelName) as string,
      inputMode: await this.prefs.get('inputMode', this.inMemory.inputMode) as number
    };
  }

  async save(data: SettingsData): Promise<void> {
    if (!this.prefs) {
      Object.assign(this.inMemory, data);
      return;
    }
    await this.prefs.put('apiKey', data.apiKey);
    await this.prefs.put('baseUrl', data.baseUrl);
    await this.prefs.put('modelName', data.modelName);
    await this.prefs.put('inputMode', data.inputMode);
    await this.prefs.flush();
  }
}
