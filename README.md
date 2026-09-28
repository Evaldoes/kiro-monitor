# kiro-monitor

Monitoramento do Kiro CLI quando ele é chamado pelo Claude Code: registra, exibe ao vivo e bloqueia comandos perigosos.

## Camadas

| Camada | Captura | Componente |
|---|---|---|
| `claude` | Comandos Bash do Claude Code que envolvem `kiro` | `bin/kmon-hook` via hooks do Claude (`config/claude-hooks.json`) |
| `kiro-hook` | agentSpawn, prompts, pre/postToolUse, stop do Kiro | `bin/kmon-hook` via agente Kiro `monitor` (`config/kiro-agent-monitor.json`) |
| `kiro-session` | Transcrição de `~/.kiro/sessions/cli/*.jsonl` | `bin/kmon-sessions` |
| `os-exec` | Todo processo descendente do `kiro-cli` (eBPF, requer sudo) | `bin/kmon-exec` (usa `execsnoop-bpfcc`) |

Todos os eventos vão para `~/.kiro-monitor/events.jsonl`.

## Instalação

```bash
./install.sh            # instala scripts e o agente "monitor"
./install.sh --default  # idem, e torna "monitor" o agente padrão do Kiro
```

Para capturar a camada `claude`, mescle `config/claude-hooks.json` em `~/.claude/settings.json` (trocando `__HOME__`).

Requisitos: `python3`, `jq`, `bpfcc-tools` (camada os-exec), Kiro CLI ≥ 2.12.

## Uso

```bash
kmon-up [start|stop|status]   # coletores + painel web (pede sudo para o eBPF)
kiro-monitor [--all]          # painel colorido no terminal
kiro-cli chat --agent monitor # usar o agente monitorado sem torná-lo padrão
```

Painel web: http://127.0.0.1:8765 — filtros por camada, busca, contador de bloqueios.

## Bloqueio

`preToolUse` (Kiro) e `PreToolUse` (Claude) retornam exit 2 quando o comando casa com a lista `DANGER` em `bin/kmon-hook`:
`rm -rf`, `git push --force`, `git reset --hard`, `mkfs`, `dd if=`, fork bomb, `chmod -R 777 /`.

## Limitações conhecidas

- Em `kiro-cli chat --no-interactive` o Kiro não grava sessão, então a camada `kiro-session` fica vazia.
- O evento `userPromptSubmit` não traz o texto do prompt; ele aparece pela camada `kiro-session`.
