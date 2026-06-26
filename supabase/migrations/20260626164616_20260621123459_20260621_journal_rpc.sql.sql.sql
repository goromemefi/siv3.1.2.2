/*
# Journal RPC Function

Adds an RPC function for getting the next journal entry number.
This is used by the journal entry page to pre-populate the entry number.
*/

-- Add RPC function for getting next journal entry number
CREATE OR REPLACE FUNCTION get_next_journal_number()
RETURNS text AS $$
DECLARE
  next_num int;
BEGIN
  next_num := nextval('journal_entry_seq');
  RETURN 'JE-' || next_num::text;
END;
$$ LANGUAGE plpgsql;