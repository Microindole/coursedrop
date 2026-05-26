import { DecryptionPlan, DecryptionResult, EncryptionPlan, EncryptionResult } from './CryptoModels';

export interface EncryptionService {
  encryptFile(plan: EncryptionPlan): Promise<EncryptionResult>;
  decryptFile(plan: DecryptionPlan): Promise<DecryptionResult>;
}

export class CourseDropEncryptionService implements EncryptionService {
  async encryptFile(plan: EncryptionPlan): Promise<EncryptionResult> {
    throw new Error(`端到端加密尚未接入：${plan.algorithm}`);
  }

  async decryptFile(plan: DecryptionPlan): Promise<DecryptionResult> {
    throw new Error(`端到端解密尚未接入：${plan.algorithm}`);
  }
}
