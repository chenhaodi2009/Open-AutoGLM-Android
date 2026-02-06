import { AutoGLMAccessibilityExt } from '../accessibility/AutoGLMAccessibilityExt';

export interface ActionDetail {
  type: string;
  x1?: number;
  y1?: number;
  x2?: number;
  y2?: number;
  text?: string;
}

export interface ExecuteResult {
  success: boolean;
  message?: string;
  actionDetail?: ActionDetail;
}

interface ActionPayload {
  _metadata: string;
  action?: string;
  x?: number;
  y?: number;
  x1?: number;
  y1?: number;
  x2?: number;
  y2?: number;
  text?: string;
  message?: string;
}

export class ActionExecutor {
  async execute(actionText: string): Promise<ExecuteResult> {
    const payload = this.parseAction(actionText);
    if (!payload) {
      return { success: false, message: '无法解析动作' };
    }
    if (payload._metadata === 'finish') {
      return { success: true, message: payload.message || '任务完成' };
    }
    if (payload._metadata !== 'do') {
      return { success: false, message: `未知动作类型: ${payload._metadata}` };
    }

    const action = payload.action || '';
    switch (action) {
      case 'tap':
        if (payload.x !== undefined && payload.y !== undefined) {
          AutoGLMAccessibilityExt.tap(payload.x, payload.y);
          return { success: true, actionDetail: { type: 'tap', x1: payload.x, y1: payload.y } };
        }
        return { success: false, message: 'tap 缺少坐标' };
      case 'swipe':
        if (payload.x1 !== undefined && payload.y1 !== undefined && payload.x2 !== undefined && payload.y2 !== undefined) {
          AutoGLMAccessibilityExt.swipe(payload.x1, payload.y1, payload.x2, payload.y2);
          return {
            success: true,
            actionDetail: { type: 'swipe', x1: payload.x1, y1: payload.y1, x2: payload.x2, y2: payload.y2 }
          };
        }
        return { success: false, message: 'swipe 缺少坐标' };
      case 'back':
        AutoGLMAccessibilityExt.back();
        return { success: true, actionDetail: { type: 'back' } };
      case 'home':
        AutoGLMAccessibilityExt.home();
        return { success: true, actionDetail: { type: 'home' } };
      case 'input':
        if (payload.text) {
          AutoGLMAccessibilityExt.inputText(payload.text);
          return { success: true, actionDetail: { type: 'input', text: payload.text } };
        }
        return { success: false, message: 'input 缺少文本' };
      default:
        return { success: false, message: `未知 action: ${action}` };
    }
  }

  private parseAction(actionText: string): ActionPayload | null {
    const trimmed = actionText.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        return JSON.parse(trimmed) as ActionPayload;
      } catch (error) {
        return null;
      }
    }

    const funcMatch = /(do|finish)\s*\(([^)]+)\)/i.exec(trimmed);
    if (!funcMatch) {
      return null;
    }
    const meta = funcMatch[1].toLowerCase();
    const args = funcMatch[2];
    const payload: ActionPayload = { _metadata: meta };
    args.split(',').forEach(pair => {
      const [keyRaw, valueRaw] = pair.split('=').map(item => item.trim());
      if (!keyRaw || valueRaw === undefined) {
        return;
      }
      const value = valueRaw.replace(/^"|"$/g, '').replace(/^'|'$/g, '');
      if (['x', 'y', 'x1', 'y1', 'x2', 'y2'].includes(keyRaw)) {
        (payload as Record<string, number>)[keyRaw] = Number(value);
      } else {
        (payload as Record<string, string>)[keyRaw] = value;
      }
    });
    return payload;
  }
}
