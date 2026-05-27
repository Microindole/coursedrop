import { PreferencesSettingsRepository } from './SettingsRepository';
import { SettingsService } from './SettingsService';

export type { AppSettings, CachePolicy } from './SettingsModels';
export { DefaultAppSettings } from './SettingsModels';
export type { SettingsRepository } from './SettingsRepository';
export { PreferencesSettingsRepository } from './SettingsRepository';
export { SettingsService } from './SettingsService';

export const settingsService = new SettingsService(new PreferencesSettingsRepository());
