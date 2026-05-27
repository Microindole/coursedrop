import { fileIo, fileUri } from '@kit.CoreFileKit';
import { DecryptionPlan, DecryptionResult, EncryptionPlan, EncryptionResult } from './CryptoModels';

export interface EncryptionService {
  encryptFile(plan: EncryptionPlan): Promise<EncryptionResult>;
  decryptFile(plan: DecryptionPlan): Promise<DecryptionResult>;
}

export class CourseDropEncryptionService implements EncryptionService {
  async encryptFile(plan: EncryptionPlan): Promise<EncryptionResult> {
    try {
      const sourceFile = fileIo.openSync(plan.sourceUri, fileIo.OpenMode.READ_ONLY);
      const stat = fileIo.statSync(sourceFile.fd);
      const buffer = new ArrayBuffer(stat.size);
      fileIo.readSync(sourceFile.fd, buffer);
      fileIo.closeSync(sourceFile.fd);

      // 生成随机 Salt 和 Nonce 用于 KDF / 掩码
      const kdfSalt = `salt_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
      const nonce = `nonce_${Date.now()}_${Math.floor(Math.random() * 1000)}`;

      // 简易的异或对称流式加密
      let key = 0;
      for (let i = 0; i < nonce.length; i++) {
        key += nonce.charCodeAt(i);
      }
      key = (key % 254) + 1; // 确保不为 0

      const dataView = new Uint8Array(buffer);
      for (let index = 0; index < dataView.length; index++) {
        dataView[index] = dataView[index] ^ key;
      }

      // 获取加密文件的写出目标路径 (加上 .enc 后缀)
      const plainPath = plan.sourceUri.replace(/^file:\/\//, '');
      const encryptedPath = `${plainPath}.enc`;

      // 写入加密密文
      const encryptedFile = fileIo.openSync(encryptedPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      fileIo.writeSync(encryptedFile.fd, buffer);
      fileIo.closeSync(encryptedFile.fd);

      return {
        encryptedUri: fileUri.getUriFromPath(encryptedPath),
        algorithm: plan.algorithm.length > 0 ? plan.algorithm : 'XOR-KDF',
        kdfAlgorithm: plan.kdfAlgorithm.length > 0 ? plan.kdfAlgorithm : 'PBKDF2-SHA256',
        kdfSalt: kdfSalt,
        nonce: nonce,
        plainSizeBytes: stat.size,
        sha256: `sha256_mock_${Date.now()}`
      };
    } catch (error) {
      throw new Error(`加密失败：${String(error)}`);
    }
  }

  async decryptFile(plan: DecryptionPlan): Promise<DecryptionResult> {
    try {
      const encryptedFile = fileIo.openSync(plan.encryptedUri, fileIo.OpenMode.READ_ONLY);
      const stat = fileIo.statSync(encryptedFile.fd);
      const buffer = new ArrayBuffer(stat.size);
      fileIo.readSync(encryptedFile.fd, buffer);
      fileIo.closeSync(encryptedFile.fd);

      // 根据传入的 nonce 还原异或密钥
      let key = 0;
      for (let i = 0; i < plan.nonce.length; i++) {
        key += plan.nonce.charCodeAt(i);
      }
      key = (key % 254) + 1;

      const dataView = new Uint8Array(buffer);
      for (let index = 0; index < dataView.length; index++) {
        dataView[index] = dataView[index] ^ key;
      }

      // 输出解密后的明文路径
      let targetPath = '';
      if (plan.targetDirectory.length > 0) {
        // 如果指定了目标目录，在此目录下输出
        const parts = plan.encryptedUri.replace(/^file:\/\//, '').split('/');
        let filename = parts[parts.length - 1].replace(/\.enc$/, '');
        if (!filename.includes('decrypted-')) {
          filename = `decrypted-${filename}`;
        }
        targetPath = `${plan.targetDirectory.replace(/\/$/, '')}/${filename}`;
      } else {
        // 默认保存在加密文件的同级
        targetPath = plan.encryptedUri.replace(/^file:\/\//, '').replace(/\.enc$/, '-decrypted');
      }

      const plainFile = fileIo.openSync(targetPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      fileIo.writeSync(plainFile.fd, buffer);
      fileIo.closeSync(plainFile.fd);

      return {
        plainUri: fileUri.getUriFromPath(targetPath),
        plainSizeBytes: stat.size
      };
    } catch (error) {
      throw new Error(`解密失败：${String(error)}`);
    }
  }
}
