import type { AppSettings, CachePolicy } from './SettingsModels';
import { SettingsRepository } from './SettingsRepository';

export class SettingsService {
  private repository: SettingsRepository;

  constructor(repository: SettingsRepository) {
    this.repository = repository;
  }

  getSettings(): AppSettings {
    return this.repository.get();
  }

  updateSecurity(e2eeEnabled: boolean, lanFirstEnabled: boolean): AppSettings {
    const settings = this.repository.get();
    settings.e2eeEnabled = e2eeEnabled;
    settings.lanFirstEnabled = lanFirstEnabled;
    this.repository.save(settings);
    return settings;
  }

  updatePolicies(defaultExpireHours: string, cachePolicy: CachePolicy): AppSettings {
    const settings = this.repository.get();
    settings.defaultExpireHours = defaultExpireHours;
    settings.cachePolicy = cachePolicy;
    this.repository.save(settings);
    return settings;
  }
}
