# subby

Subnautica game helper.

## Getting started

Start the database:

```bash
docker-compose up
```

In a racket session:

```racket
(require "main.rkt")
(enter! "main.rkt")
(boot)
(q "select * from item")
```

## Features

- DSL to describe recipes
- Import of recipes into Postgres

### WIP

- UI to calculate recipes for builds

## License

MIT.  See [License](./LICENSE).
