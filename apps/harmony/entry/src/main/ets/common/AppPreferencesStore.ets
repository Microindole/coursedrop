import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppRuntimeContext } from './AppRuntimeContext';

const PREFERENCES_NAME: string = 'CourseDropPreferences';

export class AppPreferencesStore {
  private preference?: preferences.Preferences;

  getString(key: string, defaultValue: string): string {
    const preference = this.ensurePreference();
    if (preference === undefined) {
      return defaultValue;
    }
    try {
      const value = preference.getSync(key, defaultValue);
      if (typeof value === 'string') {
        return value;
      }
      return defaultValue;
    } catch (error) {
      console.error(`[CourseDrop] preferences getString failed: ${String(error)}`);
      return defaultValue;
    }
  }

  putString(key: string, value: string): void {
    const preference = this.ensurePreference();
    if (preference === undefined) {
      return;
    }
    try {
      preference.putSync(key, value);
      this.flush(preference);
    } catch (error) {
      console.error(`[CourseDrop] preferences putString failed: ${String(error)}`);
    }
  }

  getBoolean(key: string, defaultValue: boolean): boolean {
    const preference = this.ensurePreference();
    if (preference === undefined) {
      return defaultValue;
    }
    try {
      const value = preference.getSync(key, defaultValue);
      if (typeof value === 'boolean') {
        return value;
      }
      return defaultValue;
    } catch (error) {
      console.error(`[CourseDrop] preferences getBoolean failed: ${String(error)}`);
      return defaultValue;
    }
  }

  putBoolean(key: string, value: boolean): void {
    const preference = this.ensurePreference();
    if (preference === undefined) {
      return;
    }
    try {
      preference.putSync(key, value);
      this.flush(preference);
    } catch (error) {
      console.error(`[CourseDrop] preferences putBoolean failed: ${String(error)}`);
    }
  }

  private ensurePreference(): preferences.Preferences | undefined {
    if (this.preference !== undefined) {
      return this.preference;
    }
    const context = AppRuntimeContext.getContext();
    if (context === undefined) {
      console.error('[CourseDrop] preferences context is not ready');
      return undefined;
    }
    try {
      this.preference = preferences.getPreferencesSync(context, { name: PREFERENCES_NAME });
      return this.preference;
    } catch (error) {
      console.error(`[CourseDrop] preferences open failed: ${String(error)}`);
      return undefined;
    }
  }

  private flush(preference: preferences.Preferences): void {
    preference.flush((err: BusinessError) => {
      if (err) {
        console.error(`[CourseDrop] preferences flush failed: ${err.code}, ${err.message}`);
      }
    });
  }
}

export const appPreferencesStore = new AppPreferencesStore();
