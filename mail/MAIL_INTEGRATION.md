# Stalwart Mail — Guia de Integração para Serviços Internos

Este documento descreve como outros containers/serviços devem se conectar ao
Stalwart Mail rodando neste servidor.

---

## Cenário A: Comunicação Interna (Container → Stalwart, mesmo servidor)

Usado por serviços que rodam no mesmo host (ex: Vaultwarden, n8n, Trilium).

### Pré-requisitos

O container do serviço **deve** estar na rede `mail-internal`:
```yaml
# No compose.yml do serviço:
networks:
  mail-internal:
    external: true

services:
  meu-servico:
    networks:
      - tunnel-network
      - mail-internal   # <- adicionar
```

### A1: Envio autenticado (recomendado para serviços com credenciais)

Quando o serviço precisa autenticar como um usuário do Stalwart (ex: enviar
como `no-reply@leazirondi.com.br`), **é obrigatório usar TLS** — o Stalwart
não anuncia mecanismos AUTH em conexões plaintext por segurança.

| Campo                        | Valor                                    |
| ---------------------------- | ---------------------------------------- |
| **Host/Server**              | `stalwart-mail` (DNS interno do Docker)  |
| **Porta SMTP**               | `465`                                    |
| **TLS/Segurança**            | `force_tls` / `SSL/TLS` (Implicit TLS)  |
| **Autenticação**             | `plain`                                  |
| **HELO Domain**              | FQDN público do serviço                  |
| **Accept Invalid Certs**     | ✅ Sim                                   |
| **Accept Invalid Hostnames** | ✅ Sim                                   |

> **Por que aceitar certificados inválidos?** O certificado TLS do Stalwart é
> emitido para `mail.leazirondi.com.br`, mas os containers se conectam via o
> hostname Docker `stalwart-mail` — que não bate. O tráfego continua
> **criptografado**, apenas a validação do hostname do certificado é relaxada.
> Isso é perfeitamente aceitável numa rede Docker interna e isolada.

#### Exemplo: Vaultwarden (`vault.leazirondi.com.br/admin` → SMTP Settings)

| Campo                          | Valor                              |
| ------------------------------ | ---------------------------------- |
| **Host**                       | `stalwart-mail`                    |
| **Secure SMTP**                | `force_tls`                        |
| **Port**                       | `465`                              |
| **From Address**               | `no-reply@leazirondi.com.br`       |
| **From Name**                  | `Vaultwarden - Não Responda`       |
| **Username**                   | `no-reply@leazirondi.com.br`       |
| **Password**                   | *(senha da conta no Stalwart)*     |
| **SMTP Auth mechanism**        | `plain`                            |
| **Server name sent during HELO** | `vault.leazirondi.com.br`        |
| **Accept Invalid Certs**       | ✅ marcado                         |
| **Accept Invalid Hostnames**   | ✅ marcado                         |

### A2: Relay sem autenticação (relay interno confiável)

Para serviços que **não possuem credenciais** e apenas precisam entregar
e-mails ao Stalwart como relay local. Requer configurar o Stalwart para
aceitar relay da rede `mail-internal` sem autenticação.

| Campo            | Valor                                   |
| ---------------- | --------------------------------------- |
| **Host/Server**  | `stalwart-mail`  (DNS interno do Docker) |
| **Porta SMTP**   | `25`                                    |
| **TLS/Segurança**| `off` / `None` (plaintext)              |
| **Autenticação** | Nenhuma                                 |
| **HELO Domain**  | FQDN público do serviço                 |

> **Nota:** Plaintext na porta 25 é seguro neste cenário porque o tráfego
> **nunca sai da bridge Docker** `mail-internal` — é comunicação
> processo-a-processo isolada pelo kernel.

---

## Cenário B: Comunicação Externa (Servidor → Servidor, pela internet)

Usado para envio/recebimento de e-mails entre o Stalwart e outros servidores
de e-mail na internet (Gmail, Outlook, outros MTA).

| Campo            | Valor                                        |
| ---------------- | -------------------------------------------- |
| **Porta SMTP**   | `25` (MTA-to-MTA) / `465` (SMTPS) / `587` (Submission) |
| **TLS/Segurança**| Obrigatório — `STARTTLS` ou `Implicit TLS`   |
| **Autenticação** | Depende do contexto (MTA relay geralmente não autentica) |

### Portas expostas pelo firewall (NixOS)

| Porta  | Protocolo    | Uso                                    |
| ------ | ------------ | -------------------------------------- |
| `25`   | SMTP         | Receber e-mails de outros servidores   |
| `465`  | SMTPS        | Envio autenticado (Implicit TLS)       |
| `587`  | Submission   | Envio autenticado (STARTTLS)           |
| `993`  | IMAPS        | Acesso à caixa postal (clientes)       |
| `4190` | ManageSieve  | Filtros de regras de e-mail            |

### Requisitos DNS (já devem estar configurados)

- **MX Record**: `leazirondi.com.br → mail.leazirondi.com.br`
- **SPF**: `v=spf1 a mx ip4:<IP> ip6:<IPv6> -all`
- **DKIM**: Chave pública gerada pelo Stalwart
- **DMARC**: `v=DMARC1; p=reject; rua=mailto:postmaster@leazirondi.com.br`
- **rDNS (PTR)**: IP do Hetzner apontando para `mail.leazirondi.com.br`

---

## Cenário C: Webmail (SnappyMail → Stalwart, mesmo servidor)

O SnappyMail acessa o Stalwart como um **cliente de e-mail** (IMAP + SMTP),
não como um relay. Configurado no Admin Panel do SnappyMail (`?admin` → Domains).

| Campo            | Valor                         |
| ---------------- | ----------------------------- |
| **IMAP Server**  | `stalwart-mail`               |
| **IMAP Port**    | `993`                         |
| **IMAP Secure**  | `SSL/TLS`                     |
| **SMTP Server**  | `stalwart-mail`               |
| **SMTP Port**    | `465`                         |
| **SMTP Secure**  | `SSL/TLS`                     |
| **Sieve Server** | `stalwart-mail`               |
| **Sieve Port**   | `4190`                        |
| **Sieve Secure** | `None`                        |

> **Nota:** O SnappyMail usa TLS para IMAP/SMTP porque simula um cliente de
> e-mail real. Pode ser necessário marcar "Allow self-signed certificates"
> caso o Stalwart use certificados auto-gerados para o hostname interno.
