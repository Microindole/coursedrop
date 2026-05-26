import { LocalIdentity } from './IdentityModels';

export interface IdentityRepository {
  get(): LocalIdentity | undefined;
  save(identity: LocalIdentity): void;
}

export class LocalIdentityRepository implements IdentityRepository {
  private identity?: LocalIdentity;

  get(): LocalIdentity | undefined {
    return this.identity;
  }

  save(identity: LocalIdentity): void {
    this.identity = identity;
  }
}
