import { BusinessError } from '@kit.BasicServicesKit';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { AppRuntimeContext } from '../../common/AppRuntimeContext';

export interface CameraScanResult {
  success: boolean;
  message: string;
  rawText: string;
  capturedUri: string;
}

export class CameraScanService {
  async openCamera(): Promise<CameraScanResult> {
    const context = AppRuntimeContext.getContext();
    if (context === undefined) {
      return {
        success: false,
        message: '应用上下文尚未初始化',
        rawText: '',
        capturedUri: ''
      };
    }
    const options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.QR_CODE],
      enableMultiMode: false,
      enableAlbum: true
    };
    try {
      const result = await scanBarcode.startScanForResult(context, options);
      return {
        success: result.originalValue.length > 0,
        message: result.originalValue.length > 0 ? '扫码识别成功' : '未识别到二维码内容',
        rawText: result.originalValue,
        capturedUri: ''
      };
    } catch (error) {
      const businessError = error as BusinessError;
      if (businessError.code === scanCore.ScanErrorCode.SCAN_SERVICE_CANCELED) {
        return {
          success: false,
          message: '扫码已取消',
          rawText: '',
          capturedUri: ''
        };
      }
      return {
        success: false,
        message: `扫码失败：${businessError.message}`,
        rawText: '',
        capturedUri: ''
      };
    }
  }
}
