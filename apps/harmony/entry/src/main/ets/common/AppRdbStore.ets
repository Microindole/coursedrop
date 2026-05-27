import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppRuntimeContext } from './AppRuntimeContext';

const STORE_NAME: string = 'CourseDrop.db';

export class AppRdbStore {
  private store?: relationalStore.RdbStore;
  private opening: boolean = false;

  getStore(): relationalStore.RdbStore | undefined {
    if (this.store !== undefined) {
      return this.store;
    }
    this.open();
    return this.store;
  }

  open(): void {
    if (this.store !== undefined || this.opening) {
      return;
    }
    const context = AppRuntimeContext.getContext();
    if (context === undefined) {
      console.error('[CourseDrop] RDB context is not ready');
      return;
    }
    this.opening = true;
    const config: relationalStore.StoreConfig = {
      name: STORE_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    relationalStore.getRdbStore(context, config, (err: BusinessError, store: relationalStore.RdbStore) => {
      this.opening = false;
      if (err) {
        console.error(`[CourseDrop] open RDB failed: ${err.code}, ${err.message}`);
        return;
      }
      this.store = store;
    });
  }
}

export const appRdbStore = new AppRdbStore();
