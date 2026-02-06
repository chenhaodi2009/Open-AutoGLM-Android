import UIAbility from '@ohos.app.ability.UIAbility';
import Window from '@ohos.window';

export default class MainAbility extends UIAbility {
  onWindowStageCreate(windowStage: Window.WindowStage): void {
    windowStage.setUIContent('pages/MainPage');
  }
}
