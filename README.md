# Introductory Genkit Workshop

In the era of generative AI, building chatbots that only talk is no longer enough. The current market demands AI agents: systems capable of reasoning, using external tools, and following business rules.

In this hands-on workshop (~90 min), we will build a **Smart Retail Assistant**. We will use [Genkit](https://firebase.google.com/docs/genkit), Google's framework designed to bring AI to production environments with the security and scalability that characterizes the Firebase ecosystem.

> **Live Codelab (English):** [workshop-genkit-agents-101.lperezp.dev/en/](https://workshop-genkit-agents-101.lperezp.dev/en/)
>
> **Codelab en vivo (Español):** [workshop-genkit-agents-101.lperezp.dev](https://workshop-genkit-agents-101.lperezp.dev)
>
> **Source code:** [github.com/lperezp/workshop-genkit-agents](https://github.com/lperezp/workshop-genkit-agents)

## What you will build

A smart assistant that:

- Understands user needs through natural language.
- Consults a product catalog in real time.
- Automatically validates if a product meets quality and availability standards.
- Responds with structured data ready to be consumed by a web application.

## What you will learn

- **Flows**: Complex logic orchestration with built-in observability.
- **Tool Calling**: How to allow AI to execute TypeScript code to interact with APIs.
- **Zod / Type Safety**: Strict contracts so the AI doesn't break your application.
- **Business Rules**: Quality and availability filters on catalog data.
- **Tracing**: Observability to see exactly what happens inside the model.
- **Cloud**: Deployment on Firebase Cloud Functions.

## Prerequisites

- Node.js v20 or higher
- npm
- Google Account (to get an API Key from [Google AI Studio](https://aistudio.google.com/app/apikey))

## Generate the Codelab locally

This repository uses the `claat` tool to generate the codelab pages.

1. Install [Go](https://golang.org/dl/) and configure the `GOPATH` in your `PATH`.

2. Install `claat`:
```bash
go install github.com/googlecodelabs/tools/claat@latest
```

3. Generate the pages:
```bash
# English version
claat export content/codelab-en.md

# Spanish version
claat export content/codelab.md
```

## Deployment on GitHub Pages

The repository includes a GitHub Actions workflow that automatically deploys the codelab to GitHub Pages on every push to `main`. To enable it, turn on GitHub Pages from **Settings → Pages → Source: GitHub Actions**.

## Contributing

1. Fork the repository.
2. Create a branch for your feature.
3. Commit your changes.
4. Open a Pull Request with a detailed description.

## License

This project is licensed under the Apache License 2.0. See the `LICENSE` file for details.
