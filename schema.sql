CREATE TABLE IF NOT EXISTS item (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
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

