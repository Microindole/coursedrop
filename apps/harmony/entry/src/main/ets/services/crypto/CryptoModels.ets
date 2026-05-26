export interface EncryptionPlan {
  sourceUri: string;
  plainSizeBytes: number;
  algorithm: string;
  kdfAlgorithm: string;
}

export interface EncryptionResult {
  encryptedUri: string;
  algorithm: string;
  kdfAlgorithm: string;
  kdfSalt: string;
  nonce: string;
  plainSizeBytes: number;
  sha256: string;
}

export interface DecryptionPlan {
  encryptedUri: string;
  targetDirectory: string;
  algorithm: string;
  kdfAlgorithm: string;
  kdfSalt: string;
  nonce: string;
}

export interface DecryptionResult {
  plainUri: string;
  plainSizeBytes: number;
}
