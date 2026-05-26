import { TransferItemType } from '../../models/CommonTypes';
import { FileImportService, FilePickerService, PickedFile } from '../file';
import { ShareOperationResult, ShareService } from './ShareService';

export interface ShareDraftWorkflow {
  pickAndAttachFiles(sessionId: string, typeHint?: TransferItemType): Promise<ShareOperationResult>;
}

export class DefaultShareDraftWorkflow implements ShareDraftWorkflow {
  private filePickerService: FilePickerService;
  private fileImportService: FileImportService;
  private shareService: ShareService;

  constructor(
    filePickerService: FilePickerService,
    fileImportService: FileImportService,
    shareService: ShareService
  ) {
    this.filePickerService = filePickerService;
    this.fileImportService = fileImportService;
    this.shareService = shareService;
  }

  async pickAndAttachFiles(sessionId: string, _typeHint?: TransferItemType): Promise<ShareOperationResult> {
    try {
      const files = await this.filePickerService.pickFiles();
      if (files.length === 0) {
        return {
          success: false,
          message: '未选择文件'
        };
      }
      let attachedCount = 0;
      for (let index = 0; index < files.length; index += 1) {
        const file = files[index];
        if (this.acceptsType(file, _typeHint)) {
          const importResult = await this.fileImportService.importPickedFile(file);
          const attachResult = this.shareService.attachLocalFile(sessionId, importResult.localFileId);
          if (attachResult.success) {
            attachedCount += 1;
          }
        }
      }
      return {
        success: attachedCount > 0,
        message: attachedCount > 0 ? `已加入 ${attachedCount} 个文件` : '没有文件加入分享'
      };
    } catch (error) {
      return {
        success: false,
        message: String(error)
      };
    }
  }

  private acceptsType(file: PickedFile, typeHint?: TransferItemType): boolean {
    if (typeHint === undefined) {
      return true;
    }
    return file.type === typeHint;
  }
}
