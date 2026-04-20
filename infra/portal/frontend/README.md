# Portal Frontend (Next.js)

This directory will contain the Next.js App Router frontend for the Local-Machine platform.

## Planned Structure

```
frontend/
├── app/
│   ├── layout.tsx          # Root layout (nav, auth context)
│   ├── page.tsx            # Landing / redirect to dashboard
│   ├── register/page.tsx   # Registration form
│   ├── login/page.tsx      # Login form
│   ├── dashboard/page.tsx  # Machine browser + Spawn + live IP
│   ├── profile/page.tsx    # Download .ovpn, stats, settings
│   ├── leaderboard/page.tsx
│   └── admin/
│       ├── page.tsx        # Admin overview
│       ├── users/page.tsx  # User management
│       └── pods/page.tsx   # Live Pod view
├── components/
│   ├── MachineCard.tsx     # Spawn button + live IP display
│   ├── FlagSubmit.tsx      # Flag submission form
│   ├── ActivityFeed.tsx    # Live activity (first bloods, etc.)
│   └── PodStatus.tsx       # Polling component (3s refresh)
├── lib/
│   ├── api.ts              # Backend API client
│   └── auth.ts             # JWT token management
└── public/
```

## Key Behaviors

- **Spawn button**: calls `POST /api/machines/{id}/spawn` → backend creates Pod → returns IP
- **Live IP display**: polls `GET /api/machines/{id}/status` every 3s while Pod is Pending
- **Refresh = fix**: on page load, backend checks Pod health; CrashLoop → auto-respawn
- **OVPN download**: `GET /api/profile/ovpn` streams the user's `.ovpn` file

## Status: 🔲 TODO
