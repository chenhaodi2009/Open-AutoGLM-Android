import AccessibilityExtensionAbility from '@ohos.application.AccessibilityExtensionAbility';

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
    console.info(`tap at (${x}, ${y})`);
  }

  static swipe(x1: number, y1: number, x2: number, y2: number): void {
    const instance = AutoGLMAccessibilityExt.instance;
    if (!instance) {
      console.warn('Accessibility extension not ready');
      return;
    }
    console.info(`swipe from (${x1}, ${y1}) to (${x2}, ${y2})`);
  }

  static back(): void {
    const instance = AutoGLMAccessibilityExt.instance;
    if (!instance) {
      console.warn('Accessibility extension not ready');
      return;
    }
    console.info('perform back');
  }

  static home(): void {
    const instance = AutoGLMAccessibilityExt.instance;
    if (!instance) {
      console.warn('Accessibility extension not ready');
      return;
    }
    console.info('perform home');
  }

  static inputText(text: string): void {
    const instance = AutoGLMAccessibilityExt.instance;
    if (!instance) {
      console.warn('Accessibility extension not ready');
      return;
    }
    console.info(`input text: ${text}`);
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
