import { ShareSession } from '../../models/ShareSession';

export interface ShareSessionRepository {
  list(): ShareSession[];
  current(): ShareSession;
  save(session: ShareSession): void;
}

export class LocalShareSessionRepository implements ShareSessionRepository {
  private currentSession: ShareSession = this.createDraftSession();
  private sessions: ShareSession[] = [this.currentSession];

  list(): ShareSession[] {
    return this.sessions;
  }

  current(): ShareSession {
    return this.currentSession;
  }

  save(session: ShareSession): void {
    const index = this.sessions.findIndex((next) => next.id === session.id);
    if (index < 0) {
      this.sessions.push(session);
      return;
    }
    this.sessions[index] = session;
    if (this.currentSession.id === session.id) {
      this.currentSession = session;
    }
  }

  private createDraftSession(): ShareSession {
    const createdAt = new Date().toISOString();
    return {
      id: `draft-${Date.now()}`,
      title: '',
      code: '',
      shareUrl: '',
      status: 'DRAFT',
      networkMode: 'LAN',
      expireStatus: 'ACTIVE',
      createdAt: createdAt,
      expiresAt: '',
      itemCount: 0,
      totalSizeBytes: 0,
      encrypted: true,
      items: []
    };
  }
}
