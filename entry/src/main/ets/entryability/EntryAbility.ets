import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import {
  ROUTE, SEED_DOC_MD_POPULATED, SEED_TODO_TEXT, SK, TAB, initializeNotebookPersistence, seedDefault
} from '../model/AppModel';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private targetRoute: string = ROUTE.MAIN;
  private windowStage?: window.WindowStage;

  private stringParameter(want: Want, name: string): string {
    const value = want.parameters?.[name] as string;
    return typeof value === 'string' ? value : '';
  }

  private selectSurface(want: Want): void {
    const surface: string = this.stringParameter(want, 'benchmark_surface');
    this.targetRoute = ROUTE.MAIN;
    if (surface === 'intro') {
      this.targetRoute = ROUTE.INTRO;
    } else if (surface === 'permission') {
      this.targetRoute = ROUTE.PERMISSION;
    } else if (surface === 'settings') {
      this.targetRoute = ROUTE.SETTINGS;
    } else if (surface === 'share_into') {
      this.targetRoute = ROUTE.SHARE_INTO;
    } else if (surface === 'editor') {
      AppStorage.set<string>(SK.EDITOR_PATH, 'sample.md');
      AppStorage.set<string>(SK.EDITOR_TITLE, 'sample.md');
      AppStorage.set<string>(SK.EDITOR_TEXT, SEED_DOC_MD_POPULATED);
      AppStorage.set<string>(SK.EDITOR_FORMAT, 'Markdown');
      this.targetRoute = ROUTE.EDITOR;
    } else if (surface === 'todo_editor') {
      AppStorage.set<string>(SK.EDITOR_PATH, 'todo.todo.txt');
      AppStorage.set<string>(SK.EDITOR_TITLE, 'todo.todo.txt');
      AppStorage.set<string>(SK.EDITOR_TEXT, SEED_TODO_TEXT);
      AppStorage.set<string>(SK.EDITOR_FORMAT, 'To-Do');
      this.targetRoute = ROUTE.EDITOR;
    } else if (surface === 'todo') {
      AppStorage.set<number>(SK.CUR_TAB, TAB.TODO);
    } else if (surface === 'quicknote') {
      AppStorage.set<number>(SK.CUR_TAB, TAB.QUICKNOTE);
    } else if (surface === 'more') {
      AppStorage.set<number>(SK.CUR_TAB, TAB.MORE);
    } else {
      AppStorage.set<number>(SK.CUR_TAB, TAB.NOTEBOOK);
    }
    AppStorage.set<string>(SK.CUR_ROUTE, this.targetRoute);
  }

  private loadSelectedSurface(): void {
    this.windowStage?.loadContent(this.targetRoute, (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'a2h', 'Failed to load public surface. Cause: %{public}s', JSON.stringify(err));
      }
    });
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.targetRoute = ROUTE.MAIN;
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'a2h', 'Failed to set color mode. Cause: %{public}s', JSON.stringify(err));
    }
    initializeNotebookPersistence(this.context);
    seedDefault();
    this.selectSurface(want);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.selectSurface(want);
    this.loadSelectedSurface();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    this.windowStage = windowStage;
    this.loadSelectedSurface();
  }

  onWindowStageDestroy(): void {
    this.windowStage = undefined;
  }
}
