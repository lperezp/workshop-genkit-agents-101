id: workshop-genkit-agents-101
summary: Este workshop nos ayudará a aprender acerca de Genkit. En este taller práctico, vamos a construir un Smart Retail. Utilizaremos Genkit, el framework de Google diseñado para llevar a la IA a entornos de producción con la seguridad y escalabilidad que caracteriza al ecosistema de Firebase.
authors: Luis Eduardo
categories: codelab,markdown, genkit
environments: Web
status: Published
feedback link: https://github.com/lperezp/workshop-genkit-agents-101

# Taller introductorio de Genkit

## Descripción general
Duration: 00:05:00

En la era de la IA generativa, ya no basta con construir chatbots que solo hablan. El mercado actual demanda agentes de IA: sistemas capaces de razonar, utilizar herramientas externas y seguir reglas de negocio.

En este taller práctico, vamos a construir un Smart Retail. Utilizaremos Genkit, el framework de Google diseñado para llevar a la IA a entornos de producción con la seguridad y escalabilidad que caracteriza al ecosistema de Firebase.

A lo largo de este codelab, aprenderás a dominar a utilizar diferentes LLMs para que actuen como un asistente de compras expertos y confiable.

### Que construirás? 

Un asistente inteligente que:

* Entiende las necesidades del usuario mediante el lenguaje natural.
* Consulta en tiempo real un catálogo de productos.
* Valida automáticamente si un producto cumple con los estándares de calidad y disponibilidad.
* Responde con datos estructurados listos para ser consumidos por una aplicación web.

### Lo que aprenderás hoy: 

* Orquestación de agentes: El poder de los Flows para manejar lógica compleja.
* Tool Calling: Cómo permitir que la IA ejecute código de Typescript para interactuar con APIs.
* Type Safety: Uso de Zod para garantizar que la IA no rompa la aplicación.
* Observabilidad: Cómo usar la UI de Genkit para ver exactamente que pasa 'dentro de la cabeza' del modelo.

**Código Fuente:** Puedes encontrar la solución final en [workshop-genkit-agents](https://github.com/lperezp/workshop-genkit-agents)

### Requisitos

* Node.js v20 o superior
* npm


## Configuración del entorno
Duration: 00:05:00

Primero, preparemos el terreno.

Crear carpeta: 

```
mkdir workshop-genkit-agents-101 && cd workshop-genkit-agents-101
```

Inicializar el proyecto de Node.js, instalar TypeScript y crear la estructura base:

```
# Initialize a new Node.js project
npm init -y
npm pkg set type=module

# Install and configure TypeScript
npm install -D typescript tsx
npx tsc --init

# Set up your source directory
mkdir src
touch src/index.ts
```

### Instalar paquetes Genkit

Primero, instala la CLI de Genkit globalmente. Esto te dará acceso a las herramientas de desarrollo locales, incluida la interfaz de usuario para desarrolladores:

```
npm install -g genkit-cli
```

A continuación, añade los siguientes paquetes a tu proyecto:

```
npm install genkit @genkit-ai/google-genai
```

* `genkit` — Proporciona las funcionalidades principales de Genkit.
* `@genkit-ai/google-genai` — Proporciona acceso a los modelos Gemini de Google AI.

### Configurar tu clave API del modelo

Genkit puede trabajar con varios proveedores de modelos. Este taller utiliza la API de Gemini, que ofrece un generoso plan gratuito y no requiere tarjeta de crédito para empezar.

Para usarla, necesitarás una clave API de Google AI Studio:

[Obtén una clave API de Gemini](https://aistudio.google.com/app/apikey)

Una vez que tengas tu clave, configura la variable de entorno `GOOGLE_GENAI_API_KEY`:

```
export GOOGLE_GENAI_API_KEY=<your API key>
```

## Flow
Duration: 00:15:00

### Crea tu primera aplicación

Un flujo es una función especial de Genkit con observabilidad integrada, seguridad de tipos e integración de herramientas.

Actualiza `src/index.ts` con lo siguiente:

```ts
import { googleAI } from '@genkit-ai/google-genai';
import { genkit, z } from 'genkit';

const ai = genkit({
    plugins: [googleAI()],
    model: googleAI.model('gemini-2.5-flash'),
});

export const basicScoutFlow = ai.defineFlow(
    {
        name: 'basicScoutFlow',
    },
    async (productType) => {
        const { text } = await ai.generate(
            `Eres un experto en retail. Dame los detalles de este producto: ${productType}`
        );
        return text;
    }
);
```

Este ejemplo de código:

* Configura el modelo `gemini-2.5-flash`.
* Define un flujo de Genkit para generar una consulta basada en su entrada.
* Ejecuta el flujo con una entrada de ejemplo e imprime el resultado.


### Prueba el flujo en la interfaz de usuario del desarrollador

La interfaz de usuario para desarrolladores es una herramienta local para probar e inspeccionar componentes de Genkit, como flujos, mediante una interfaz visual.

**Iniciar la interfaz de usuario para desarrolladores**

Se requiere la CLI de Genkit para ejecutar la interfaz de usuario para desarrolladores. Si seguiste los pasos de instalación anteriores, ya la tienes instalada.

Ejecuta el siguiente comando desde la raíz de tu proyecto:

```
genkit start -- npx tsx --watch src/index.ts
```

Abre http://localhost:4000 en tu navegador.

En la barra lateral, haz clic en Flows y selecciona basicScoutFlow.

Escribe un producto (ej. "Iphone 15") y presiona Run.

## Zod: Entrada y Salida Estructurada
Duration: 00:15:00

Añade este nuevo flujo a tu archivo `src/index.ts`:

```ts
const ProductDetailsSchema = z.object({
    name: z.string(),
    brand: z.string(),
    features: z.array(z.string()),
    recommendation_text: z.string()
});

export const basicScoutFlow = ai.defineFlow(
    {
        name: 'basicScoutFlow',
        inputSchema: z.string(),
        outputSchema: ProductDetailsSchema,
    },
    async (productName) => {
        const { output } = await ai.generate({
            prompt: `Eres un experto en retail. Dame los detalles de este producto: ${productName}`,
            output: { schema: ProductDetailsSchema },
        });

        if (!output) throw new Error("La IA no pudo generar el formato correcto.");
        return output;
    }
);
```

### ¿Qué acabas de implementar?

* **Contratos estrictos**: Si Gemini intenta inventar un campo que no está en el esquema, Genkit lo filtrará o lanzará un error.
* **Seguridad de tipos**: TypeScript ahora sabe exactamente qué propiedades tiene tu respuesta (p. ej. puedes hacer `output.brand` con autocompletado).
* **Validación**: Campos como `"recommendation_text"` te sugiere si el producto te conviene o no.

### Prueba el resultado

Vuelve a la Developer UI ([localhost:4000](http://localhost:4000)). Verás que ahora aparece `structuredScoutFlow`. Al ejecutarlo, notarás que la respuesta ya no es un párrafo, sino un objeto JSON limpio y listo para ser usado en una aplicación de producción.

## Tool Calling
Duration: 00:10:00

Los modelos de lenguaje (LLMs) tienen un límite: su conocimiento llega hasta su fecha de entrenamiento. No saben qué hay en tu almacén hoy ni qué precio tiene un producto en este segundo.

**Tool Calling** permite que la IA use funciones de TypeScript para interactuar con APIs externas. La IA no solo "habla", ahora "actúa".

### Define la herramienta

Vamos a crear una herramienta que realice una búsqueda real en el catálogo de DummyJSON. Genkit utiliza la descripción que escribes para que la IA entienda cuándo debe usar esta función.

Añade este código a `src/index.ts`:

```ts
export const searchProductTool = ai.defineTool(
    {
        name: 'searchProduct',
        description: 'Busca productos en el catálogo oficial de la tienda GenkitStore para obtener precios y stock en tiempo real.',
        inputSchema: z.object({ query: z.string() }),
        outputSchema: z.any(),
    },
    async (input) => {
        const response = await fetch(`https://dummyjson.com/products/search?q=${input.query}`);
        const data = await response.json();
        return data.products;
    }
);
```

Una vez definida la herramienta, puedes abrirla y probarla directamente en la Developer UI de Genkit ([localhost:4000](http://localhost:4000)), donde ya aparece listada junto con tus flujos.

### Integra la herramienta en tu agente

La magia de Genkit es que tú no llamas a la función manualmente. Se la entregas al modelo y él, basándose en la pregunta del usuario, decide si necesita usarla.

Primero, actualiza el esquema `ProductDetailsSchema` que definiste anteriormente para que acepte una lista de productos:

```ts
const ProductDetailsSchema = z.array(z.object({
    name: z.string(),
    brand: z.string(),
    features: z.array(z.string()),
    recommendation_text: z.string()
}));
```

Añade este nuevo flujo a `src/index.ts`:

```ts
export const agentFlow = ai.defineFlow(
    {
        name: 'agentFlow',
        inputSchema: z.string(),
        outputSchema: ProductDetailsSchema,
    },
    async (userInput) => {
        const { output } = await ai.generate({
            prompt: userInput,
            tools: [searchProductTool],
            output: { schema: ProductDetailsSchema },
        });

        if (!output) throw new Error("La IA no pudo generar el formato correcto.");
        return output;
    }
);
```

## Reglas de Negocio
Duration: 00:15:00

Una regla de negocio es una restricción impuesta por el desarrollador que la IA no puede ignorar. En este paso, aprenderás a interceptar los datos de la API y aplicar lógica de negocio para que el asistente sea responsable y confiable.

### ¿Por qué son necesarias?

* **Calidad**: No recomendemos productos con ratings bajos sin advertir al usuario.
* **Disponibilidad**: No generemos falsas expectativas si el stock es crítico.

### Implementando reglas de calidad

Primero, actualiza `ProductDetailsSchema` para incluir los nuevos campos de precio, rating, advertencia y disponibilidad:

```ts
const ProductDetailsSchema = z.array(z.object({
    name: z.string(),
    brand: z.string(),
    price: z.number(),
    rating: z.number(),
    features: z.array(z.string()),
    recommendation_text: z.string(),
    warning: z.string().optional(),
    availability: z.enum(['En Stock', 'Pocas Unidades', 'Agotado']).optional()
}));
```

Vamos a modificar nuestro flujo para que analice el campo `rating`. Si el rating es menor a 4.0, obligaremos a la IA a incluir un mensaje de advertencia.

Añade este flujo a `src/index.ts`:

```ts
export const guardedScoutFlow = ai.defineFlow(
    {
        name: 'guardedScoutFlow',
        inputSchema: z.string(),
        outputSchema: ProductDetailsSchema,
    },
    async (userInput) => {
        const { output } = await ai.generate({
            prompt: userInput,
            tools: [searchProductTool],
            output: { schema: ProductDetailsSchema },
            system: `
                Eres un asistente de compras honesto. 
                REGLA DE ORO: Si un producto tiene un rating menor a 3.0, 
                debes llenar el campo 'warning' indicando que la satisfacción 
                del cliente es baja.
            `,
        });

        if (!output) throw new Error("Error al generar respuesta");
        return output;
    }
);
```

### Reglas de precios: intercepción de datos

A veces, la regla no es solo un mensaje, sino filtrar la información antes de que la IA la vea. Si un producto supera el presupuesto del usuario, es mejor excluirlo para que la IA no lo recomiende.

Modifica el cuerpo de tu `searchProductTool` para añadir este filtro:

```ts
async (input) => {
    const response = await fetch(`https://dummyjson.com/products/search?q=${input.query}`);
    const data = await response.json();
    
    // Regla de precios: Filtramos productos que superen el presupuesto máximo
    const affordableProducts = data.products.filter((p: any) => p.price <= 1900);
    
    return affordableProducts;
}
```

### Prueba el impacto de tus reglas

1. Ve a la Developer UI ([localhost:4000](http://localhost:4000)).
2. Ejecuta el `guardedScoutFlow` preguntando por: `""Estoy buscando laptop""`.
3. Observa el resultado: verás que el campo `"recommendation_text` te genera una recomendación del producto.

### Conceptos clave de este módulo

* **System Instructions**: Usamos el `system` prompt para darle reglas éticas a la IA.
* **Data Filtering**: El desarrollador tiene el control total sobre qué datos llegan al modelo.

## Tracing
Duration: 00:05:00

¿Alguna vez te has preguntado qué pasa exactamente entre que el usuario hace una pregunta y la IA responde? En el desarrollo tradicional hacemos `console.log` o usamos el debugger. En Genkit, tenemos Tracing.

### ¿Qué es el Tracing?

Es una vista detallada (como el "Network Tab" de Chrome) que registra cada paso de un Flow:

* Qué herramientas llamó la IA.
* Cuánto tiempo demoró cada llamada a la API.
* Cuántos tokens consumió.
* Cuál fue el "razonamiento" intermedio antes de dar la respuesta final.

### Ejecuta un flujo complejo

Para ver un Trace interesante, necesitamos un flujo que haga varias cosas. Asegúrate de tener corriendo tu Developer UI:

```
genkit start -- npx tsx --watch src/index.ts
```

1. Ve a [http://localhost:4000](http://localhost:4000).
2. Selecciona el flujo `guardedScoutFlow`.
3. Haz una pregunta que obligue a la IA a trabajar: `"Busco una laptop de menos de 3000 USD que tenga buenas reseñas"`.

### Abre el Inspector de Trazas

Una vez que el flujo termine:

1. En la barra lateral izquierda, haz clic en el ícono de **Inspect** (la lupa o el ícono de trazas).
2. Verás una lista de las ejecuciones recientes. Haz clic en la última.

## Despliegue en la nube
Duration: 00:15:00

Hasta ahora, hemos ejecutado nuestro agente en la Developer UI. En un entorno profesional, necesitamos que nuestro flujo sea accesible a través de una URL segura (HTTPS) para que pueda ser consumido por una app en Angular, React o Flutter.

### Configura un proyecto de Firebase

Si aún no tienes un proyecto de Firebase con Cloud Functions en TypeScript, sigue estos pasos:

1. Crea un nuevo proyecto en la [consola de Firebase](https://console.firebase.google.com/) o elige uno existente.
2. Actualiza el proyecto al plan **Blaze**, requerido para desplegar Cloud Functions.
3. Instala la CLI de Firebase e inicia sesión:

```
firebase login

firebase login --reauth # alternativa, si es necesario

firebase login --no-localhost # si ejecutas en un shell remoto
```

4. Anda a la carpeta raiz del proyecto e inicializa Firebase:

```
firebase init
```

El asistente de inicialización te hará una serie de preguntas. Estas son las respuestas recomendadas:

| Pregunta | Respuesta |
|---|---|
| Which Firebase features do you want to set up? | **Functions: Configure a Cloud Functions directory and its files** |
| Please select an option | **Use an existing project** |
| Select a default Firebase project | Selecciona tu proyecto (ej. `workshop-scout-retail`) |
| What language would you like to use? | **TypeScript** |
| Do you want to use ESLint? | **No** |
| Do you want to install dependencies with npm now? | **Yes** |
| Would you like to install agent skills for Firebase? | **No** |

Al finalizar, verás el mensaje `Firebase initialization complete!` y se habrá creado la carpeta `functions/` con toda la estructura necesaria.

### Preparar el flujo para el despliegue

Actualiza el final de tu archivo `functions/src/index.ts`:

```ts
import { googleAI } from '@genkit-ai/google-genai';
import { genkit, z } from 'genkit';
import { defineSecret } from "firebase-functions/params";
import { onCallGenkit } from "firebase-functions/https";

// enableFirebaseTelemetry();

const googleAIapiKey = defineSecret("GOOGLE_GENAI_API_KEY");

const ai = genkit({
    plugins: [googleAI()],
    model: googleAI.model('gemini-2.5-flash'),
});

const ProductDetailsSchema = z.array(z.object({
    name: z.string(),
    brand: z.string(),
    price: z.number(),
    rating: z.number(),
    features: z.array(z.string()),
    recommendation_text: z.string(),
    warning: z.string().optional(),
    availability: z.enum(['En Stock', 'Pocas Unidades', 'Agotado']).optional()
}));

export const basicScoutFlow = ai.defineFlow(
    {
        name: 'basicScoutFlow',
        inputSchema: z.string(),
        outputSchema: ProductDetailsSchema,
    },
    async (productName) => {
        const { output } = await ai.generate({
            prompt: `Eres un experto en retail. Dame los detalles de este producto: ${productName}`,
            output: { schema: ProductDetailsSchema },
        });

        if (!output) throw new Error("La IA no pudo generar el formato correcto.");
        return output;
    }
);

export const generateBasicScoutFlow = onCallGenkit(
    {
        cors: '*',
        authPolicy: () => true,
        secrets: [googleAIapiKey],
    },
    basicScoutFlow
);

```

### Configurar el API Key

En producción, nunca debemos dejar las API Keys en el código o en archivos `.env` locales. Usaremos el gestor de secretos de Firebase para que Gemini pueda autenticarse de forma segura.

Ejecuta este comando en tu terminal para subir tu clave de Google AI Studio:

```
firebase functions:secrets:set GOOGLE_GENAI_API_KEY
```

Pega tu clave cuando la terminal te lo solicite.

Edita src/index.ts y agrega esto luego de los imports.

```
import { defineSecret } from 'firebase-functions/params';
const googleAIapiKey = defineSecret('GOOGLE_GENAI_API_KEY');
```

### Desplegar a Firebase

Asegúrate de haber iniciado sesión con `firebase login` y de haber seleccionado tu proyecto. Luego ejecuta:

```
firebase deploy --only functions
```

### Prueba tu API en vivo

Una vez que el despliegue termine, la terminal te entregará una URL similar a:

```
https://us-central1-tu-proyecto.cloudfunctions.net/generateBasicScoutFlow
```

Has pasado de tener un script local a una API de IA generativa con orquestación profesional, conexión real a base de datos (Tools), contratos de datos garantizados (Zod) y reglas de negocio activas.

## Felicidades
Duration: 00:05:00

Has construido un sistema de IA robusto, tipado y listo para producción.

### Lo que has logrado hoy

* **Entorno**: Configuraste un ambiente de desarrollo moderno para IA.
* **Flows**: Entendiste cómo orquestar pasos lógicos en una función rastreable.
* **Tools**: Le diste "manos" a la IA para consultar inventarios reales.
* **Zod**: Implementaste seguridad de tipos para un Frontend robusto.
* **Reglas de Negocio**: Protegiste la experiencia del usuario con filtros de calidad.
* **Observabilidad**: Aprendiste a usar Tracing para dejar de ver la IA como una caja negra.
* **Cloud**: Desplegaste una infraestructura escalable en Firebase.

### Siguientes pasos

* Conecta esta API a una aplicación de Angular o React.
* Explora el plugin de RAG para subir manuales de productos en PDF.
* Implementa evaluaciones automáticas para medir la precisión de las respuestas de tu agente.

### Mantengamos el contacto

Si tienes dudas o quieres compartir lo que construiste, ¡escríbeme!

* [lperezp.dev](https://lperezp.dev)
* LinkedIn: [Luis Eduardo Perez Pacherrez](https://www.linkedin.com/in/luiseduardoperezpacherrez/)
* GitHub: [lperezp](https://github.com/lperezp)
* Redes sociales: [X](https://x.com/lperezp_pe), [Instagram](https://instagram.com/lperezp.dev)