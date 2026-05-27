import { Room } from '../models/Room';
import { apiClient } from './ApiClient';

export class RoomService {
  async createRoom(name: string): Promise<Room> {
    const body = JSON.stringify({ name: name });
    const responseText = await apiClient.postJson('/api/rooms', body);
    return JSON.parse(responseText) as Room;
  }

  async joinRoom(code: string): Promise<Room> {
    const responseText = await apiClient.postJson(`/api/rooms/${code}/join`, '');
    return JSON.parse(responseText) as Room;
  }
}

export const roomService = new RoomService();
