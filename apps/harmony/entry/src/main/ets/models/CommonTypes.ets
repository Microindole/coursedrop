export type NetworkMode = 'LAN' | 'RELAY' | 'E2EE' | 'OFFLINE';

export type ExpireStatus = 'ACTIVE' | 'EXPIRING_SOON' | 'EXPIRED';

export type TransferItemType = 'FILE' | 'IMAGE' | 'TEXT' | 'LINK';

export interface TimeRange {
  createdAt: string;
  expiresAt: string;
}
