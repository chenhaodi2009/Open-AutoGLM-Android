import InputMethodExtensionAbility from '@ohos.application.InputMethodExtensionAbility';
import inputMethod from '@ohos.inputMethod';

export default class AutoGLMInputMethodExt extends InputMethodExtensionAbility {
  onCreate(): void {
    console.info('AutoGLM IME created');
  }

  onDestroy(): void {
    console.info('AutoGLM IME destroyed');
  }

  createInputWindow(): inputMethod.InputWindow {
    return this.context.createWindow('AutoGLMIME');
  }
}
