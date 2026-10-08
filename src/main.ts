import 'reflect-metadata'
import 'dotenv/config'
import { NestFactory } from '@nestjs/core'
import { ValidationPipe } from '@nestjs/common'
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger'
import { AppModule } from './app.module.js'

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule)

  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }))

  const config = new DocumentBuilder()
    .setTitle('Warehouse Engine API')
    .setDescription('Domain-driven logistics and inventory allocation platform')
    .setVersion('1.0')
    .build()

  const document = SwaggerModule.createDocument(app, config)
  SwaggerModule.setup('api/docs', app, document)

  const port = Number(process.env.PORT)
  await app.listen(port)

  console.log(`[Bootstrap] Warehouse Engine running at http://localhost:${port}`)
  console.log(`[Bootstrap] Swagger UI available at http://localhost:${port}/api/docs`)
}

bootstrap()
