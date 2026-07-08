/**
 * Markor A2H — central app model + AppStorage-backed mock-data layer.
 *
 * backend in without changing the AppStorage keys the UI binds to.
 *
 * The keys here are the **stable component-id surface** declared in
 */

/** A notebook file-browser row (DS_NOTEBOOK_TREE entry). */
export class FsEntry {
  name: string = '';
  description: string = '';
  isFolder: boolean = false;
  path: string = '';
}

/** A todo.txt task (DS_TODO). */
export class TodoTask {
  raw: string = '';
  done: boolean = false;
  priority: string = '';
  text: string = '';
  contexts: string[] = [];
  projects: string[] = [];
  dueDate: string = '';
}

/** Settings preference row (DS_SETTINGS). */
export interface PrefRow {
  key: string;
  title: string;
  summary?: string;
  category: string;
}

export class SK {
  static readonly NOTEBOOK_ENTRIES: string = 'sk.notebook_entries';
  static readonly TODO_TASKS: string = 'sk.todo_tasks';
  static readonly QUICKNOTE_TEXT: string = 'sk.quicknote_text';
  static readonly CUR_TAB: string = 'sk.current_tab';
  static readonly CUR_ROUTE: string = 'sk.current_route';
  static readonly EDITOR_TEXT: string = 'sk.editor_text';
  static readonly EDITOR_TITLE: string = 'sk.editor_title';
  static readonly EDITOR_FORMAT: string = 'sk.editor_format';
  static readonly SEARCH_QUERY: string = 'sk.search_query';
  static readonly NEW_FILE_DIALOG_VISIBLE: string = 'sk.nfd_visible';
  static readonly NFD_NAME: string = 'sk.nfd_name';
  static readonly NFD_EXT: string = 'sk.nfd_ext';
  static readonly NFD_TYPE: string = 'sk.nfd_type';
  static readonly NFD_TEMPLATE: string = 'sk.nfd_template';
  static readonly NFD_NAME_FORMAT: string = 'sk.nfd_name_format';
  static readonly PREFS: string = 'sk.prefs';
}

/** Routes — mirror labels.py ROUTE_* exactly. */
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

/** Bottom-nav tab indices (mirror labels.TAB_*). */
export class TAB {
  static readonly NOTEBOOK: number = 0;
  static readonly TODO: number = 1;
  static readonly QUICKNOTE: number = 2;
  static readonly MORE: number = 3;
}

/** Helper to construct an FsEntry. */
function fs(name: string, description: string, isFolder: boolean, path: string): FsEntry {
  const e: FsEntry = new FsEntry();
  e.name = name; e.description = description; e.isFolder = isFolder; e.path = path;
  return e;
}

export const SEED_NOTEBOOK_POPULATED: FsEntry[] = [
  fs('..', '/storage/emulated/0/Documents', true, '..'),
  fs('sub', '7/3/2026, 9:33 AM', true, 'sub'),
  fs('notes.md', '7/3/2026, 9:33 AM', false, 'notes.md'),
  fs('quicknote.md', '7/3/2026, 9:33 AM', false, 'quicknote.md'),
  fs('sample.md', '7/3/2026, 9:33 AM', false, 'sample.md'),
  fs('todo.todo.txt', '7/3/2026, 9:33 AM', false, 'todo.todo.txt'),
];

/** Default seed for DS_TODO populated_mixed (5 deterministic tasks). */
export const SEED_TODO_POPULATED: TodoTask[] = [
  parseTodo('(A) 2026-01-01 Buy milk +shopping @home'),
  parseTodo('2026-01-02 Call mom +family'),
  parseTodo('x 2026-01-03 2026-01-01 Read book +reading @home'),
  parseTodo('(C) Plan trip +travel due:2026-12-01'),
  parseTodo('Email boss +work due:2026-02-01'),
];

/** DS_DOC_MD populated sample. */
export const SEED_DOC_MD_POPULATED =
  '# Sample\n## H2\n**bold** _italic_ ~~strike~~ \n' +
  '- [ ] todo\n- [x] done\n1. one\n2. two\n' +
  '| a | b |\n|---|---|\n| 1 | 2 |\n[link](https://example.com)\n';

/** DS_QUICKNOTE populated. */
export const SEED_QUICKNOTE_POPULATED = 'idea 1\nidea 2\n';

/** Parse a todo.txt line into a TodoTask (subset, sufficient for shell). */
export function parseTodo(line: string): TodoTask {
  const t: TodoTask = new TodoTask();
  t.raw = line; t.text = line;
  let s = line;
  const doneM = s.match(/^x\s+(\S+)\s+(\S+\s+)?/);
  if (doneM !== null) { t.done = true; s = s.slice(doneM[0].length); }
  const priM = s.match(/^\(([A-Z])\)\s+(\S+)\s+/);
  if (priM !== null) { t.priority = priM[1]; s = s.slice(priM[0].length); }
  const dateM = s.match(/^(\d{4}-\d{2}-\d{2})\s+/);
  if (dateM !== null) { s = s.slice(dateM[0].length); }
  t.text = s;
  const ctxM = s.match(/@\S+/g);
  if (ctxM !== null) t.contexts = ctxM;
  const prjM = s.match(/\+\S+/g);
  if (prjM !== null) t.projects = prjM;
  const dueM = s.match(/due:(\S+)/);
  if (dueM !== null) t.dueDate = dueM[1];
  return t;
}

/** Initialize AppStorage with the populated seed (used by EntryAbility + tests). */
export function seedDefault(): void {
  AppStorage.setOrCreate<FsEntry[]>(SK.NOTEBOOK_ENTRIES, SEED_NOTEBOOK_POPULATED);
  AppStorage.setOrCreate<TodoTask[]>(SK.TODO_TASKS, SEED_TODO_POPULATED);
  AppStorage.setOrCreate<string>(SK.QUICKNOTE_TEXT, SEED_QUICKNOTE_POPULATED);
  AppStorage.setOrCreate<string>(SK.EDITOR_TEXT, SEED_DOC_MD_POPULATED);
  AppStorage.setOrCreate<string>(SK.EDITOR_TITLE, 'sample');
  AppStorage.setOrCreate<string>(SK.EDITOR_FORMAT, 'Markdown');
  AppStorage.setOrCreate<number>(SK.CUR_TAB, TAB.NOTEBOOK);
  AppStorage.setOrCreate<string>(SK.CUR_ROUTE, ROUTE.MAIN);
  AppStorage.setOrCreate<string>(SK.SEARCH_QUERY, '');
  AppStorage.setOrCreate<boolean>(SK.NEW_FILE_DIALOG_VISIBLE, false);
  AppStorage.setOrCreate<string>(SK.NFD_NAME, 'Title');
  AppStorage.setOrCreate<string>(SK.NFD_EXT, '.md');
  AppStorage.setOrCreate<string>(SK.NFD_TYPE, 'Markdown');
  AppStorage.setOrCreate<string>(SK.NFD_TEMPLATE, 'Empty file');
  AppStorage.setOrCreate<string>(SK.NFD_NAME_FORMAT, '{{title}}');
}

/** Reset to empty-list state (empty-state capture). */
export function seedEmpty(): void {
  AppStorage.setOrCreate<FsEntry[]>(SK.NOTEBOOK_ENTRIES, []);
  AppStorage.setOrCreate<TodoTask[]>(SK.TODO_TASKS, []);
  AppStorage.setOrCreate<string>(SK.QUICKNOTE_TEXT, '');
  AppStorage.setOrCreate<string>(SK.EDITOR_TEXT, '');
}
