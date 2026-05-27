import camera from '@ohos.multimedia.camera';
import cameraPicker from '@ohos.multimedia.cameraPicker';
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
    const profile = new cameraPicker.PickerProfile();
    profile.cameraPosition = camera.CameraPosition.CAMERA_POSITION_BACK;
    const mediaTypes: cameraPicker.PickerMediaType[] = [cameraPicker.PickerMediaType.PHOTO];
    const result = await cameraPicker.pick(context, mediaTypes, profile);
    return {
      success: false,
      message: '已打开系统相机，但当前 SDK 未提供通用二维码解码 API，请使用调试文本或系统浏览器扫码完成联调',
      rawText: '',
      capturedUri: result.resultUri
    };
  }
}
