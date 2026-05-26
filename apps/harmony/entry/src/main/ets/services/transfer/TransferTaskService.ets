import { NetworkMode } from '../../models/CommonTypes';
import { TransferDirection, TransferTask } from '../../models/TransferTask';
import { TransferTaskRepository } from './TransferTaskRepository';

export interface TransferProgress {
  progress: number;
  speedBytesPerSecond?: number;
}

export interface TransferTaskService {
  createTask(itemId: string, direction: TransferDirection, networkMode: NetworkMode, sessionId?: string): TransferTask;
  start(taskId: string): TransferTask;
  updateProgress(taskId: string, progress: TransferProgress): TransferTask;
  complete(taskId: string): TransferTask;
  fail(taskId: string, message: string): TransferTask;
  cancel(taskId: string): TransferTask;
  listAll(): TransferTask[];
  listBySession(sessionId: string): TransferTask[];
}

export class DefaultTransferTaskService implements TransferTaskService {
  private repository: TransferTaskRepository;

  constructor(repository: TransferTaskRepository) {
    this.repository = repository;
  }

  createTask(itemId: string, direction: TransferDirection, networkMode: NetworkMode, sessionId?: string): TransferTask {
    const task: TransferTask = {
      id: `task-${Date.now()}`,
      itemId: itemId,
      sessionId: sessionId,
      direction: direction,
      status: 'PENDING',
      networkMode: networkMode,
      progress: 0
    };
    this.repository.save(task);
    return task;
  }

  start(taskId: string): TransferTask {
    const task = this.requireTask(taskId);
    task.status = 'RUNNING';
    task.startedAt = new Date().toISOString();
    this.repository.save(task);
    return task;
  }

  updateProgress(taskId: string, progress: TransferProgress): TransferTask {
    const task = this.requireTask(taskId);
    if (task.status !== 'RUNNING') {
      throw new Error('只有运行中的任务可以更新进度');
    }
    task.progress = this.normalizeProgress(progress.progress);
    task.speedBytesPerSecond = progress.speedBytesPerSecond;
    this.repository.save(task);
    return task;
  }

  complete(taskId: string): TransferTask {
    const task = this.requireTask(taskId);
    task.status = 'COMPLETED';
    task.progress = 100;
    task.completedAt = new Date().toISOString();
    this.repository.save(task);
    return task;
  }

  fail(taskId: string, message: string): TransferTask {
    const task = this.requireTask(taskId);
    task.status = 'FAILED';
    task.errorMessage = message;
    task.completedAt = new Date().toISOString();
    this.repository.save(task);
    return task;
  }

  cancel(taskId: string): TransferTask {
    const task = this.requireTask(taskId);
    task.status = 'CANCELED';
    task.completedAt = new Date().toISOString();
    this.repository.save(task);
    return task;
  }

  listAll(): TransferTask[] {
    return this.repository.listAll();
  }

  listBySession(sessionId: string): TransferTask[] {
    return this.repository.listBySession(sessionId);
  }

  private requireTask(taskId: string): TransferTask {
    const task = this.repository.findById(taskId);
    if (task === undefined) {
      throw new Error(`传输任务不存在：${taskId}`);
    }
    return task;
  }

  private normalizeProgress(progress: number): number {
    if (progress < 0) {
      return 0;
    }
    if (progress > 100) {
      return 100;
    }
    return progress;
  }
}
