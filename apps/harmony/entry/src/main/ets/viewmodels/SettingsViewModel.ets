import { AppConfig } from '../common/AppConfig';

export type CachePolicy = 'MANUAL' | 'DAILY' | 'EXPIRED_ONLY';

export class SettingsViewModel {
  serverUrl: string = AppConfig.DEFAULT_SERVER_URL;
  e2eeEnabled: boolean = true;
  lanFirstEnabled: boolean = true;
  defaultExpireHours: string = '24';
  cachePolicy: CachePolicy = 'EXPIRED_ONLY';

  getExpireOptions(): string[] {
    return ['1 小时', '6 小时', '24 小时', '7 天'];
  }

  getCachePolicyLabel(): string {
    if (this.cachePolicy === 'MANUAL') {
      return '手动清理';
    }
    if (this.cachePolicy === 'DAILY') {
      return '每天自动清理';
    }
    return '仅清理过期内容';
  }
}
