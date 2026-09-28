# Modules — ERP Agro

```
lib/
  main.dart
  core/                     # Shared: models, state, data, theme, widgets
  modules/
    auth/                   # Login
    shell/                  # App shell + dashboard
    producer/               # CADPRO — rural producer registration
    purchases/              # Planned / direct purchases
    logistics/              # Warehouse + carriers
    network/                # Lateral loans / transfers
    stock/                  # Inventory / consumption
    fees/                   # Management fee
```

Each folder under `modules/` is a feature submodule of the main Flutter app.
