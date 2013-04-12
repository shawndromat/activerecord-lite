CREATE TABLE cats (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255),
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255),
  lname VARCHAR(255)
);

INSERT INTO humans (fname, lname) VALUES ("Devon", "Watts");
INSERT INTO cats (name, owner_id) VALUES ("Breakfast", 1);
INSERT INTO cats (name, owner_id) VALUES ("Earl", 1);
