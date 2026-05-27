import { TransferItemType } from '../../models/CommonTypes';
import { LocalFileEntry } from '../../models/LocalFileEntry';
import { FileImportService } from './FileImportService';
import { FilePickerService } from './FilePickerService';
import { CourseDropFileStore } from '../local/CourseDropFileStore';
import { FileSystemService } from './FileSystemService';
import { LocalFileIndexRepository } from '../local/LocalFileIndexRepository';

export interface LocalFileImportResult {
  success: boolean;
  message: string;
  importedCount: number;
}

export class LocalFileImportWorkflow {
  private filePickerService: FilePickerService;
  private fileImportService: FileImportService;
  private fileStore: CourseDropFileStore;
  private fileSystemService: FileSystemService;
  private indexRepository: LocalFileIndexRepository;

  constructor(
    filePickerService: FilePickerService,
    fileImportService: FileImportService,
    fileStore: CourseDropFileStore,
    fileSystemService: FileSystemService,
    indexRepository: LocalFileIndexRepository
  ) {
    this.filePickerService = filePickerService;
    this.fileImportService = fileImportService;
    this.fileStore = fileStore;
    this.fileSystemService = fileSystemService;
    this.indexRepository = indexRepository;
  }

  async importFiles(typeHint?: TransferItemType): Promise<LocalFileImportResult> {
    try {
      const files = await this.filePickerService.pickFiles(typeHint);
      if (files.length === 0) {
        return {
          success: false,
          message: '未选择文件',
          importedCount: 0
        };
      }
      let importedCount = 0;
      for (let index = 0; index < files.length; index += 1) {
        await this.fileImportService.importPickedFile(files[index]);
        importedCount += 1;
      }
      return {
        success: importedCount > 0,
        message: `已导入 ${importedCount} 个文件`,
        importedCount: importedCount
      };
    } catch (error) {
      return {
        success: false,
        message: String(error),
        importedCount: 0
      };
    }
  }

  createDebugTextFile(): LocalFileImportResult {
    try {
      const libraryRoot = this.fileStore.libraryRoot();
      if (libraryRoot.length === 0) {
        throw new Error('App 文件目录未初始化');
      }
      const displayName = `cd-test-${Date.now()}.txt`;
      const content = `hello coursedrop\ncreatedAt=${new Date().toISOString()}\n`;
      console.info(`[CourseDrop] create debug file in ${libraryRoot}`);
      const createdFile = this.fileSystemService.writeTextFile(libraryRoot, displayName, content);
      const entry: LocalFileEntry = {
        id: `local-${Date.now()}`,
        displayName: displayName,
        type: 'TEXT',
        contentType: 'text/plain',
        sizeBytes: createdFile.sizeBytes,
        localUri: createdFile.uri,
        shareCount: 0,
        remoteCached: false,
        encrypted: false
      };
      this.indexRepository.save(entry);
      console.info(`[CourseDrop] debug file indexed ${entry.id}, ${createdFile.path}`);
      return {
        success: true,
        message: `已生成测试文件：${displayName} · ${createdFile.sizeBytes} bytes`,
        importedCount: 1
      };
    } catch (error) {
      return {
        success: false,
        message: `生成测试文件失败：${String(error)}`,
        importedCount: 0
      };
    }
  }
}
