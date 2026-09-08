import { Global, Module } from "@nestjs/common";
import { DatabaseConnection } from "./database-connection.js";
import { IDatabaseConnection } from "./database-connection.interface.js";

@Global()
@Module({
  providers: [{ provide: IDatabaseConnection, useClass: DatabaseConnection }],
  exports: [IDatabaseConnection],
})
export class PersistenceModule {}