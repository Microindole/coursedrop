import { appPreferencesStore } from '../../common/AppPreferencesStore';
import { AppSettings, DefaultAppSettings } from './SettingsModels';

const KEY_SETTINGS: string = 'settings.app';

export interface SettingsRepository {
  get(): AppSettings;
  save(settings: AppSettings): void;
}

export class PreferencesSettingsRepository implements SettingsRepository {
  get(): AppSettings {
    const defaults = DefaultAppSettings.create();
    const jsonText = appPreferencesStore.getString(KEY_SETTINGS, '');
    if (jsonText.length === 0) {
      return defaults;
    }
    try {
      const settings = JSON.parse(jsonText) as AppSettings;
      return {
        e2eeEnabled: settings.e2eeEnabled,
        lanFirstEnabled: settings.lanFirstEnabled,
        defaultExpireHours: settings.defaultExpireHours,
        cachePolicy: settings.cachePolicy
      };
    } catch (error) {
      console.error(`[CourseDrop] load settings failed: ${String(error)}`);
      return defaults;
    }
  }

  save(settings: AppSettings): void {
    appPreferencesStore.putString(KEY_SETTINGS, JSON.stringify(settings));
  }
}
