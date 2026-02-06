import inputMethod from '@ohos.inputMethod';

@Entry
@Component
struct KeyboardPanel {
  @State private inputText: string = '';

  build() {
    Column() {
      Text('AutoGLM 输入法').fontSize(16).fontWeight(FontWeight.Bold);
      TextInput({ placeholder: '输入要提交的文本', text: this.inputText })
        .onChange((value: string) => {
          this.inputText = value;
        })
        .margin({ top: 8 });
      Row() {
        Button('提交文本')
          .margin({ right: 8 })
          .onClick(() => {
            inputMethod.getInputMethodController().insertText(this.inputText);
          });
        Button('切换输入法')
          .onClick(() => {
            inputMethod.getInputMethodController().showInputMethodPicker();
          });
      }
      .margin({ top: 12 });
    }
    .padding(12)
    .backgroundColor('#F5F5F5');
  }
}
