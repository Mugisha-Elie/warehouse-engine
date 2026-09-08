import type { ITask } from "pg-promise";

export type Transaction = ITask<unknown>

export abstract class IDatabaseConnection {
  abstract query<T>(query: string, params?: unknown[]): Promise<T[]>
  abstract oneOrNone<T>(query: string, params?: unknown[]): Promise<T | null>
  abstract one<T>(query: string, params?: unknown[]): Promise<T>
  abstract none(query: string, params?: unknown[]): Promise<void>
  abstract tx<T>(callback: (t: Transaction) => Promise<T>): Promise<T>
}