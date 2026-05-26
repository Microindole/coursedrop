import { PickedFile } from './FileModels';

export interface FilePickerService {
  pickFiles(): Promise<PickedFile[]>;
}

export class SystemFilePickerService implements FilePickerService {
  async pickFiles(): Promise<PickedFile[]> {
    throw new Error('系统文件选择器尚未接入');
  }
}
