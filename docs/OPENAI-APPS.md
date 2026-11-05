# OpenAI na Windows 10 — aplikacje i narzędzia

Nie wszystkie produkty OpenAI są aplikacjami instalowanymi w Windows. Ten katalog odróżnia oficjalne programy, narzędzia deweloperskie i usługi webowe.

| Produkt | Typ | Jak uruchomić |
| --- | --- | --- |
| ChatGPT Desktop (Chat, Work, Codex) | Oficjalna aplikacja Windows | Microsoft Store, oficjalny wpis ID `9PLM9XGG6VKS` |
| Codex CLI | Oficjalne narzędzie developerskie | `npm install -g @openai/codex@latest` |
| OpenAI CLI | Oficjalne narzędzie API | Windows ZIP z instrukcji OpenAI Developers |
| OpenAI Python SDK | Oficjalna biblioteka | `pip install openai` |
| OpenAI Agents SDK | Oficjalna biblioteka agentów | `pip install openai-agents` |
| OpenAI Docs MCP | Oficjalny serwer zdalny tylko do dokumentacji | `codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp` |
| OpenAI API Platform | Usługa webowa/API | https://platform.openai.com |
| ChatGPT Web | Usługa webowa | https://chatgpt.com |
| Sora i inne usługi webowe OpenAI | Usługi zależne od regionu/planu | Wejdź na oficjalną stronę OpenAI |

## Instalator (opcjonalny)

Uruchom w PowerShell z katalogu repozytorium:

```powershell
.\scripts\Install-OpenAITools.ps1
.\scripts\Install-OpenAITools.ps1 -InstallChatGPT -WhatIf
.\scripts\Install-OpenAITools.ps1 -InstallChatGPT -InstallCodexCLI
.\scripts\Install-OpenAITools.ps1 -InstallPythonSDK
.\scripts\Install-OpenAITools.ps1 -ConfigureDocsMCP
```

Skrypt **nie instaluje niczego bez wskazania przełącznika**. OpenAI CLI jest instalowane ręcznie na podstawie oficjalnego ZIP, a nie przez mylące pakiety o podobnej nazwie.

## Linki źródłowe

- ChatGPT na Windows: https://help.openai.com/en/articles/9982051-using-the-chatgpt-windows-app
- Nowa aplikacja desktopowa z Codex: https://help.openai.com/en/articles/20001276-moving-to-the-new-chatgpt-desktop-app
- Codex: https://developers.openai.com/codex/
- OpenAI CLI dla Windows: https://developers.openai.com/api/reference/cli
- OpenAI Docs MCP: https://developers.openai.com/learn/docs-mcp
- OpenAI Python SDK: https://github.com/openai/openai-python
- OpenAI Agents SDK: https://github.com/openai/openai-agents-python

Uwaga: logowanie do aplikacji ChatGPT/Codex **nie oznacza** dostępu do płatnych żądań OpenAI API. Dostęp i rozliczenie API są osobne. Po zakończeniu standardowego wsparcia Windows 10 (14.10.2025) należy rozważyć ESU lub wspierany host.
