#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

INPUT="$1"

# Determine match by atomic_number (int), symbol, or name (case-insensitive for symbol/name)
# We’ll query once and format exactly as required.

QUERY_RESULT=$($PSQL "
SELECT e.atomic_number,
       e.name,
       e.symbol,
       t.type,
       p.atomic_mass,
       p.melting_point_celsius,
       p.boiling_point_celsius
FROM elements e
JOIN properties p USING(atomic_number)
JOIN types t ON p.type_id = t.type_id
WHERE
  -- atomic number
  (e.atomic_number::TEXT = '$INPUT')
  OR
  -- symbol (case-insensitive)
  (LOWER(e.symbol) = LOWER('$INPUT'))
  OR
  -- name (case-insensitive)
  (LOWER(e.name) = LOWER('$INPUT'))
LIMIT 1;
")

if [[ -z $QUERY_RESULT ]]
then
  echo "I could not find that element in the database."
  exit 0
fi

IFS="|" read A_NUM NAME SYMBOL TYPE AMASS MP BP <<< "$QUERY_RESULT"

# Ensure atomic_mass prints without unnecessary trailing zeros
# (We rely on DB normalization, but this guards weird displays.)
# No extra echoes; print exactly one line as required.
echo "The element with atomic number $A_NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of $AMASS amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius."
# script updated
