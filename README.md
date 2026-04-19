# Taller introductorio de Genkit

En la era de la IA generativa, ya no basta con construir chatbots que solo hablan. El mercado actual demanda agentes de IA: sistemas capaces de razonar, utilizar herramientas externas y seguir reglas de negocio.

En este taller práctico (~90 min), vamos a construir un **Smart Retail Assistant**. Utilizaremos [Genkit](https://firebase.google.com/docs/genkit), el framework de Google diseñado para llevar la IA a entornos de producción con la seguridad y escalabilidad que caracteriza al ecosistema de Firebase.

> **Codelab en vivo:** [workshop-genkit-agents-101.lperezp.dev](https://workshop-genkit-agents-101.lperezp.dev)
>
> **Código fuente de la solución:** [github.com/lperezp/workshop-genkit-agents](https://github.com/lperezp/workshop-genkit-agents)

## Qué construirás

Un asistente inteligente que:

- Entiende las necesidades del usuario mediante lenguaje natural.
- Consulta en tiempo real un catálogo de productos.
- Valida automáticamente si un producto cumple con los estándares de calidad y disponibilidad.
- Responde con datos estructurados listos para ser consumidos por una aplicación web.

## Lo que aprenderás

- **Flows**: Orquestación de lógica compleja con observabilidad integrada.
- **Tool Calling**: Cómo permitir que la IA ejecute código TypeScript para interactuar con APIs.
- **Zod / Type Safety**: Contratos estrictos para que la IA no rompa tu aplicación.
- **Reglas de Negocio**: Filtros de calidad y disponibilidad sobre los datos del catálogo.
- **Tracing**: Observabilidad para ver exactamente qué pasa dentro del modelo.
- **Cloud**: Despliegue en Firebase Cloud Functions.

## Módulos

| # | Módulo | Duración |
|---|--------|----------|
| 1 | Descripción general | 5 min |
| 2 | Configuración del entorno | 5 min |
| 3 | Flow | 15 min |
| 4 | Zod: Entrada y Salida Estructurada | 15 min |
| 5 | Tool Calling | 10 min |
| 6 | Reglas de Negocio | 15 min |
| 7 | Tracing | 5 min |
| 8 | Despliegue en la nube | 15 min |
| 9 | Felicidades | 5 min |
| | **Total** | **90 min** |

## Requisitos

- Node.js v20 o superior
- npm
- Cuenta de Google (para obtener una API Key de [Google AI Studio](https://aistudio.google.com/app/apikey))

## Generar el Codelab localmente

Este repositorio usa la herramienta `claat` para generar las páginas del codelab.

1. Instala [Go](https://golang.org/dl/) y configura el `GOPATH` en tu `PATH`.

2. Instala `claat`:
```bash
go install github.com/googlecodelabs/tools/claat@latest
```

3. Genera las páginas:
```bash
claat export content/codelab.md
```

## Despliegue en GitHub Pages

El repositorio incluye un workflow de GitHub Actions que despliega el codelab automáticamente a GitHub Pages en cada push a `main`. Para habilitarlo, activa GitHub Pages desde **Settings → Pages → Source: GitHub Actions**.

## Contribuir

1. Haz fork del repositorio.
2. Crea una rama para tu cambio.
3. Realiza tus modificaciones.
4. Abre un Pull Request con una descripción detallada.

## Licencia

Este proyecto está licenciado bajo Apache License 2.0. Consulta el archivo `LICENSE` para más detalles.
