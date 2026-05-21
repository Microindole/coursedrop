import { TransferItem } from '../models/TransferItem';
import { apiClient } from './ApiClient';

export class TransferService {
  async listItems(roomId: string): Promise<TransferItem[]> {
    throw new Error(`listItems is not connected yet: ${roomId}, ${apiClient.getBaseUrl()}`);
  }
}

export const transferService = new TransferService();

