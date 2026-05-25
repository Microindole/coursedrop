import { TransferTask } from '../../models/TransferTask';

export interface TransferTaskRepository {
  listBySession(sessionId: string): TransferTask[];
  listAll(): TransferTask[];
}

export class LocalTransferTaskRepository implements TransferTaskRepository {
  private tasks: TransferTask[] = [];

  listBySession(sessionId: string): TransferTask[] {
    return this.tasks.filter((task) => task.sessionId === sessionId);
  }

  listAll(): TransferTask[] {
    return this.tasks;
  }
}
