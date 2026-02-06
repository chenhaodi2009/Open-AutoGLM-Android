import router from '@ohos.router';

@Entry
@Component
struct ModelConfigPage {
  @State private temperature: number = 0.0;
  @State private topP: number = 0.85;

  build() {
    Column() {
      Text('模型配置').fontSize(18).fontWeight(FontWeight.Bold);
      Text(`温度: ${this.temperature.toFixed(2)}`);
      Slider({ value: this.temperature, min: 0, max: 1 })
        .onChange((value: number) => { this.temperature = value; });
      Text(`TopP: ${this.topP.toFixed(2)}`);
      Slider({ value: this.topP, min: 0, max: 1 })
        .onChange((value: number) => { this.topP = value; });
      Button('返回').margin({ top: 16 }).onClick(() => {
        router.back();
      });
    }
    .padding(16);
  }
}
