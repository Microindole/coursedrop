import { Room } from '../models/Room';
import { apiClient } from './ApiClient';

export class RoomService {
  async createRoom(name: string): Promise<Room> {
    throw new Error(`createRoom is not connected yet: ${name}, ${apiClient.getBaseUrl()}`);
  }

  async joinRoom(code: string): Promise<Room> {
    throw new Error(`joinRoom is not connected yet: ${code}, ${apiClient.getBaseUrl()}`);
  }
}

export const roomService = new RoomService();

