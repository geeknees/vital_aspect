#  Vital Aspect  🌿  
AI-powered 360° Feedback & OKR Platform for psychologically safe teams  
*(Rails + Hotwire + SQLite + OpenAI)*

---

## Table of Contents
1. [Why Vital Aspect?](#why-vital-aspect)
2. [Key Features](#key-features)
3. [Tech Stack](#tech-stack)
4. [Quick Start (5 min)](#quick-start-5-min)

---

## Why Vital Aspect?
> *“What gets talked about, gets improved — when everyone feels safe to talk.”*

* **Psychological Safety First** – Feedback is anonymous by default, AI suggests tone-softening and bias checks.  
* **360° Evaluation Meets OKR** – Continuous pulse surveys merge with quarterly Objectives in one view.  
* **AI‐Assisted Coaching** – GPT‐powered insights recommend growth actions for individuals & teams.  

---

## Key Features
| Area | Feature |
|------|---------|
| **Feedback** | Anonymous 360° surveys, bias-detection, AI tone rewrite |
| **OKR** | Objectives → Key Results → Weekly Check-ins with Turbo Streams |
| **Insight** | AI summary (strengths / growth areas) & TrustGauge score |
| **Safety** | Opt-out questions, emotion detection, aggregated dashboard |
| **Integrations** | Slack / Email /CSV & Google Sheets export |

---

## Tech Stack
* **Ruby 3.4 / Rails 8** – Hotwire (Turbo, Stimulus)
* **SQlite** – Database 
* **OpenAI (GPT-4o mini)** – feedback summarization & bias check  
* **Qdrant** – vector similarity for past feedback retrieval  
* **Tailwind CSS** – UI Kit  

---

## Quick Start (5 min)

```bash
# 1. clone + env vars
git clone https://github.com/geeknees/vital_aspect.git && cd vital_aspect
cp .env.example .env        # add OPENAI_API_KEY

# 2. setup and run
bin/rails db:setup
bin/dev

# 3. open
open http://localhost:3000

