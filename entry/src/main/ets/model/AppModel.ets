/** Public, implementation-neutral state exposed by the Markor UI shell. */

import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

export class FsEntry {
  name: string = '';
  description: string = '';
  isFolder: boolean = false;
  path: string = '';
}

export class TodoTask {
  raw: string = '';
  done: boolean = false;
  priority: string = '';
  text: string = '';
  contexts: string[] = [];
  projects: string[] = [];
  dueDate: string = '';
}

export class SK {
  static readonly NOTEBOOK_ENTRIES: string = 'sk.notebook_entries';
  static readonly FILE_CONTENTS: string = 'sk.file_contents';
  static readonly TODO_TASKS: string = 'sk.todo_tasks';
  static readonly QUICKNOTE_TEXT: string = 'sk.quicknote_text';
  static readonly CUR_TAB: string = 'sk.current_tab';
  static readonly CUR_ROUTE: string = 'sk.current_route';
  static readonly CUR_FOLDER: string = 'sk.current_folder';
  static readonly VIRTUAL_FOLDER: string = 'sk.virtual_folder';
  static readonly EDITOR_TEXT: string = 'sk.editor_text';
  static readonly EDITOR_TITLE: string = 'sk.editor_title';
  static readonly EDITOR_PATH: string = 'sk.editor_path';
  static readonly EDITOR_FORMAT: string = 'sk.editor_format';
  static readonly SEARCH_QUERY: string = 'sk.search_query';
  static readonly NEW_FILE_DIALOG_VISIBLE: string = 'sk.nfd_visible';
  static readonly NFD_NAME: string = 'sk.nfd_name';
  static readonly NFD_EXT: string = 'sk.nfd_ext';
  static readonly NFD_TYPE: string = 'sk.nfd_type';
  static readonly NFD_TEMPLATE: string = 'sk.nfd_template';
  static readonly NFD_NAME_FORMAT: string = 'sk.nfd_name_format';
  static readonly START_TAB: string = 'sk.start_tab';
  static readonly INTRO_COMPLETE: string = 'sk.intro_complete';
  static readonly NOTEBOOK_LOCATION: string = 'sk.notebook_location';
  static readonly THEME: string = 'sk.theme';
  static readonly COLOR_PRESET: string = 'sk.color_preset';
  static readonly HIGHLIGHT_ENABLED: string = 'sk.highlight_enabled';
  static readonly PREVIEW_FIRST: string = 'sk.preview_first';
  static readonly FAVOURITES: string = 'sk.notebook_favourites';
  static readonly PERSISTED_ENTRIES: string = 'sk.persisted_entries';
  static readonly PERSISTED_CONTENTS: string = 'sk.persisted_contents';
  static readonly PERSISTED_FAVOURITES: string = 'sk.persisted_favourites';
}

export class ROUTE {
  static readonly INTRO: string = 'pages/IntroPage';
  static readonly PERMISSION: string = 'pages/PermissionPage';
  static readonly MAIN: string = 'pages/MainPage';
  static readonly EDITOR: string = 'pages/EditorPage';
  static readonly SHARE_INTO: string = 'pages/ShareIntoPage';
  static readonly SETTINGS: string = 'pages/SettingsPage';
  static readonly SETTINGS_SUB: string = 'pages/SettingsSubPage';
  static readonly ACTION_BUTTON_SETTINGS: string = 'pages/ActionButtonSettingsPage';
}

export class TAB {
  static readonly NOTEBOOK: number = 0;
  static readonly TODO: number = 1;
  static readonly QUICKNOTE: number = 2;
  static readonly MORE: number = 3;
}

function fs(name: string, description: string, isFolder: boolean, path: string): FsEntry {
  const entry: FsEntry = new FsEntry();
  entry.name = name;
  entry.description = description;
  entry.isFolder = isFolder;
  entry.path = path;
  return entry;
}

export const SEED_NOTEBOOK_POPULATED: FsEntry[] = [
  fs('sub', 'Folder', true, 'sub'),
  fs('notes.md', 'Markdown document', false, 'notes.md'),
  fs('quicknote.md', 'Markdown document', false, 'quicknote.md'),
  fs('sample.md', 'Markdown document', false, 'sample.md'),
  fs('todo.todo.txt', 'Todo.txt document', false, 'todo.todo.txt'),
  fs('data.json', 'JSON document', false, 'data.json'),
  fs('notes.csv', 'CSV document', false, 'notes.csv'),
  fs('child.md', 'Markdown document', false, 'sub/child.md'),
];

export const SEED_FILE_CONTENTS: Record<string, string> = {
  'notes.md': '# Notes\n- one\n- two\n',
  'quicknote.md': 'idea 1\nidea 2\n',
  'sample.md':
    '# Sample\n## H2\n### H3\n**bold** _italic_ ~~strike~~ `code`\n' +
    '- [ ] todo\n- [x] done\n1. one\n2. two\n' +
    '| a | b |\n|---|---|\n| 1 | 2 |\n[link](https://example.com)\n',
  'todo.todo.txt':
    '(A) 2026-01-01 Buy milk +shopping @home\n' +
    '2026-01-02 Call mom +family\n' +
    'x 2026-01-03 2026-01-01 Read book +reading @home\n' +
    '(C) Plan trip +travel due:2026-12-01\n' +
    'Email boss +work due:2026-02-01\n',
  'data.json': '{"k": 1}\n',
  'notes.csv': 'a,b\n1,2\n',
  'sub/child.md': '# Child\n',
};

export const SEED_TODO_TEXT: string = SEED_FILE_CONTENTS['todo.todo.txt'];
export const SEED_DOC_MD_POPULATED: string = SEED_FILE_CONTENTS['sample.md'];
export const SEED_QUICKNOTE_POPULATED: string = SEED_FILE_CONTENTS['quicknote.md'];
export const SEED_TODO_EXTRA_CONTEXTS: string[] = ['home', 'shop'];
export const SEED_TODO_PROJECTS: string[] = [
  'shopping', 'family', 'reading', 'work', 'travel', 'music', 'video'
];

const NOTEBOOK_PREFS: string = 'notebook_state';
let notebookPreferences: preferences.Preferences | undefined = undefined;

export function initializeNotebookPersistence(context: common.UIAbilityContext): void {
  notebookPreferences = preferences.getPreferencesSync(context, { name: NOTEBOOK_PREFS });
}

export function saveNotebookState(entries: FsEntry[], contents: Record<string, string>, favourites: string[]): void {
  if (notebookPreferences === undefined) {
    return;
  }
  notebookPreferences.putSync(SK.PERSISTED_ENTRIES, JSON.stringify(entries));
  notebookPreferences.putSync(SK.PERSISTED_CONTENTS, JSON.stringify(contents));
  notebookPreferences.putSync(SK.PERSISTED_FAVOURITES, JSON.stringify(favourites));
  notebookPreferences.flushSync();
}

function readNotebookPreference(key: string, fallback: string): string {
  if (notebookPreferences === undefined) {
    return fallback;
  }
  return `${notebookPreferences.getSync(key, fallback)}`;
}

export function parseTodo(line: string): TodoTask {
  const task: TodoTask = new TodoTask();
  task.raw = line;
  task.text = line;
  let remaining: string = line;
  const doneMatch = remaining.match(/^x\s+(\S+)\s+(\S+\s+)?/);
  if (doneMatch !== null) {
    task.done = true;
    remaining = remaining.slice(doneMatch[0].length);
  }
  const priorityMatch = remaining.match(/^\(([A-Z])\)\s+(\S+)\s+/);
  if (priorityMatch !== null) {
    task.priority = priorityMatch[1];
    remaining = remaining.slice(priorityMatch[0].length);
  }
  const dateMatch = remaining.match(/^(\d{4}-\d{2}-\d{2})\s+/);
  if (dateMatch !== null) {
    remaining = remaining.slice(dateMatch[0].length);
  }
  task.text = remaining;
  const contexts = remaining.match(/@\S+/g);
  if (contexts !== null) {
    task.contexts = contexts;
  }
  const projects = remaining.match(/\+\S+/g);
  if (projects !== null) {
    task.projects = projects;
  }
  const due = remaining.match(/due:(\S+)/);
  if (due !== null) {
    task.dueDate = due[1];
  }
  return task;
}

export const SEED_TODO_POPULATED: TodoTask[] =
  SEED_TODO_TEXT.trim().split('\n').map((line: string) => parseTodo(line));

export function seedDefault(): void {
  const savedEntries: string = readNotebookPreference(SK.PERSISTED_ENTRIES, '');
  const savedContents: string = readNotebookPreference(SK.PERSISTED_CONTENTS, '');
  const savedFavourites: string = readNotebookPreference(SK.PERSISTED_FAVOURITES, '[]');
  if (savedEntries.length > 0 && savedContents.length > 0) {
    AppStorage.setOrCreate<FsEntry[]>(SK.NOTEBOOK_ENTRIES, JSON.parse(savedEntries) as FsEntry[]);
    AppStorage.setOrCreate<Record<string, string>>(
      SK.FILE_CONTENTS, JSON.parse(savedContents) as Record<string, string>);
    AppStorage.setOrCreate<string[]>(SK.FAVOURITES, JSON.parse(savedFavourites) as string[]);
  } else {
    AppStorage.setOrCreate<FsEntry[]>(SK.NOTEBOOK_ENTRIES, SEED_NOTEBOOK_POPULATED);
    AppStorage.setOrCreate<Record<string, string>>(SK.FILE_CONTENTS, SEED_FILE_CONTENTS);
    AppStorage.setOrCreate<string[]>(SK.FAVOURITES, []);
    saveNotebookState(SEED_NOTEBOOK_POPULATED, SEED_FILE_CONTENTS, []);
  }
  AppStorage.setOrCreate<TodoTask[]>(SK.TODO_TASKS, SEED_TODO_POPULATED);
  AppStorage.setOrCreate<string>(SK.QUICKNOTE_TEXT, SEED_QUICKNOTE_POPULATED);
  AppStorage.setOrCreate<string>(SK.EDITOR_TEXT, SEED_DOC_MD_POPULATED);
  AppStorage.setOrCreate<string>(SK.EDITOR_TITLE, 'sample.md');
  AppStorage.setOrCreate<string>(SK.EDITOR_PATH, 'sample.md');
  AppStorage.setOrCreate<string>(SK.EDITOR_FORMAT, 'Markdown');
  // Shared Base always presents Notebook at cold start. The start-tab setting
  // remains public UI, while persistence and routing are reserved for Gold.
  AppStorage.setOrCreate<number>(SK.START_TAB, TAB.NOTEBOOK);
  AppStorage.set<number>(SK.CUR_TAB, TAB.NOTEBOOK);
  AppStorage.setOrCreate<string>(SK.CUR_ROUTE, ROUTE.MAIN);
  AppStorage.setOrCreate<string>(SK.CUR_FOLDER, '');
  AppStorage.setOrCreate<string>(SK.VIRTUAL_FOLDER, 'Notebook');
  AppStorage.setOrCreate<string>(SK.SEARCH_QUERY, '');
  AppStorage.setOrCreate<boolean>(SK.NEW_FILE_DIALOG_VISIBLE, false);
  AppStorage.setOrCreate<string>(SK.NFD_NAME, 'Title');
  AppStorage.setOrCreate<string>(SK.NFD_EXT, '.md');
  AppStorage.setOrCreate<string>(SK.NFD_TYPE, 'Markdown');
  AppStorage.setOrCreate<string>(SK.NFD_TEMPLATE, 'Empty file');
  AppStorage.setOrCreate<string>(SK.NFD_NAME_FORMAT, '{{title}}');
  AppStorage.setOrCreate<boolean>(SK.INTRO_COMPLETE, false);
  AppStorage.setOrCreate<string>(SK.NOTEBOOK_LOCATION, 'Documents/markor');
  AppStorage.setOrCreate<string>(SK.THEME, 'System');
  AppStorage.setOrCreate<string>(SK.COLOR_PRESET, 'Default');
  AppStorage.setOrCreate<boolean>(SK.HIGHLIGHT_ENABLED, true);
  AppStorage.setOrCreate<boolean>(SK.PREVIEW_FIRST, false);
}

export function seedEmpty(): void {
  AppStorage.set<FsEntry[]>(SK.NOTEBOOK_ENTRIES, []);
  AppStorage.set<Record<string, string>>(SK.FILE_CONTENTS, {});
  AppStorage.set<TodoTask[]>(SK.TODO_TASKS, []);
  AppStorage.set<string>(SK.QUICKNOTE_TEXT, '');
  AppStorage.set<string>(SK.EDITOR_TEXT, '');
}
