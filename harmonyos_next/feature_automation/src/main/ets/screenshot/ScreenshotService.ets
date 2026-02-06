import image from '@ohos.multimedia.image';

export class ScreenshotService {
  async capture(): Promise<image.PixelMap | undefined> {
    console.info('capture screenshot placeholder');
    return undefined;
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
