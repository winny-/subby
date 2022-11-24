CREATE TABLE IF NOT EXISTS item (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  spawn_id TEXT
);

CREATE TABLE IF NOT EXISTS ingredient (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  quantity INTEGER NOT NULL,
  item UUID REFERENCES item(id) NOT NULL,
  builds UUID REFERENCES item(id) NOT NULL
);

CREATE OR REPLACE FUNCTION nameof(id UUID)
RETURNS text
AS $$
  select name from item where item.id = $1
  $$
  LANGUAGE SQL;

CREATE OR REPLACE VIEW recipe AS
  SELECT item.id AS item_id, -- Item PK
         nameof(item.id) AS item_name, -- Item name
         ingredient.id AS ingredient_entry_id, -- Ingredient PK
         ingredient.item AS ingredient_id, -- Ingredient's item FK
         nameof(ingredient.item) AS ingredient_name, -- Ingredient's item FK name
         ingredient.quantity AS quantity, -- number of this ingredient
         ingredient.builds AS builds_id, -- Builds Item FK
         nameof(ingredient.builds) AS builds_name -- Builds Item FK name
    FROM item
         INNER JOIN ingredient
             ON item.id = ingredient.builds;
