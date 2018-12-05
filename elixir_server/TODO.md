# Think about types and relations

# Root object: Lobby -> Games

# Readme

```iex
> Absinthe.Schema.lookup_type(SchreckensWeb.Schema, "Game")
> Absinthe.Schema.lookup_type(SchreckensWeb.Schema, "RootQueryType")
```

```graphql
{
  lobby {
    games {
      id
    }
  }
}
```
