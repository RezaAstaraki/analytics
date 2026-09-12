# Data model (ERD)

MVP analytics core: visitors, sessions, events, and identity. No accounts/subscriptions yet.

## Entity relationship diagram

```mermaid
erDiagram
  properties ||--o{ visitors : tracks
  properties ||--o{ sessions : tracks
  properties ||--o{ events : tracks
  properties ||--o{ visitor_identity_map : has
  properties ||--o{ visitor_merges : has

  visitors ||--o{ sessions : has
  visitors ||--o{ events : generates
  visitors ||--o{ visitor_identity_map : "canonical for"
  visitors ||--o{ visitor_merges : "from/to"

  sessions ||--o{ events : contains

  properties {
    string property_id PK
    string name
    timestamp created_at
  }

  visitors {
    string visitor_id PK
    string property_id FK
    string user_id "nullable site login"
    timestamp first_seen
    timestamp last_seen
  }

  visitor_identity_map {
    string property_id FK
    string identity_type "anonymous|user|..."
    string identity_value
    string canonical_visitor_id FK
  }

  visitor_merges {
    string property_id FK
    string from_visitor_id FK
    string to_visitor_id FK
    timestamp merged_at
  }

  sessions {
    string session_id PK
    string property_id FK
    string visitor_id FK
    timestamp started_at
    timestamp ended_at
    string source
    string medium
    string campaign
    string channel_group
    bool is_bounce
    int duration_sec
  }

  events {
    string event_id PK
    string property_id FK
    string visitor_id FK
    string session_id FK
    string event_name "SDK-defined"
    timestamp client_timestamp
    timestamp server_timestamp
    date received_date
    string page_path
    string source
    string medium
    string campaign
    string channel_group
    string user_id
    string device_type
    string country
    jsonb properties
  }
```

## Relationships

| From | To | Cardinality | Meaning |
|------|-----|-------------|---------|
| visitor | session | 1:N | many visits per person |
| session | event | 1:N | many actions per visit |
| visitor | event | 1:N | all actions by that person (denormalized FK) |
| visitor | visitor_identity_map | 1:N | many raw IDs → one canonical visitor |
| visitor | visitor_merges | 1:N | merge audit trail |

## Notes

- Events are append-only; `event_name` and `properties` are defined by the SDK.
- Client sends `anonymous_id` only; server resolves `visitor_id` and assigns `session_id`.
- `visitor_identity_map` is unique on `(property_id, identity_type, identity_value)`.
- Preview this diagram at [mermaid.live](https://mermaid.live) or in GitHub Markdown.
