import { TransferItemType } from '../../models/CommonTypes';

export interface PickedFile {
  uri: string;
  displayName: string;
  contentType: string;
  sizeBytes: number;
  type: TransferItemType;
}

export interface FileImportPlan {
  sourceUri: string;
  displayName: string;
  contentType: string;
  sizeBytes: number;
  type: TransferItemType;
  targetDirectory: string;
}

export interface FileImportResult {
  localFileId: string;
  localUri: string;
}
