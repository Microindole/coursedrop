import { TransferTask } from '../../models/TransferTask';

export interface TransferTaskRepository {
  listBySession(sessionId: string): TransferTask[];
  listAll(): TransferTask[];
  findById(id: string): TransferTask | undefined;
  save(task: TransferTask): void;
}

export class RuntimeTransferTaskRepository implements TransferTaskRepository {
  private tasks: TransferTask[] = [];

  listBySession(sessionId: string): TransferTask[] {
    return this.copyTasks(this.tasks.filter((task) => task.sessionId === sessionId));
  }

  listAll(): TransferTask[] {
    return this.copyTasks(this.tasks);
  }

  findById(id: string): TransferTask | undefined {
    const task = this.tasks.find((next) => next.id === id);
    if (task === undefined) {
      return undefined;
    }
    return this.copyTask(task);
  }

  save(task: TransferTask): void {
    const nextTask = this.copyTask(task);
    const index = this.tasks.findIndex((next) => next.id === task.id);
    if (index < 0) {
      this.tasks.push(nextTask);
      return;
    }
    this.tasks[index] = nextTask;
  }

  private copyTasks(source: TransferTask[]): TransferTask[] {
    const tasks: TransferTask[] = [];
    source.forEach((task: TransferTask) => {
      tasks.push(this.copyTask(task));
    });
    return tasks;
  }

  private copyTask(task: TransferTask): TransferTask {
    return {
      id: task.id,
      itemId: task.itemId,
      sessionId: task.sessionId,
      deviceId: task.deviceId,
      direction: task.direction,
      status: task.status,
      networkMode: task.networkMode,
      progress: task.progress,
      speedBytesPerSecond: task.speedBytesPerSecond,
      errorMessage: task.errorMessage,
      startedAt: task.startedAt,
      completedAt: task.completedAt
    };
  }
}
