import http from '@ohos.net.http';
import image from '@ohos.multimedia.image';
import { SettingsStore } from '../../../common_data/src/main/ets/preferences/SettingsStore';
import { ScreenshotService } from '../../../feature_automation/src/main/ets/screenshot/ScreenshotService';

export interface ModelResponse {
  thinking: string;
  action: string;
}

interface ChatRequest {
  model: string;
  messages: Array<{ role: string; content: Array<{ type: string; text?: string; image_url?: { url: string } }> }>;
  max_tokens: number;
  temperature: number;
  top_p: number;
  stream: boolean;
}

export class ModelClient {
  private readonly settingsStore: SettingsStore;
  private readonly screenshotService: ScreenshotService;

  constructor(settingsStore: SettingsStore) {
    this.settingsStore = settingsStore;
    this.screenshotService = new ScreenshotService();
  }

  async request(prompt: string, screenshot: image.PixelMap | undefined, currentApp?: string): Promise<ModelResponse> {
    const settings = await this.settingsStore.load();
    const baseUrl = this.ensureTrailingSlash(settings.baseUrl);
    const requestUrl = `${baseUrl}chat/completions`;

    const contentItems: Array<{ type: string; text?: string; image_url?: { url: string } }> = [];
    if (screenshot) {
      const base64 = await this.screenshotService.toBase64(screenshot, 80);
      contentItems.push({
        type: 'image_url',
        image_url: { url: `data:image/jpeg;base64,${base64}` }
      });
    }
    contentItems.push({ type: 'text', text: `${prompt}\n\n${this.buildScreenInfo(currentApp)}` });

    const body: ChatRequest = {
      model: settings.modelName,
      messages: [{ role: 'user', content: contentItems }],
      max_tokens: 3000,
      temperature: 0.0,
      top_p: 0.85,
      stream: false
    };

    const client = http.createHttp();
    const response = await client.request(requestUrl, {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${settings.apiKey || 'EMPTY'}`
      },
      extraData: JSON.stringify(body)
    });

    const payload = JSON.parse(response.result as string);
    const content = payload.choices?.[0]?.message?.content ?? '';
    return this.parseResponse(content);
  }

  private buildScreenInfo(currentApp?: string): string {
    return JSON.stringify({ current_app: currentApp || 'Unknown' });
  }

  private parseResponse(content: string): ModelResponse {
    let thinking = '';
    let action = content.trim();
    if (content.includes('<answer>')) {
      const parts = content.split('<answer>');
      thinking = parts[0].replace('<think>', '').replace('</think>', '').trim();
      action = parts[1].replace('</answer>', '').trim();
    }
    return { thinking, action };
  }

  private ensureTrailingSlash(url: string): string {
    return url.endsWith('/') ? url : `${url}/`;
  }
}
