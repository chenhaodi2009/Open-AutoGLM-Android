import AccessibilityExtensionAbility from '@ohos.application.AccessibilityExtensionAbility';
import accessibility from '@ohos.accessibility';

export class AutoGLMAccessibilityExt extends AccessibilityExtensionAbility {
  private static instance: AutoGLMAccessibilityExt | null = null;

  static getInstance(): AutoGLMAccessibilityExt | null {
    return AutoGLMAccessibilityExt.instance;
  }

  static tap(x: number, y: number): void {
    const instance = AutoGLMAccessibilityExt.instance;
    if (!instance) {
      console.warn('Accessibility extension not ready');
      return;
    }
    const path = new accessibility.GesturePath();
    path.moveTo(x, y);
    accessibility.sendGesture({
      paths: [path],
      duration: 50
    });
  }

  static swipe(x1: number, y1: number, x2: number, y2: number): void {
    const instance = AutoGLMAccessibilityExt.instance;
    if (!instance) {
      console.warn('Accessibility extension not ready');
      return;
    }
    const path = new accessibility.GesturePath();
    path.moveTo(x1, y1);
    path.lineTo(x2, y2);
    accessibility.sendGesture({
      paths: [path],
      duration: 300
    });
  }

  static back(): void {
    const instance = AutoGLMAccessibilityExt.instance;
    if (!instance) {
      console.warn('Accessibility extension not ready');
      return;
    }
    accessibility.sendKeyEvent({ keyCode: accessibility.KeyCode.KEYCODE_BACK });
  }

  static home(): void {
    const instance = AutoGLMAccessibilityExt.instance;
    if (!instance) {
      console.warn('Accessibility extension not ready');
      return;
    }
    accessibility.sendKeyEvent({ keyCode: accessibility.KeyCode.KEYCODE_HOME });
  }

  static inputText(text: string): void {
    const instance = AutoGLMAccessibilityExt.instance;
    if (!instance) {
      console.warn('Accessibility extension not ready');
      return;
    }
    accessibility.sendText(text);
  }

  onConnect(): void {
    AutoGLMAccessibilityExt.instance = this;
    console.info('AutoGLM Accessibility extension connected');
  }

  onDisconnect(): void {
    AutoGLMAccessibilityExt.instance = null;
    console.info('AutoGLM Accessibility extension disconnected');
  }
}
