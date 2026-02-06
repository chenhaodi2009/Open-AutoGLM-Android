import image from '@ohos.multimedia.image';
import screenshot from '@ohos.screenshot';

export class ScreenshotService {
  async capture(): Promise<image.PixelMap | undefined> {
    try {
      const pixelMap = await screenshot.takeScreenshot();
      return pixelMap;
    } catch (error) {
      console.error(`capture screenshot failed: ${JSON.stringify(error)}`);
      return undefined;
    }
  }

  async toBase64(pixelMap?: image.PixelMap, quality: number = 80): Promise<string> {
    if (!pixelMap) {
      return '';
    }
    const imagePacker = image.createImagePacker();
    const packOpts: image.PackingOption = { format: 'image/jpeg', quality };
    const arrayBuffer = await imagePacker.packing(pixelMap, packOpts);
    return this.arrayBufferToBase64(arrayBuffer);
  }

  private arrayBufferToBase64(buffer: ArrayBuffer): string {
    const bytes = new Uint8Array(buffer);
    let binary = '';
    bytes.forEach((byte) => {
      binary += String.fromCharCode(byte);
    });
    return globalThis.btoa(binary);
  }
}
