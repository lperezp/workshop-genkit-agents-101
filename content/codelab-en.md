id: workshop-genkit-agents-101-en
summary: This workshop will help us learn about Genkit. In this hands-on lab, we will build a Smart Retail assistant. We will use Genkit, Google's framework designed to bring AI to production environments with the security and scalability that characterizes the Firebase ecosystem.
authors: Luis Eduardo
categories: codelab,markdown,genkit
environments: Web
status: Published
feedback link: https://github.com/lperezp/workshop-genkit-agents-101

# Introductory Genkit Workshop

## Overview
Duration: 00:05:00

**Versión en Español:** Este codelab también está disponible en **[Español](https://workshop-genkit-agents-101.lperezp.dev/)**.

In the era of generative AI, building chatbots that only talk is no longer enough. The current market demands AI agents: systems capable of reasoning, using external tools, and following business rules.

In this hands-on workshop, we will build a Smart Retail assistant. We will use Genkit, Google's framework designed to bring AI to production environments with the security and scalability that characterizes the Firebase ecosystem.

Throughout this codelab, you will learn to master using different LLMs so they act as an expert and reliable shopping assistant.

### What will you build?

A smart assistant that:

* Understands user needs through natural language.
* Consults a product catalog in real time.
* Automatically validates if a product meets quality and availability standards.
* Responds with structured data ready to be consumed by a web application.

### What you will learn today:

* Agent Orchestration: The power of Flows to handle complex logic.
* Tool Calling: How to allow AI to execute TypeScript code to interact with APIs.
* Type Safety: Using Zod to ensure AI doesn't break the application.
* Observability: How to use the Genkit UI to see exactly what happens 'inside the model's head'.

**Source Code:** You can find the final solution at [workshop-genkit-agents](https://github.com/lperezp/workshop-genkit-agents)

### Prerequisites

* Node.js v20 or higher
* npm

## Environment Setup
Duration: 00:05:00

First, let's prepare the ground.

Create a folder:

```
mkdir workshop-genkit-agents-101 && cd workshop-genkit-agents-101
```

Initialize the Node.js project, install TypeScript, and create the base structure:

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

### Install Genkit packages

First, install the Genkit CLI globally. This will give you access to local development tools, including the developer user interface:

```
npm install -g genkit-cli
```

Next, add the following packages to your project:

```
npm install genkit @genkit-ai/google-genai
```

* `genkit` — Provides core Genkit capabilities.
* `@genkit-ai/google-genai` — Provides access to Google AI Gemini models.

### Configure your model API key

Genkit can work with various model providers. This workshop uses the Gemini API, which offers a generous free tier and does not require a credit card to get started.

To use it, you will need a Google AI Studio API key:

[Get a Gemini API key](https://aistudio.google.com/app/apikey)

Once you have your key, configure the `GOOGLE_GENAI_API_KEY` environment variable:

```
export GOOGLE_GENAI_API_KEY=<your API key>
```

## Flow
Duration: 00:15:00

### Create your first app

A flow is a special Genkit function with built-in observability, type safety, and tool integration.

Update `src/index.ts` with the following:

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
            `You are a retail expert. Give me the details of this product: ${productType}`
        );
        return text;
    }
);
```

This code example:

* Configures the `gemini-2.5-flash` model.
* Defines a Genkit flow to generate a query based on its input.
* Executes the flow with a sample input and prints the result.

### Test the flow in the developer UI

The Developer UI is a local tool to test and inspect Genkit components, such as flows, through a visual interface.

**Start the Developer UI**

The Genkit CLI is required to run the Developer UI. If you followed the installation steps above, you already have it installed.

Run the following command from the root of your project:

```
genkit start -- npx tsx --watch src/index.ts
```

Open http://localhost:4000 in your browser.

In the sidebar, click on Flows and select basicScoutFlow.

Type a product (e.g. "Iphone 15") and hit Run.

## Zod: Structured Input and Output
Duration: 00:15:00

Add this new flow to your `src/index.ts` file:

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
            prompt: `You are a retail expert. Give me the details of this product: ${productName}`,
            output: { schema: ProductDetailsSchema },
        });

        if (!output) throw new Error("The AI failed to generate the correct format.");
        return output;
    }
);
```

### What did you just implement?

* **Strict Contracts**: If Gemini tries to make up a field that is not in the schema, Genkit will filter it out or throw an error.
* **Type Safety**: TypeScript now knows exactly what properties your response has (e.g. you can make `output.brand` with auto-complete).
* **Validation**: Fields like `"recommendation_text"` will suggest whether the product suits you or not.

### Test the output

Go back to the Developer UI ([localhost:4000](http://localhost:4000)). You'll see that `structuredScoutFlow` now appears. Upon execution, you will notice that the response is no longer a paragraph, but a clean JSON object ready to be used in a production application.

## Tool Calling
Duration: 00:10:00

Language models (LLMs) have a limit: their knowledge only goes up to their training date. They do not know what is in your warehouse today or what price a product has this very second.

**Tool Calling** allows the AI to use TypeScript functions to interact with external APIs. The AI does not just "talk", it now "acts".

### Define the tool

Let's create a tool that performs an actual search in the DummyJSON catalog. Genkit uses the description you write so the AI understands when to use this function.

Add this code to `src/index.ts`:

```ts
export const searchProductTool = ai.defineTool(
    {
        name: 'searchProduct',
        description: 'Searches for products in the official GenkitStore catalog to get real-time pricing and stock.',
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

Once the tool is defined, you can open it and test it directly in the Genkit Developer UI ([localhost:4000](http://localhost:4000)), where it is already listed alongside your flows.

### Integrate the tool into your agent

The magic of Genkit is that you do not call the function manually. You hand it over to the model and it, based on the user's question, decides whether it needs to use it.

First, update the `ProductDetailsSchema` you defined earlier so it accepts a list of products:

```ts
const ProductDetailsSchema = z.array(z.object({
    name: z.string(),
    brand: z.string(),
    features: z.array(z.string()),
    recommendation_text: z.string()
}));
```

Add this new flow to `src/index.ts`:

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

        if (!output) throw new Error("The AI failed to generate the correct format.");
        return output;
    }
);
```

## Business Rules
Duration: 00:15:00

A business rule is a constraint imposed by the developer that the AI cannot ignore. In this step, you will learn to intercept API data and apply business logic so the assistant is responsible and reliable.

### Why are they necessary?

* **Quality**: Let's not recommend low-rated products without alerting the user.
* **Availability**: Let's not raise false expectations if stock is critical.

### Implementing quality rules

First, update `ProductDetailsSchema` to include the new fields: price, rating, warning, and availability:

```ts
const ProductDetailsSchema = z.array(z.object({
    name: z.string(),
    brand: z.string(),
    price: z.number(),
    rating: z.number(),
    features: z.array(z.string()),
    recommendation_text: z.string(),
    warning: z.string().optional(),
    availability: z.enum(['In Stock', 'Low Stock', 'Out of Stock']).optional()
}));
```

Let's modify our flow so it analyzes the `rating` field. If the rating is lower than 4.0, we will force the AI to include a warning message.

Add this flow to `src/index.ts`:

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
                You are an honest shopping assistant. 
                GOLDEN RULE: If a product has a rating lower than 3.0, 
                you must fill out the 'warning' field stating that customer 
                satisfaction is low.
            `,
        });

        if (!output) throw new Error("Error generating response");
        return output;
    }
);
```

### Pricing rules: Data interception

Sometimes, the rule isn't just a message but filtering out information before the AI sees it. If a product exceeds the user's budget, it's better to exclude it so the AI doesn't recommend it.

Modify the body of your `searchProductTool` to add this filter:

```ts
async (input) => {
    const response = await fetch(`https://dummyjson.com/products/search?q=${input.query}`);
    const data = await response.json();
    
    // Pricing rule: Filter out products that exceed the maximum budget
    const affordableProducts = data.products.filter((p: any) => p.price <= 1900);
    
    return affordableProducts;
}
```

### Test the impact of your rules

1. Go to the Developer UI ([localhost:4000](http://localhost:4000)).
2. Run the `guardedScoutFlow` asking for: `""I am looking for a laptop""`.
3. Check the output: you will see that the `"recommendation_text"` field generates a product recommendation for you.

### Key concepts from this module

* **System Instructions**: We use the `system` prompt to lay down ethical rules for the AI.
* **Data Filtering**: The developer has full control over what data reaches the model.

## Tracing
Duration: 00:05:00

Have you ever wondered exactly what happens between the user asking a question and the AI responding? In traditional development, we `console.log` or use a debugger. In Genkit, we have Tracing.

### What is Tracing?

It is a detailed view (like Chrome's "Network Tab") that records every step of a Flow:

* Which tools the AI called.
* How long each API call took.
* How many tokens it consumed.
* What the intermediate "reasoning" was before producing a final answer.

### Run a complex flow

To see an interesting Trace, we need a flow that does multiple things. Make sure your Developer UI is running:

```
genkit start -- npx tsx --watch src/index.ts
```

1. Go to [http://localhost:4000](http://localhost:4000).
2. Select the `guardedScoutFlow` flow.
3. Ask a question that forces the AI to work: `"I am looking for a laptop under 3000 USD that has good reviews"`.

### Open the Trace Inspector

Once the flow completes:

1. On the left sidebar, click the **Inspect** icon (the magnifying glass or tracing icon).
2. You will see a list of recent runs. Click on the latest one.

## Cloud Deployment
Duration: 00:15:00

So far, we have run our agent through the Developer UI. In a professional environment, we need our flow to be accessible via a secure HTTPS URL, so it can be consumed by an Angular, React, or Flutter app.

### Set up a Firebase project

If you do not yet have a Firebase project with Cloud Functions in TypeScript, follow these steps:

1. Create a new project in the [Firebase console](https://console.firebase.google.com/) or select an existing one.
2. Upgrade the project to the **Blaze** plan, which is required to deploy Cloud Functions.
3. Install the Firebase CLI and log in:

```
firebase login

firebase login --reauth # alternative, if needed

firebase login --no-localhost # if running in a remote shell
```

4. Go to the root folder of the project and initialize Firebase:

```
firebase init
```

The setup wizard will ask you a series of questions. These are the recommended answers:

| Question | Answer |
|---|---|
| Which Firebase features do you want to set up? | **Functions: Configure a Cloud Functions directory and its files** |
| Please select an option | **Use an existing project** |
| Select a default Firebase project | Select your project (e.g. `workshop-scout-retail`) |
| What language would you like to use? | **TypeScript** |
| Do you want to use ESLint? | **No** |
| Do you want to install dependencies with npm now? | **Yes** |
| Would you like to install agent skills for Firebase? | **No** |

Once finished, you will see the `Firebase initialization complete!` message, and the `functions/` folder will have been created with all the required structure.

### Prepare the flow for deployment

Update the end of your `functions/src/index.ts` file:

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
    availability: z.enum(['In Stock', 'Low Stock', 'Out of Stock']).optional()
}));

export const basicScoutFlow = ai.defineFlow(
    {
        name: 'basicScoutFlow',
        inputSchema: z.string(),
        outputSchema: ProductDetailsSchema,
    },
    async (productName) => {
        const { output } = await ai.generate({
            prompt: `You are a retail expert. Give me the details of this product: ${productName}`,
            output: { schema: ProductDetailsSchema },
        });

        if (!output) throw new Error("The AI failed to generate the correct format.");
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

### Configure the API Key

In production, we must never leave API Keys embedded in the code or in local `.env` files. We will use the Firebase secret manager so Gemini can authenticate securely.

Run this command in your terminal to upload your Google AI Studio key:

```
firebase functions:secrets:set GOOGLE_GENAI_API_KEY
```

Paste your key when the terminal prompts for it.

Edit src/index.ts and append this right after the imports.

```
import { defineSecret } from 'firebase-functions/params';
const googleAIapiKey = defineSecret('GOOGLE_GENAI_API_KEY');
```

### Deploy to Firebase

Make sure you are logged in via `firebase login` and have selected your project. Then run:

```
firebase deploy --only functions
```

### Test your Live API

Once the deployment finishes, the terminal will give you a URL similar to:

```
https://us-central1-your-project.cloudfunctions.net/generateBasicScoutFlow
```

You have progressed from having a local script to a generative AI API with professional orchestration, real database connections (Tools), guaranteed data contracts (Zod), and active business rules.

## Congratulations
Duration: 00:05:00

You have built a robust, typed, and production-ready AI system.

### What you accomplished today

* **Environment**: Setup a modern development environment for AI.
* **Flows**: Understood how to orchestrate logical steps into a traceable function.
* **Tools**: Gave the AI "hands" to query real inventories.
* **Zod**: Implemented type safety for a robust frontend.
* **Business Rules**: Guarded the user experience using quality filters.
* **Observability**: Learned to use Tracing to stop treating AI as a black box.
* **Cloud**: Deployed scalable infrastructure onto Firebase.

### Next Steps

* Connect this API to an Angular or React app.
* Explore the RAG plugin to upload PDF product manuals.
* Implement automated evaluations to measure the accuracy of your agent's responses.

### Let's keep in touch

If you have questions or want to share what you've built, feel free to reach out!

* [lperezp.dev](https://lperezp.dev?utm_source=codelab&utm_medium=referral&utm_campaign=workshop-genkit-agents-101)
* LinkedIn: [Luis Eduardo Perez Pacherrez](https://www.linkedin.com/in/luiseduardoperezpacherrez/?utm_source=codelab&utm_medium=referral&utm_campaign=workshop-genkit-agents-101)
* GitHub: [lperezp](https://github.com/lperezp?utm_source=codelab&utm_medium=referral&utm_campaign=workshop-genkit-agents-101)
* Social Media: [X](https://x.com/lperezp_pe?utm_source=codelab&utm_medium=referral&utm_campaign=workshop-genkit-agents-101), [Instagram](https://instagram.com/lperezp.dev?utm_source=codelab&utm_medium=referral&utm_campaign=workshop-genkit-agents-101)
