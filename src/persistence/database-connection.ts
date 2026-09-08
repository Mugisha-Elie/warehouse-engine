import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import pgPromise, { type IDatabase, type IInitOptions, type IMain } from "pg-promise";
import { IDatabaseConnection, type Transaction } from './database-connection.interface.js';

@Injectable()
export class DatabaseConnection extends IDatabaseConnection implements OnModuleInit, OnModuleDestroy {
  private readonly initOptions: IInitOptions = {
    capSQL:  true,
  }

  private readonly pgp: IMain = pgPromise(this.initOptions)
  private db!: IDatabase<unknown>

  async onModuleInit(): Promise<void> {
    const config = {
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT),
      database: process.env.DB_NAME,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      max: 20,
    }

    this.db = this.pgp(config)

    const obj = await this.db.connect()
    obj.done()
    console.log('[DatabaseConnection] PostgreSQL connection pool initialized and verified.')
  }

  async onModuleDestroy(): Promise<void> {
    if (this.db) {
      await this.db.$pool.end()
      console.log('[DatabaseConnection] PostgreSQL connection pool closed gracefully.')
    }
  }

  async query<T>(query: string, params?: unknown[]): Promise<T[]> {
    return this.db.any<T>(query, params)
  }

  async oneOrNone<T>(query: string, params?: unknown[]): Promise<T | null> {
    return this.db.oneOrNone<T>(query, params)
  }

  async one<T>(query: string, params?: unknown[]): Promise<T> {
    return this.db.one<T>(query, params)
  }

  async none(query: string, params?: unknown[]): Promise<void> {
    this.db.none(query, params)
  }

  async tx<T>(callback: (t: Transaction) => Promise<T>): Promise<T> {
    return this.db.tx(callback)
  }
}

