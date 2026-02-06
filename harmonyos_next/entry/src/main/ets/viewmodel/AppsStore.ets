export interface AppInfo {
  bundleName: string;
  label: string;
  enabled: boolean;
}

export class AppsStore {
  apps: AppInfo[] = [];

  loadApps(): void {
    this.apps = [];
  }

  toggleApp(bundleName: string, enabled: boolean): void {
    this.apps = this.apps.map(app =>
      app.bundleName === bundleName ? { ...app, enabled } : app
    );
  }
}
